#!/usr/bin/env bash
# =============================================================================
# 01-create-vbox-ova.sh
# VirtualBox를 이용해 Ubuntu 24.04 기반 Kubernetes 환경 VM을 생성하고
# OVA 파일로 내보내는 부트스트랩 스크립트입니다.
#
# 사전 요구 사항:
#   - VirtualBox 7.x  (VBoxManage 명령이 PATH에 있어야 합니다)
#   - genisoimage 또는 mkisofs  (시드 ISO 생성용)
#   - curl
#   - 최소 40 GB 여유 디스크 공간
#   - 최소 8 GB RAM (VM 할당 기본값 4 GB)
#
# 사용법:
#   bash 01-create-vbox-ova.sh [옵션]
#
# 옵션:
#   --vm-name   NAME       VM 이름          (기본값: k8s-ubuntu24)
#   --memory    MB         RAM(MB)          (기본값: 4096)
#   --cpus      N          CPU 코어 수       (기본값: 2)
#   --disk-size MB         디스크 크기(MB)  (기본값: 40960  = 40 GB)
#   --ubuntu-iso PATH      Ubuntu ISO 경로  (없으면 자동 다운로드)
#   --output    PATH       OVA 저장 경로    (기본값: ./k8s-ubuntu24.ova)
#   --help                 이 도움말 표시
# =============================================================================
set -euo pipefail

# ── 기본값 ────────────────────────────────────────────────────────────────────
VM_NAME="${VM_NAME:-k8s-ubuntu24}"
VM_MEMORY="${VM_MEMORY:-4096}"
VM_CPUS="${VM_CPUS:-2}"
VM_DISK_MB="${VM_DISK_MB:-40960}"
UBUNTU_ISO="${UBUNTU_ISO:-}"
OUTPUT_OVA="${OUTPUT_OVA:-$(pwd)/k8s-ubuntu24.ova}"
WORK_DIR="${WORK_DIR:-/tmp/vbox-k8s-build}"
UBUNTU_ISO_URL="https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"

# ── 인수 파싱 ─────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --vm-name)    VM_NAME="$2";    shift 2 ;;
    --memory)     VM_MEMORY="$2";  shift 2 ;;
    --cpus)       VM_CPUS="$2";    shift 2 ;;
    --disk-size)  VM_DISK_MB="$2"; shift 2 ;;
    --ubuntu-iso) UBUNTU_ISO="$2"; shift 2 ;;
    --output)     OUTPUT_OVA="$2"; shift 2 ;;
    --help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//' | sed '/^!/d'
      exit 0 ;;
    *) echo "알 수 없는 옵션: $1" >&2; exit 1 ;;
  esac
done

# ── 로그 함수 ─────────────────────────────────────────────────────────────────
log()  { printf '\n\033[1;34m[vbox-bootstrap] %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[vbox-bootstrap] WARNING: %s\033[0m\n' "$*"; }
die()  { printf '\033[1;31m[vbox-bootstrap] ERROR: %s\033[0m\n' "$*" >&2; exit 1; }

# ── 사전 조건 확인 ────────────────────────────────────────────────────────────
check_prerequisites() {
  log "사전 조건 확인"

  command -v VBoxManage >/dev/null 2>&1 \
    || die "VBoxManage 를 찾을 수 없습니다. VirtualBox 7.x 를 설치하세요."

  if command -v genisoimage >/dev/null 2>&1; then
    ISO_CMD="genisoimage"
  elif command -v mkisofs >/dev/null 2>&1; then
    ISO_CMD="mkisofs"
  else
    die "genisoimage 또는 mkisofs 가 필요합니다.\n  sudo apt-get install -y genisoimage"
  fi

  command -v curl >/dev/null 2>&1 || die "curl 이 필요합니다."

  log "사전 조건 OK (VBoxManage, ${ISO_CMD}, curl)"
}

# ── Ubuntu ISO 준비 ───────────────────────────────────────────────────────────
prepare_ubuntu_iso() {
  if [[ -n "${UBUNTU_ISO}" && -f "${UBUNTU_ISO}" ]]; then
    log "기존 Ubuntu ISO 사용: ${UBUNTU_ISO}"
    return 0
  fi

  UBUNTU_ISO="${WORK_DIR}/ubuntu-24.04-server.iso"
  if [[ -f "${UBUNTU_ISO}" ]]; then
    log "캐시된 Ubuntu ISO 사용: ${UBUNTU_ISO}"
    return 0
  fi

  log "Ubuntu 24.04 Server ISO 다운로드 중..."
  mkdir -p "${WORK_DIR}"
  curl -L --progress-bar -o "${UBUNTU_ISO}" "${UBUNTU_ISO_URL}" \
    || die "ISO 다운로드 실패: ${UBUNTU_ISO_URL}"
  log "다운로드 완료: ${UBUNTU_ISO}"
}

# ── 시드 ISO 생성 (cloud-init / autoinstall) ──────────────────────────────────
#
# Ubuntu 24.04 autoinstall 은 두 번째 CD-ROM 드라이브에 마운트된 ISO 에서
# /autoinstall.yaml (또는 /user-data + /meta-data) 를 읽습니다.
# 여기서는 NoCloud 시드 ISO 방식을 사용합니다.
# -----------------------------------------------------------------------------
create_seed_iso() {
  log "시드 ISO(cloud-init) 생성"

  local seed_dir="${WORK_DIR}/seed"
  local seed_iso="${WORK_DIR}/seed.iso"

  rm -rf "${seed_dir}" && mkdir -p "${seed_dir}"

  # user-data (= autoinstall 설정)
  cp "${CONFIG_DIR}/autoinstall-user-data" "${seed_dir}/user-data"

  # meta-data (비어있어도 됨)
  cat > "${seed_dir}/meta-data" <<'META'
instance-id: k8s-ubuntu24
local-hostname: k8s-node
META

  # k8s-bootstrap.sh 를 시드 ISO 에 포함 → late-commands 에서 /cdrom/k8s-bootstrap.sh 로 접근
  cp "${CONFIG_DIR}/k8s-bootstrap.sh" "${seed_dir}/k8s-bootstrap.sh"

  ${ISO_CMD} \
    -output "${seed_iso}" \
    -volid CIDATA \
    -joliet -rock \
    "${seed_dir}"

  SEED_ISO="${seed_iso}"
  log "시드 ISO 생성 완료: ${seed_iso}"
}

# ── VirtualBox VM 생성 ────────────────────────────────────────────────────────
create_vm() {
  log "VirtualBox VM 생성: ${VM_NAME}"

  # 동일 이름 VM 이 이미 있으면 삭제
  if VBoxManage showvminfo "${VM_NAME}" >/dev/null 2>&1; then
    warn "기존 VM '${VM_NAME}' 삭제 중..."
    VBoxManage unregistervm "${VM_NAME}" --delete 2>/dev/null || true
  fi

  local vdi="${WORK_DIR}/${VM_NAME}.vdi"

  VBoxManage createvm \
    --name "${VM_NAME}" \
    --ostype Ubuntu_64 \
    --register

  VBoxManage modifyvm "${VM_NAME}" \
    --memory "${VM_MEMORY}" \
    --cpus "${VM_CPUS}" \
    --vram 16 \
    --graphicscontroller vmsvga \
    --firmware efi \
    --nic1 nat \
    --natpf1 "ssh,tcp,,2222,,22" \
    --audio none \
    --usb off \
    --usbehci off

  # 스토리지 컨트롤러 (SATA)
  VBoxManage storagectl "${VM_NAME}" \
    --name "SATA" \
    --add sata \
    --controller IntelAhci \
    --portcount 4 \
    --bootable on

  # 가상 디스크 생성
  VBoxManage createmedium disk \
    --filename "${vdi}" \
    --size "${VM_DISK_MB}" \
    --format VDI

  VBoxManage storageattach "${VM_NAME}" \
    --storagectl "SATA" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "${vdi}"

  # Ubuntu 설치 ISO (port 1)
  VBoxManage storageattach "${VM_NAME}" \
    --storagectl "SATA" \
    --port 1 \
    --device 0 \
    --type dvddrive \
    --medium "${UBUNTU_ISO}"

  # 시드 ISO (port 2) — autoinstall 이 여기서 user-data 를 읽음
  VBoxManage storageattach "${VM_NAME}" \
    --storagectl "SATA" \
    --port 2 \
    --device 0 \
    --type dvddrive \
    --medium "${SEED_ISO}"

  # 부트 순서: 광학 → 디스크
  VBoxManage modifyvm "${VM_NAME}" \
    --boot1 dvd \
    --boot2 disk \
    --boot3 none \
    --boot4 none

  log "VM 생성 완료"
}

# ── VM 부팅 및 자동 설치 대기 ────────────────────────────────────────────────
boot_and_install() {
  log "VM 부팅 시작 (헤드리스 모드)"
  VBoxManage startvm "${VM_NAME}" --type headless

  log "Ubuntu 자동 설치 완료를 기다립니다 (최대 40 분)..."
  log "  진행 상황은 다음 명령으로 확인하세요:"
  log "    VBoxManage controlvm ${VM_NAME} screenshotpng /tmp/screen.png"

  # VM 이 종료될 때까지 대기 (autoinstall 완료 후 reboot → 설치 완료)
  local timeout_sec=2400   # 40 분
  local elapsed=0
  local check_interval=30

  while VBoxManage list runningvms 2>/dev/null | grep -q "\"${VM_NAME}\""; do
    if [[ ${elapsed} -ge ${timeout_sec} ]]; then
      die "설치 타임아웃 (${timeout_sec}s). VM 상태를 수동으로 확인하세요."
    fi
    sleep "${check_interval}"
    elapsed=$((elapsed + check_interval))
    log "  경과: ${elapsed}s / ${timeout_sec}s"
  done

  log "VM 설치 완료 (종료 감지)"
}

# ── 설치 후 ISO 언마운트 및 재부팅 확인 ─────────────────────────────────────
post_install_cleanup() {
  log "ISO 드라이브 제거"

  VBoxManage storageattach "${VM_NAME}" \
    --storagectl "SATA" --port 1 --device 0 \
    --type dvddrive --medium emptydrive 2>/dev/null || true

  VBoxManage storageattach "${VM_NAME}" \
    --storagectl "SATA" --port 2 --device 0 \
    --type dvddrive --medium emptydrive 2>/dev/null || true

  # 부트 순서를 디스크 우선으로 변경
  VBoxManage modifyvm "${VM_NAME}" \
    --boot1 disk --boot2 none --boot3 none --boot4 none

  log "ISO 제거 완료"
}

# ── OVA 내보내기 ──────────────────────────────────────────────────────────────
export_ova() {
  log "OVA 내보내기: ${OUTPUT_OVA}"
  mkdir -p "$(dirname "${OUTPUT_OVA}")"
  VBoxManage export "${VM_NAME}" \
    --output "${OUTPUT_OVA}" \
    --ovf20 \
    --manifest \
    --options manifest,nomacs
  log "OVA 내보내기 완료: ${OUTPUT_OVA}"
  ls -lh "${OUTPUT_OVA}"
}

# ── 정리 ──────────────────────────────────────────────────────────────────────
cleanup_vm() {
  log "임시 VM 정리 (OVA 내보내기 후)"
  VBoxManage unregistervm "${VM_NAME}" --delete 2>/dev/null || true
  log "VM 정리 완료"
}

# ── 메인 ─────────────────────────────────────────────────────────────────────
main() {
  log "=== VirtualBox OVA 부트스트랩 시작 ==="
  log "  VM 이름  : ${VM_NAME}"
  log "  RAM      : ${VM_MEMORY} MB"
  log "  CPU      : ${VM_CPUS} 코어"
  log "  디스크   : ${VM_DISK_MB} MB"
  log "  출력 OVA : ${OUTPUT_OVA}"

  mkdir -p "${WORK_DIR}"

  check_prerequisites
  prepare_ubuntu_iso
  create_seed_iso
  create_vm
  boot_and_install
  post_install_cleanup
  export_ova
  cleanup_vm

  log "=== 완료 ==="
  log "생성된 OVA: ${OUTPUT_OVA}"
  log "다음 단계: bash 02-import-ova-to-ami.sh --ova ${OUTPUT_OVA}"
}

main "$@"
