#!/usr/bin/env bash
# =============================================================================
# 03-deploy-ec2.sh
# AWS EC2 인스턴스를 AMI 에서 배포하는 스크립트입니다.
#
# 사전 요구 사항:
#   - AWS CLI v2  (aws configure 또는 환경변수로 자격증명 설정)
#   - 배포할 AMI ID (02-import-ova-to-ami.sh 실행 결과)
#   - VPC / 서브넷 (기본 VPC 사용 가능)
#
# 사용법:
#   bash 03-deploy-ec2.sh [옵션]
#
# 옵션:
#   --ami-id        AMI_ID     배포할 AMI ID            (필수)
#   --instance-type TYPE       EC2 인스턴스 타입         (기본값: t3.medium)
#   --key-name      NAME       키 페어 이름              (없으면 자동 생성)
#   --sg-name       NAME       보안 그룹 이름            (기본값: k8s-sg)
#   --subnet-id     ID         서브넷 ID                 (기본값: 기본 VPC 의 첫 번째 서브넷)
#   --region        REGION     AWS 리전                  (기본값: us-east-1)
#   --name          NAME       EC2 인스턴스 이름 태그    (기본값: k8s-ubuntu24-node)
#   --volume-size   GB         루트 볼륨 크기 (GB)       (기본값: 40)
#   --allowed-cidr  CIDR       인바운드 허용 CIDR        (기본값: 현재 공인 IP/32)
#   --help                     이 도움말 표시
# =============================================================================
set -euo pipefail

# ── 기본값 ────────────────────────────────────────────────────────────────────
AMI_ID="${AMI_ID:-}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t3.medium}"
KEY_NAME="${KEY_NAME:-}"
SG_NAME="${SG_NAME:-k8s-sg}"
SUBNET_ID="${SUBNET_ID:-}"
AWS_REGION="${AWS_REGION:-us-east-1}"
INSTANCE_NAME="${INSTANCE_NAME:-k8s-ubuntu24-node}"
VOLUME_SIZE_GB="${VOLUME_SIZE_GB:-40}"
# ALLOWED_CIDR: 빈 값이면 실행 시 현재 공인 IP 를 자동으로 조회합니다.
# 공인 IP 조회에 실패하면 0.0.0.0/0 을 사용하고 경고를 출력합니다.
ALLOWED_CIDR="${ALLOWED_CIDR:-}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
KEY_DIR="${KEY_DIR:-$(pwd)}"

# ── 인수 파싱 ─────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --ami-id)        AMI_ID="$2";         shift 2 ;;
    --instance-type) INSTANCE_TYPE="$2";  shift 2 ;;
    --key-name)      KEY_NAME="$2";       shift 2 ;;
    --sg-name)       SG_NAME="$2";        shift 2 ;;
    --subnet-id)     SUBNET_ID="$2";      shift 2 ;;
    --region)        AWS_REGION="$2";     shift 2 ;;
    --name)          INSTANCE_NAME="$2";  shift 2 ;;
    --volume-size)   VOLUME_SIZE_GB="$2"; shift 2 ;;
    --allowed-cidr)  ALLOWED_CIDR="$2";   shift 2 ;;
    --help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//' | sed '/^!/d'
      exit 0 ;;
    *) echo "알 수 없는 옵션: $1" >&2; exit 1 ;;
  esac
done

# ── 로그 함수 ─────────────────────────────────────────────────────────────────
log()  { printf '\n\033[1;34m[deploy-ec2] %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[deploy-ec2] WARNING: %s\033[0m\n' "$*"; }
die()  { printf '\033[1;31m[deploy-ec2] ERROR: %s\033[0m\n' "$*" >&2; exit 1; }

# ── 사전 조건 확인 ────────────────────────────────────────────────────────────
check_prerequisites() {
  log "사전 조건 확인"

  command -v aws >/dev/null 2>&1 \
    || die "AWS CLI v2 가 필요합니다."

  aws sts get-caller-identity --region "${AWS_REGION}" >/dev/null 2>&1 \
    || die "AWS 자격증명이 설정되지 않았습니다."

  [[ -n "${AMI_ID}" ]] \
    || die "--ami-id 옵션이 필요합니다. (예: --ami-id ami-0123456789abcdef0)"

  # AMI 존재 확인
  aws ec2 describe-images \
    --image-ids "${AMI_ID}" \
    --region "${AWS_REGION}" \
    --query 'Images[0].ImageId' \
    --output text >/dev/null 2>&1 \
    || die "AMI '${AMI_ID}' 를 찾을 수 없습니다."

  log "사전 조건 OK"
}

# ── 허용 CIDR 결정 ────────────────────────────────────────────────────────────
resolve_allowed_cidr() {
  if [[ -n "${ALLOWED_CIDR}" ]]; then
    log "인바운드 허용 CIDR: ${ALLOWED_CIDR}"
    return 0
  fi

  # 현재 공인 IP 를 자동 조회하여 /32 로 제한
  local my_ip
  my_ip="$(curl -fsSL --connect-timeout 5 https://checkip.amazonaws.com 2>/dev/null \
    || curl -fsSL --connect-timeout 5 https://api.ipify.org 2>/dev/null \
    || echo "")"

  if [[ -n "${my_ip}" ]]; then
    ALLOWED_CIDR="${my_ip}/32"
    log "현재 공인 IP 기반 CIDR: ${ALLOWED_CIDR}"
  else
    ALLOWED_CIDR="0.0.0.0/0"
    warn "공인 IP 조회 실패. 모든 IP 허용(0.0.0.0/0) 으로 설정됩니다."
    warn "보안 강화를 위해 --allowed-cidr 옵션으로 특정 IP 범위를 지정하세요."
  fi
}

# ── 키 페어 준비 ─────────────────────────────────────────────────────────────
ensure_key_pair() {
  if [[ -n "${KEY_NAME}" ]]; then
    # 지정된 키 페어가 AWS 에 있는지 확인
    aws ec2 describe-key-pairs \
      --key-names "${KEY_NAME}" \
      --region "${AWS_REGION}" >/dev/null 2>&1 \
      || die "키 페어 '${KEY_NAME}' 를 찾을 수 없습니다."
    log "기존 키 페어 사용: ${KEY_NAME}"
    return 0
  fi

  # 새 키 페어 자동 생성
  KEY_NAME="k8s-key-${TIMESTAMP}"
  local key_file="${KEY_DIR}/${KEY_NAME}.pem"
  log "키 페어 생성: ${KEY_NAME}"

  aws ec2 create-key-pair \
    --key-name "${KEY_NAME}" \
    --region "${AWS_REGION}" \
    --query 'KeyMaterial' \
    --output text > "${key_file}"

  chmod 400 "${key_file}"
  log "개인 키 저장됨: ${key_file}"
  log "  (이 파일을 안전하게 보관하세요. EC2 SSH 접속에 필요합니다.)"
}

# ── 보안 그룹 준비 ────────────────────────────────────────────────────────────
ensure_security_group() {
  log "보안 그룹 확인/생성: ${SG_NAME}"

  # 기본 VPC ID 조회
  VPC_ID="$(aws ec2 describe-vpcs \
    --region "${AWS_REGION}" \
    --filters "Name=isDefault,Values=true" \
    --query 'Vpcs[0].VpcId' \
    --output text)"

  [[ "${VPC_ID}" != "None" && -n "${VPC_ID}" ]] \
    || die "기본 VPC 를 찾을 수 없습니다. --subnet-id 를 직접 지정하거나 기본 VPC 를 생성하세요."

  log "VPC: ${VPC_ID}"

  # 기존 SG 조회
  SG_ID="$(aws ec2 describe-security-groups \
    --region "${AWS_REGION}" \
    --filters \
      "Name=group-name,Values=${SG_NAME}" \
      "Name=vpc-id,Values=${VPC_ID}" \
    --query 'SecurityGroups[0].GroupId' \
    --output text 2>/dev/null || echo "")"

  if [[ "${SG_ID}" == "None" || -z "${SG_ID}" ]]; then
    log "보안 그룹 생성: ${SG_NAME}  (허용 CIDR: ${ALLOWED_CIDR})"
    SG_ID="$(aws ec2 create-security-group \
      --group-name "${SG_NAME}" \
      --description "K8s Ubuntu 24.04 Node — SSH 및 Kubernetes API 접근" \
      --vpc-id "${VPC_ID}" \
      --region "${AWS_REGION}" \
      --query 'GroupId' \
      --output text)"

    # SSH (22) 인바운드 허용
    aws ec2 authorize-security-group-ingress \
      --group-id "${SG_ID}" \
      --protocol tcp \
      --port 22 \
      --cidr "${ALLOWED_CIDR}" \
      --region "${AWS_REGION}"

    # Kubernetes API Server (6443) 인바운드 허용
    aws ec2 authorize-security-group-ingress \
      --group-id "${SG_ID}" \
      --protocol tcp \
      --port 6443 \
      --cidr "${ALLOWED_CIDR}" \
      --region "${AWS_REGION}"

    # NodePort 범위 (30000-32767) 허용
    aws ec2 authorize-security-group-ingress \
      --group-id "${SG_ID}" \
      --protocol tcp \
      --port 30000-32767 \
      --cidr "${ALLOWED_CIDR}" \
      --region "${AWS_REGION}"

    log "보안 그룹 생성 완료: ${SG_ID}"
  else
    log "기존 보안 그룹 사용: ${SG_ID}"
  fi
}

# ── 서브넷 조회 ───────────────────────────────────────────────────────────────
ensure_subnet() {
  if [[ -n "${SUBNET_ID}" ]]; then
    log "지정된 서브넷 사용: ${SUBNET_ID}"
    return 0
  fi

  log "기본 VPC 의 첫 번째 퍼블릭 서브넷 조회"
  SUBNET_ID="$(aws ec2 describe-subnets \
    --region "${AWS_REGION}" \
    --filters \
      "Name=vpc-id,Values=${VPC_ID}" \
      "Name=defaultForAz,Values=true" \
    --query 'Subnets[0].SubnetId' \
    --output text)"

  [[ "${SUBNET_ID}" != "None" && -n "${SUBNET_ID}" ]] \
    || die "기본 VPC 의 서브넷을 찾을 수 없습니다. --subnet-id 를 직접 지정하세요."

  log "서브넷: ${SUBNET_ID}"
}

# ── AMI 루트 디바이스 이름 조회 ───────────────────────────────────────────────
get_root_device_name() {
  ROOT_DEVICE="$(aws ec2 describe-images \
    --image-ids "${AMI_ID}" \
    --region "${AWS_REGION}" \
    --query 'Images[0].RootDeviceName' \
    --output text)"
  [[ -n "${ROOT_DEVICE}" ]] || ROOT_DEVICE="/dev/sda1"
  log "루트 디바이스: ${ROOT_DEVICE}"
}

# ── EC2 인스턴스 시작 ────────────────────────────────────────────────────────
launch_instance() {
  log "EC2 인스턴스 시작"

  INSTANCE_ID="$(aws ec2 run-instances \
    --image-id "${AMI_ID}" \
    --instance-type "${INSTANCE_TYPE}" \
    --key-name "${KEY_NAME}" \
    --security-group-ids "${SG_ID}" \
    --subnet-id "${SUBNET_ID}" \
    --region "${AWS_REGION}" \
    --associate-public-ip-address \
    --block-device-mappings "[{
      \"DeviceName\": \"${ROOT_DEVICE}\",
      \"Ebs\": {
        \"VolumeSize\": ${VOLUME_SIZE_GB},
        \"VolumeType\": \"gp3\",
        \"DeleteOnTermination\": true
      }
    }]" \
    --tag-specifications \
      "ResourceType=instance,Tags=[
        {Key=Name,Value=${INSTANCE_NAME}},
        {Key=BaseOS,Value=Ubuntu-24.04},
        {Key=K8sReady,Value=true},
        {Key=CreatedBy,Value=vm-ova-ami-bootstrap},
        {Key=CreatedAt,Value=${TIMESTAMP}}
      ]" \
    --query 'Instances[0].InstanceId' \
    --output text)"

  log "인스턴스 시작됨: ${INSTANCE_ID}"
}

# ── 인스턴스 실행 대기 ────────────────────────────────────────────────────────
wait_for_instance() {
  log "인스턴스 running 상태 대기..."
  aws ec2 wait instance-running \
    --instance-ids "${INSTANCE_ID}" \
    --region "${AWS_REGION}"
  log "인스턴스 running 상태 확인됨: ${INSTANCE_ID}"
}

# ── 퍼블릭 IP 조회 ────────────────────────────────────────────────────────────
get_public_ip() {
  PUBLIC_IP="$(aws ec2 describe-instances \
    --instance-ids "${INSTANCE_ID}" \
    --region "${AWS_REGION}" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)"
  log "퍼블릭 IP: ${PUBLIC_IP}"
}

# ── 결과 요약 출력 ────────────────────────────────────────────────────────────
print_summary() {
  echo ""
  log "=== EC2 배포 완료 ==="
  echo ""
  echo "  인스턴스 ID   : ${INSTANCE_ID}"
  echo "  인스턴스 타입 : ${INSTANCE_TYPE}"
  echo "  AMI ID        : ${AMI_ID}"
  echo "  퍼블릭 IP     : ${PUBLIC_IP}"
  echo "  리전          : ${AWS_REGION}"
  echo "  키 페어       : ${KEY_NAME}"
  echo ""
  echo "  SSH 접속:"
  if [[ -f "${KEY_DIR}/${KEY_NAME}.pem" ]]; then
    echo "    ssh -i ${KEY_DIR}/${KEY_NAME}.pem ubuntu@${PUBLIC_IP}"
  else
    echo "    ssh -i <your-key.pem> ubuntu@${PUBLIC_IP}"
  fi
  echo ""
  echo "  K8s 클러스터 확인 (SSH 접속 후):"
  echo "    kubectl get nodes"
  echo "    kubectl get ns"
  echo ""
  echo "  인스턴스 종료:"
  echo "    aws ec2 terminate-instances --instance-ids ${INSTANCE_ID} --region ${AWS_REGION}"
  echo ""
}

# ── 메인 ─────────────────────────────────────────────────────────────────────
main() {
  log "=== AWS EC2 배포 시작 ==="
  log "  AMI ID         : ${AMI_ID}"
  log "  인스턴스 타입  : ${INSTANCE_TYPE}"
  log "  리전           : ${AWS_REGION}"
  log "  인스턴스 이름  : ${INSTANCE_NAME}"

  check_prerequisites
  resolve_allowed_cidr
  ensure_key_pair
  ensure_security_group
  ensure_subnet
  get_root_device_name
  launch_instance
  wait_for_instance
  get_public_ip
  print_summary
}

main "$@"
