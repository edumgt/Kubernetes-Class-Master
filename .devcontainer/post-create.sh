#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
KIND_CLUSTER_NAME="${KIND_CLUSTER_NAME:-lecture}"
MODE="${1:-}"

log() {
  printf '[codespaces] %s\n' "$*"
}

arch_name() {
  case "$(uname -m)" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *)
      log "unsupported architecture: $(uname -m)"
      exit 1
      ;;
  esac
}

sudo_cmd() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

install_common_packages() {
  sudo_cmd apt-get update
  sudo_cmd apt-get install -y --no-install-recommends ca-certificates curl tar jq
}

install_kubectl() {
  if command -v kubectl >/dev/null 2>&1; then
    return 0
  fi

  local arch
  local version
  arch="$(arch_name)"
  version="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
  curl -fsSL -o /tmp/kubectl "https://dl.k8s.io/release/${version}/bin/linux/${arch}/kubectl"
  sudo_cmd install -m 0755 /tmp/kubectl /usr/local/bin/kubectl
  log "installed kubectl ${version}"
}

install_helm() {
  if command -v helm >/dev/null 2>&1; then
    return 0
  fi

  local arch
  local version
  arch="$(arch_name)"
  version="${HELM_VERSION:-v3.18.4}"
  curl -fsSL -o /tmp/helm.tgz "https://get.helm.sh/helm-${version}-linux-${arch}.tar.gz"
  tar -xzf /tmp/helm.tgz -C /tmp
  sudo_cmd install -m 0755 "/tmp/linux-${arch}/helm" /usr/local/bin/helm
  log "installed helm ${version}"
}

install_kind() {
  if command -v kind >/dev/null 2>&1; then
    return 0
  fi

  local arch
  local version
  arch="$(arch_name)"
  version="${KIND_VERSION:-v0.23.0}"
  curl -fsSL -o /tmp/kind "https://kind.sigs.k8s.io/dl/${version}/kind-linux-${arch}"
  sudo_cmd install -m 0755 /tmp/kind /usr/local/bin/kind
  log "installed kind ${version}"
}

ensure_tools() {
  install_common_packages
  install_kubectl
  install_helm
  install_kind
}

install_metallb() {
  local metallb_version="${METALLB_VERSION:-v0.14.9}"

  if kubectl get namespace metallb-system >/dev/null 2>&1; then
    log "metallb already installed, skipping"
    return 0
  fi

  log "installing metallb ${metallb_version}"
  kubectl apply -f "https://raw.githubusercontent.com/metallb/metallb/${metallb_version}/config/manifests/metallb-native.yaml"

  log "waiting for metallb controller to be ready"
  kubectl wait --namespace metallb-system \
    --for=condition=ready pod \
    --selector=app=metallb \
    --timeout=120s

  # Derive an IP range from the kind Docker bridge network.
  # Use the last 50 host addresses of the subnet so the pool is always
  # within the actual CIDR regardless of prefix length (/16, /24, etc.).
  local kind_cidr
  kind_cidr="$(docker network inspect kind --format '{{(index .IPAM.Config 0).Subnet}}')"
  local pool_range
  pool_range="$(python3 - "${kind_cidr}" <<'PYEOF'
import ipaddress, sys
net = ipaddress.ip_network(sys.argv[1], strict=False)
hosts = list(net.hosts())
if len(hosts) < 50:
    print(f"{hosts[0]}-{hosts[-1]}")
else:
    print(f"{hosts[-50]}-{hosts[-1]}")
PYEOF
)"
  local pool_start="${pool_range%%-*}"
  local pool_end="${pool_range##*-}"

  log "configuring metallb address pool ${pool_start}-${pool_end}"
  kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: kind-pool
  namespace: metallb-system
spec:
  addresses:
    - ${pool_start}-${pool_end}
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: kind-l2
  namespace: metallb-system
spec:
  ipAddressPools:
    - kind-pool
EOF
  log "metallb ready: pool ${pool_start}-${pool_end}"
}

install_dashboard() {
  local dashboard_port="${DASHBOARD_PORT:-8443}"

  if helm status kubernetes-dashboard -n kubernetes-dashboard >/dev/null 2>&1; then
    log "kubernetes-dashboard already installed, skipping"
    return 0
  fi

  log "installing kubernetes-dashboard via helm"
  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/ >/dev/null
  helm repo update kubernetes-dashboard >/dev/null
  helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --create-namespace \
    --namespace kubernetes-dashboard \
    --set kong.proxy.type=LoadBalancer \
    --wait --timeout 180s

  # Wait for MetalLB to assign an IP to the LoadBalancer service
  log "waiting for dashboard LoadBalancer IP"
  local dashboard_ip=""
  local retries=30
  while [[ -z "${dashboard_ip}" && ${retries} -gt 0 ]]; do
    dashboard_ip="$(kubectl get svc -n kubernetes-dashboard \
      -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.status.loadBalancer.ingress[0].ip}{end}' \
      2>/dev/null || true)"
    if [[ -z "${dashboard_ip}" ]]; then
      sleep 2
      retries=$(( retries - 1 ))
    fi
  done

  if [[ -z "${dashboard_ip}" ]]; then
    log "WARNING: dashboard LoadBalancer IP not assigned; skipping proxy setup"
    return 0
  fi

  # Forward the host port to the MetalLB IP using socat.
  # A systemd service keeps the forward alive across Codespaces restarts.
  sudo_cmd apt-get install -y --no-install-recommends socat

  sudo_cmd tee /etc/systemd/system/dashboard-proxy.service >/dev/null <<SERVICE
[Unit]
Description=Kubernetes Dashboard port forward via MetalLB
After=network.target

[Service]
ExecStart=/usr/bin/socat TCP-LISTEN:${dashboard_port},bind=127.0.0.1,fork,reuseaddr TCP:${dashboard_ip}:443
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SERVICE

  sudo_cmd systemctl daemon-reload
  sudo_cmd systemctl enable --now dashboard-proxy.service
  log "dashboard proxy: localhost:${dashboard_port} -> ${dashboard_ip}:443"

  # Service account with cluster-admin rights for dashboard login
  kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-admin
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dashboard-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: dashboard-admin
    namespace: kubernetes-dashboard
EOF

  local token
  token="$(kubectl create token dashboard-admin -n kubernetes-dashboard --duration=720h)"
  install -m 600 /dev/null /tmp/dashboard-token.txt
  printf '%s\n' "${token}" > /tmp/dashboard-token.txt
  log "dashboard token : cat /tmp/dashboard-token.txt"
  log "dashboard URL   : https://localhost:${dashboard_port}"
}

ensure_kind_cluster() {
  if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
    log "docker daemon is not available, skip kind cluster bootstrap"
    return 0
  fi

  if ! kind get clusters 2>/dev/null | grep -qx "${KIND_CLUSTER_NAME}"; then
    log "creating kind cluster: ${KIND_CLUSTER_NAME}"
    kind create cluster \
      --name "${KIND_CLUSTER_NAME}" \
      --config "${SCRIPT_DIR}/kind-config.yaml" \
      --wait 180s
  else
    log "kind cluster already exists: ${KIND_CLUSTER_NAME}"
  fi

  kubectl config use-context "kind-${KIND_CLUSTER_NAME}" >/dev/null
  kubectl wait --for=condition=Ready node --all --timeout=180s
  # Single-node: allow workloads on the control-plane node
  kubectl taint nodes --all node-role.kubernetes.io/control-plane- 2>/dev/null || true
  kubectl create namespace lecture --dry-run=client -o yaml | kubectl apply -f -
  install_metallb
  install_dashboard
  log "k8s context ready: kind-${KIND_CLUSTER_NAME}"
}

main() {
  ensure_tools

  if [[ "${MODE}" == "--ci" ]]; then
    log "ci mode: skip kind cluster creation"
    kubectl version --client >/dev/null
    helm version --short >/dev/null
    kind version >/dev/null
    return 0
  fi

  ensure_kind_cluster
}

main "$@"
