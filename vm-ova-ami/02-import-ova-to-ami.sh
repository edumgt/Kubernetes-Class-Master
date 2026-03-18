#!/usr/bin/env bash
# =============================================================================
# 02-import-ova-to-ami.sh
# VirtualBox OVA 를 S3 에 업로드하고 AWS VM Import/Export 를 이용해
# AMI(Amazon Machine Image) 로 변환하는 스크립트입니다.
#
# 사전 요구 사항:
#   - AWS CLI v2  (aws configure 또는 환경변수로 자격증명 설정)
#   - vmimport IAM 역할 (README.md 참고)
#   - S3 버킷 존재 (--s3-bucket 옵션으로 지정)
#
# 사용법:
#   bash 02-import-ova-to-ami.sh [옵션]
#
# 옵션:
#   --ova       PATH        OVA 파일 경로        (기본값: ./k8s-ubuntu24.ova)
#   --s3-bucket NAME        S3 버킷 이름         (필수)
#   --s3-prefix PREFIX      S3 키 접두사         (기본값: k8s-ova-import)
#   --ami-name  NAME        AMI 이름             (기본값: k8s-ubuntu24-<timestamp>)
#   --region    REGION      AWS 리전             (기본값: us-east-1)
#   --wait                  임포트 완료까지 대기  (기본값: 활성화)
#   --no-wait               임포트 작업 ID 출력 후 즉시 종료
#   --help                  이 도움말 표시
# =============================================================================
set -euo pipefail

# ── 기본값 ────────────────────────────────────────────────────────────────────
OVA_PATH="${OVA_PATH:-$(pwd)/k8s-ubuntu24.ova}"
S3_BUCKET="${S3_BUCKET:-}"
S3_PREFIX="${S3_PREFIX:-k8s-ova-import}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
AMI_NAME="${AMI_NAME:-k8s-ubuntu24-${TIMESTAMP}}"
AWS_REGION="${AWS_REGION:-us-east-1}"
WAIT_FOR_COMPLETION="${WAIT_FOR_COMPLETION:-true}"

# ── 인수 파싱 ─────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --ova)        OVA_PATH="$2";        shift 2 ;;
    --s3-bucket)  S3_BUCKET="$2";       shift 2 ;;
    --s3-prefix)  S3_PREFIX="$2";       shift 2 ;;
    --ami-name)   AMI_NAME="$2";        shift 2 ;;
    --region)     AWS_REGION="$2";      shift 2 ;;
    --wait)       WAIT_FOR_COMPLETION="true";  shift ;;
    --no-wait)    WAIT_FOR_COMPLETION="false"; shift ;;
    --help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//' | sed '/^!/d'
      exit 0 ;;
    *) echo "알 수 없는 옵션: $1" >&2; exit 1 ;;
  esac
done

# ── 로그 함수 ─────────────────────────────────────────────────────────────────
log()  { printf '\n\033[1;34m[ova-to-ami] %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[ova-to-ami] WARNING: %s\033[0m\n' "$*"; }
die()  { printf '\033[1;31m[ova-to-ami] ERROR: %s\033[0m\n' "$*" >&2; exit 1; }

# ── 사전 조건 확인 ────────────────────────────────────────────────────────────
check_prerequisites() {
  log "사전 조건 확인"

  command -v aws >/dev/null 2>&1 \
    || die "AWS CLI v2 가 필요합니다: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"

  aws sts get-caller-identity --region "${AWS_REGION}" >/dev/null 2>&1 \
    || die "AWS 자격증명이 설정되지 않았습니다. 'aws configure' 또는 환경변수를 설정하세요."

  [[ -f "${OVA_PATH}" ]] \
    || die "OVA 파일을 찾을 수 없습니다: ${OVA_PATH}"

  [[ -n "${S3_BUCKET}" ]] \
    || die "--s3-bucket 옵션이 필요합니다."

  # vmimport 역할 존재 확인
  aws iam get-role --role-name vmimport --region "${AWS_REGION}" >/dev/null 2>&1 \
    || die "IAM 역할 'vmimport' 가 없습니다. README.md 의 IAM 설정 섹션을 참고하세요."

  log "사전 조건 OK"
}

# ── vmimport IAM 역할 정책 확인 / 생성 안내 ──────────────────────────────────
#
# 실제 생성은 README.md 를 참고하세요.
# 이 함수는 역할이 올바른 신뢰 정책을 갖는지만 확인합니다.
check_vmimport_role() {
  log "vmimport IAM 역할 확인"
  local trust
  trust="$(aws iam get-role --role-name vmimport \
    --query 'Role.AssumeRolePolicyDocument' --output json)"
  echo "${trust}" | grep -q "vmie.amazonaws.com" || {
    die "vmimport 역할의 신뢰 정책에 'vmie.amazonaws.com' 이 없습니다. README.md 의 IAM 설정 섹션을 참고하세요."
  }
  log "vmimport 역할 OK"
}

# ── S3 버킷 확인 / 생성 ───────────────────────────────────────────────────────
ensure_s3_bucket() {
  log "S3 버킷 확인: s3://${S3_BUCKET}"
  if ! aws s3api head-bucket --bucket "${S3_BUCKET}" --region "${AWS_REGION}" 2>/dev/null; then
    warn "버킷 '${S3_BUCKET}' 가 없습니다. 새로 생성합니다..."
    if [[ "${AWS_REGION}" == "us-east-1" ]]; then
      aws s3api create-bucket \
        --bucket "${S3_BUCKET}" \
        --region "${AWS_REGION}"
    else
      aws s3api create-bucket \
        --bucket "${S3_BUCKET}" \
        --region "${AWS_REGION}" \
        --create-bucket-configuration LocationConstraint="${AWS_REGION}"
    fi
    # 퍼블릭 액세스 차단
    aws s3api put-public-access-block \
      --bucket "${S3_BUCKET}" \
      --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
    log "S3 버킷 생성 완료: ${S3_BUCKET}"
  else
    log "기존 S3 버킷 사용: ${S3_BUCKET}"
  fi
}

# ── OVA → S3 업로드 ───────────────────────────────────────────────────────────
upload_ova_to_s3() {
  local ova_filename
  ova_filename="$(basename "${OVA_PATH}")"
  S3_KEY="${S3_PREFIX}/${ova_filename}"

  log "OVA 파일 S3 업로드 중..."
  log "  소스: ${OVA_PATH}"
  log "  대상: s3://${S3_BUCKET}/${S3_KEY}"

  aws s3 cp "${OVA_PATH}" "s3://${S3_BUCKET}/${S3_KEY}" \
    --region "${AWS_REGION}" \
    --no-progress

  log "S3 업로드 완료"
}

# ── VM Import 작업 시작 ───────────────────────────────────────────────────────
start_import_task() {
  log "AWS VM Import 작업 시작"

  local containers
  containers="$(cat <<JSON
[{
  "Description": "${AMI_NAME}",
  "Format": "ova",
  "UserBucket": {
    "S3Bucket": "${S3_BUCKET}",
    "S3Key":    "${S3_KEY}"
  }
}]
JSON
)"

  IMPORT_TASK_ID="$(aws ec2 import-image \
    --region "${AWS_REGION}" \
    --description "${AMI_NAME}" \
    --disk-containers "${containers}" \
    --license-type BYOL \
    --platform Linux \
    --architecture x86_64 \
    --query 'ImportTaskId' \
    --output text)"

  log "Import 작업 시작됨: ${IMPORT_TASK_ID}"
  log "  AWS 콘솔에서 확인:"
  log "  https://console.aws.amazon.com/ec2/v2/home?region=${AWS_REGION}#ImportTasks"
}

# ── Import 완료 대기 ──────────────────────────────────────────────────────────
wait_for_import() {
  if [[ "${WAIT_FOR_COMPLETION}" != "true" ]]; then
    log "--no-wait 모드: 작업 ID '${IMPORT_TASK_ID}' 를 저장한 후 나중에 확인하세요."
    log "  aws ec2 describe-import-image-tasks --import-task-ids ${IMPORT_TASK_ID} --region ${AWS_REGION}"
    return 0
  fi

  log "Import 완료 대기 중 (최대 60 분)..."
  local timeout_sec=3600
  local elapsed=0
  local check_interval=30

  while true; do
    local status_json
    status_json="$(aws ec2 describe-import-image-tasks \
      --import-task-ids "${IMPORT_TASK_ID}" \
      --region "${AWS_REGION}" \
      --query 'ImportImageTasks[0]' \
      --output json)"

    local status
    status="$(echo "${status_json}" | python3 -c "import sys,json; t=json.load(sys.stdin); print(t.get('Status',''))")"
    local progress
    progress="$(echo "${status_json}" | python3 -c "import sys,json; t=json.load(sys.stdin); print(t.get('Progress',''))")"

    log "  상태: ${status}  진행률: ${progress}%  경과: ${elapsed}s"

    case "${status}" in
      completed)
        AMI_ID="$(echo "${status_json}" | python3 -c "import sys,json; t=json.load(sys.stdin); print(t.get('ImageId',''))")"
        log "Import 완료! AMI ID: ${AMI_ID}"
        break ;;
      deleted|cancelled)
        local msg
        msg="$(echo "${status_json}" | python3 -c "import sys,json; t=json.load(sys.stdin); print(t.get('StatusMessage',''))")"
        die "Import 실패 (${status}): ${msg}" ;;
    esac

    if [[ ${elapsed} -ge ${timeout_sec} ]]; then
      die "Import 타임아웃. 작업 ID: ${IMPORT_TASK_ID}"
    fi

    sleep "${check_interval}"
    elapsed=$((elapsed + check_interval))
  done
}

# ── AMI 태그 설정 ─────────────────────────────────────────────────────────────
tag_ami() {
  [[ -z "${AMI_ID:-}" ]] && return 0
  log "AMI 태그 설정: ${AMI_ID}"
  aws ec2 create-tags \
    --region "${AWS_REGION}" \
    --resources "${AMI_ID}" \
    --tags \
      Key=Name,Value="${AMI_NAME}" \
      Key=BaseOS,Value="Ubuntu-24.04" \
      Key=K8sReady,Value="true" \
      Key=CreatedBy,Value="vm-ova-ami-bootstrap" \
      Key=CreatedAt,Value="${TIMESTAMP}"
  log "태그 설정 완료"
}

# ── 결과 요약 출력 ────────────────────────────────────────────────────────────
print_summary() {
  log "=== AMI 임포트 완료 ==="
  echo ""
  echo "  Import Task ID : ${IMPORT_TASK_ID}"
  echo "  AMI ID         : ${AMI_ID:-<--no-wait 모드: 아직 완료되지 않음>}"
  echo "  리전           : ${AWS_REGION}"
  echo "  AMI 이름       : ${AMI_NAME}"
  echo ""
  log "다음 단계: bash 03-deploy-ec2.sh --ami-id ${AMI_ID:-<AMI_ID>} --region ${AWS_REGION}"
}

# ── 메인 ─────────────────────────────────────────────────────────────────────
main() {
  log "=== OVA → AWS AMI 임포트 시작 ==="
  log "  OVA      : ${OVA_PATH}"
  log "  S3 버킷  : ${S3_BUCKET}"
  log "  리전     : ${AWS_REGION}"
  log "  AMI 이름 : ${AMI_NAME}"

  check_prerequisites
  check_vmimport_role
  ensure_s3_bucket
  upload_ova_to_s3
  start_import_task
  wait_for_import
  tag_ami
  print_summary
}

main "$@"
