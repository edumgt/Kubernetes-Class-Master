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
