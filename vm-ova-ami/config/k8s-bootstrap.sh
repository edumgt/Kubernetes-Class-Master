#!/usr/bin/env bash
# =============================================================================
# k8s-bootstrap.sh
# Ubuntu 24.04 VM 내부에서 실행되는 Kubernetes 환경 구성 스크립트.
# autoinstall late-commands 단계 또는 첫 부팅 후 수동으로 실행합니다.
# =============================================================================
set -euo pipefail

K8S_VERSION="${K8S_VERSION:-1.30}"
KUBECTL_VERSION="${KUBECTL_VERSION:-$(curl -fsSL https://dl.k8s.io/release/stable.txt)}"
HELM_VERSION="${HELM_VERSION:-v3.18.4}"
KIND_VERSION="${KIND_VERSION:-v0.23.0}"
KIND_CLUSTER_NAME="${KIND_CLUSTER_NAME:-k8s-local}"

log() {
  printf '\n\033[1;32m[bootstrap] %s\033[0m\n' "$*"
}

arch_name() {
  case "$(uname -m)" in
    x86_64|amd64)  echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *)
      echo "Unsupported architecture: $(uname -m)" >&2
      exit 1 ;;
  esac
}

# ── 공통 패키지 ─────────────────────────────────────────────────────────────
install_common_packages() {
  log "공통 패키지 설치"
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg lsb-release \
    apt-transport-https software-properties-common \
    git jq tar unzip bash-completion
}

# ── Docker (containerd 포함) ─────────────────────────────────────────────────
install_docker() {
  if command -v docker >/dev/null 2>&1; then
    log "Docker 이미 설치됨 — 건너뜀"
    return 0
  fi
  log "Docker 설치"
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin
  systemctl enable --now docker
  usermod -aG docker ubuntu 2>/dev/null || true
  log "Docker 설치 완료"
}

# ── kubectl ───────────────────────────────────────────────────────────────────
install_kubectl() {
  if command -v kubectl >/dev/null 2>&1; then
    log "kubectl 이미 설치됨 — 건너뜀"
    return 0
  fi
  log "kubectl ${KUBECTL_VERSION} 설치"
  local arch
  arch="$(arch_name)"
  curl -fsSL -o /tmp/kubectl \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${arch}/kubectl"
  install -m 0755 /tmp/kubectl /usr/local/bin/kubectl
  kubectl completion bash > /etc/bash_completion.d/kubectl
  log "kubectl 설치 완료"
}

# ── Helm ─────────────────────────────────────────────────────────────────────
install_helm() {
  if command -v helm >/dev/null 2>&1; then
    log "Helm 이미 설치됨 — 건너뜀"
    return 0
  fi
  log "Helm ${HELM_VERSION} 설치"
  local arch
  arch="$(arch_name)"
  curl -fsSL -o /tmp/helm.tgz \
    "https://get.helm.sh/helm-${HELM_VERSION}-linux-${arch}.tar.gz"
  tar -xzf /tmp/helm.tgz -C /tmp
  install -m 0755 "/tmp/linux-${arch}/helm" /usr/local/bin/helm
  helm completion bash > /etc/bash_completion.d/helm
  log "Helm 설치 완료"
}

# ── kind ─────────────────────────────────────────────────────────────────────
install_kind() {
  if command -v kind >/dev/null 2>&1; then
    log "kind 이미 설치됨 — 건너뜀"
    return 0
  fi
  log "kind ${KIND_VERSION} 설치"
  local arch
  arch="$(arch_name)"
  curl -fsSL -o /tmp/kind \
    "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${arch}"
  install -m 0755 /tmp/kind /usr/local/bin/kind
  kind completion bash > /etc/bash_completion.d/kind
  log "kind 설치 완료"
}

# ── kind 클러스터 자동 생성 서비스 ──────────────────────────────────────────
configure_kind_cluster_service() {
  log "kind 클러스터 부팅 자동화 서비스 등록"

  cat > /usr/local/bin/kind-cluster-init.sh <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
CLUSTER="${KIND_CLUSTER_NAME:-k8s-local}"
if ! kind get clusters 2>/dev/null | grep -qx "${CLUSTER}"; then
  kind create cluster --name "${CLUSTER}" --wait 120s
fi
kubectl config use-context "kind-${CLUSTER}"
kubectl create namespace lecture --dry-run=client -o yaml | kubectl apply -f -
SCRIPT
  chmod +x /usr/local/bin/kind-cluster-init.sh

  cat > /etc/systemd/system/kind-cluster.service <<UNIT
[Unit]
Description=Bootstrap kind Kubernetes cluster
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
User=ubuntu
Environment=HOME=/home/ubuntu
Environment=KIND_CLUSTER_NAME=${KIND_CLUSTER_NAME}
ExecStart=/usr/local/bin/kind-cluster-init.sh

[Install]
WantedBy=multi-user.target
UNIT

  systemctl daemon-reload
  systemctl enable kind-cluster.service
  log "kind 클러스터 서비스 등록 완료"
}

# ── .bashrc 편의 설정 ──────────────────────────────────────────────────────
configure_bashrc() {
  log ".bashrc 편의 설정 추가"
  cat >> /home/ubuntu/.bashrc <<'RC'

# ── Kubernetes 편의 설정 ──────────────────────────────
source /etc/bash_completion
source <(kubectl completion bash) 2>/dev/null || true
source <(helm completion bash)    2>/dev/null || true
source <(kind completion bash)    2>/dev/null || true
alias k=kubectl
complete -o default -F __start_kubectl k
export KUBECONFIG="${HOME}/.kube/config"
RC
  chown ubuntu:ubuntu /home/ubuntu/.bashrc 2>/dev/null || true
}

# ── 임시 파일 정리 ────────────────────────────────────────────────────────────
cleanup() {
  log "임시 파일 정리"
  rm -f /tmp/kubectl /tmp/kind /tmp/helm.tgz /tmp/linux-*/helm 2>/dev/null || true
  apt-get clean
}

# ── 메인 ─────────────────────────────────────────────────────────────────────
main() {
  install_common_packages
  install_docker
  install_kubectl
  install_helm
  install_kind
  configure_kind_cluster_service
  configure_bashrc
  cleanup
  log "=== K8s 환경 구성 완료 ==="
  log "재부팅 후 'kind-cluster' 서비스가 자동으로 로컬 클러스터를 생성합니다."
  log "  kubectl get nodes"
  log "  kubectl get ns"
}

main "$@"
