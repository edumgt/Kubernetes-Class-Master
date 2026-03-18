# VM OVA → AWS AMI → EC2 배포 가이드

Ubuntu 24.04 기반 Kubernetes 환경을 VirtualBox OVA 이미지로 만들고,  
이를 AWS AMI 로 올린 뒤 EC2 로 배포하는 end-to-end 자동화 스크립트 모음입니다.

```
vm-ova-ami/
├── 01-create-vbox-ova.sh        # VirtualBox VM 생성 → OVA 내보내기
├── 02-import-ova-to-ami.sh      # OVA → S3 업로드 → AWS AMI 변환
├── 03-deploy-ec2.sh             # AMI → EC2 인스턴스 배포
├── config/
│   ├── autoinstall-user-data    # Ubuntu 24.04 자동 설치 설정 (cloud-init)
│   └── k8s-bootstrap.sh        # VM 내부 K8s 도구 설치 스크립트
└── README.md                   # 이 파일
```

---

## 사전 요구 사항

| 단계 | 필요 도구 |
|------|-----------|
| Step 1 (OVA 생성) | VirtualBox 7.x (`VBoxManage`), `genisoimage` 또는 `mkisofs`, `curl` |
| Step 2 (AMI 변환) | AWS CLI v2, 적절한 IAM 권한, S3 버킷 |
| Step 3 (EC2 배포) | AWS CLI v2, 적절한 IAM 권한 |

---

## Step 1 — VirtualBox OVA 생성

`01-create-vbox-ova.sh` 는 다음 흐름으로 동작합니다.

```
Ubuntu 24.04 ISO 다운로드
    ↓
cloud-init 시드 ISO 생성  (autoinstall-user-data + k8s-bootstrap.sh 포함)
    ↓
VirtualBox VM 생성 (EFI, 4 GB RAM, 2 CPU, 40 GB 디스크)
    ↓
헤드리스 부팅 → Ubuntu 자동 설치 → k8s-bootstrap.sh 자동 실행
    ↓
ISO 언마운트 → OVA 내보내기 → VM 삭제
```

### 실행

```bash
cd vm-ova-ami

# 기본 설정으로 실행 (Ubuntu ISO 자동 다운로드, 출력: ./k8s-ubuntu24.ova)
bash 01-create-vbox-ova.sh

# 옵션 지정 예시
bash 01-create-vbox-ova.sh \
  --vm-name   my-k8s-vm \
  --memory    8192 \
  --cpus      4 \
  --disk-size 81920 \
  --ubuntu-iso /path/to/ubuntu-24.04-live-server-amd64.iso \
  --output    /tmp/k8s-ubuntu24.ova
```

### VM 기본 계정

| 항목 | 값 |
|------|----|
| 사용자명 | `ubuntu` |
| 비밀번호 | `ubuntu` |
| SSH 포트 (NAT 포워딩) | `localhost:2222 → VM:22` |

```bash
# OVA 설치 후 SSH 접속 테스트
ssh -p 2222 ubuntu@localhost
```

### VM 내 K8s 환경

`k8s-bootstrap.sh` 가 다음 도구를 설치합니다.

| 도구 | 용도 |
|------|------|
| Docker (containerd 포함) | 컨테이너 런타임 |
| kubectl | Kubernetes CLI |
| Helm | 패키지 관리 |
| kind | 로컬 K8s 클러스터 |

부팅 후 `kind-cluster.service` 가 자동으로 `k8s-local` 클러스터를 생성합니다.

```bash
# VM 접속 후
kubectl get nodes
kubectl get ns
kind get clusters
```

---

## Step 2 — OVA → AWS AMI 변환

`02-import-ova-to-ami.sh` 는 AWS VM Import/Export 서비스를 사용합니다.

### IAM 역할 설정 (최초 1회)

AWS VM Import 에는 `vmimport` IAM 역할이 필요합니다.

```bash
# 1. 신뢰 정책 파일 생성
cat > /tmp/trust-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "vmie.amazonaws.com" },
    "Action": "sts:AssumeRole",
    "Condition": {
      "StringEquals": { "sts:Externalid": "vmimport" }
    }
  }]
}
EOF

# 2. 역할 생성
aws iam create-role \
  --role-name vmimport \
  --assume-role-policy-document file:///tmp/trust-policy.json

# 3. S3 + EC2 접근 권한 정책 파일 생성 (버킷 이름을 실제 값으로 변경)
cat > /tmp/role-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetBucketLocation","s3:GetObject","s3:ListBucket","s3:PutObject","s3:GetBucketAcl"],
      "Resource": ["arn:aws:s3:::YOUR-BUCKET-NAME","arn:aws:s3:::YOUR-BUCKET-NAME/*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:ModifySnapshotAttribute","ec2:CopySnapshot","ec2:RegisterImage",
        "ec2:Describe*","ec2:CreateTags"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# 4. 정책 연결
aws iam put-role-policy \
  --role-name vmimport \
  --policy-name vmimport \
  --policy-document file:///tmp/role-policy.json
```

### 실행

```bash
# 기본 실행 (S3 버킷 이름은 필수)
bash 02-import-ova-to-ami.sh \
  --ova       ./k8s-ubuntu24.ova \
  --s3-bucket my-vm-import-bucket \
  --region    ap-northeast-2

# 완료를 기다리지 않고 즉시 반환
bash 02-import-ova-to-ami.sh \
  --s3-bucket my-vm-import-bucket \
  --no-wait

# 임포트 상태 수동 확인
aws ec2 describe-import-image-tasks \
  --import-task-ids import-ami-XXXXXXXXXX \
  --region ap-northeast-2
```

> **소요 시간**: 30 GB OVA 기준 약 20–40 분

---

## Step 3 — AMI → EC2 배포

`03-deploy-ec2.sh` 는 임포트된 AMI 로 EC2 인스턴스를 시작합니다.

### 실행

```bash
# 기본 실행
bash 03-deploy-ec2.sh \
  --ami-id  ami-0123456789abcdef0 \
  --region  ap-northeast-2

# 옵션 지정 예시
bash 03-deploy-ec2.sh \
  --ami-id        ami-0123456789abcdef0 \
  --instance-type t3.large \
  --key-name      my-existing-key \
  --sg-name       k8s-sg \
  --region        ap-northeast-2 \
  --name          k8s-node-01 \
  --volume-size   60
```

### 접속

스크립트 완료 후 출력되는 SSH 명령어로 접속합니다.

```bash
# 키 페어를 자동 생성한 경우
ssh -i ./k8s-key-<timestamp>.pem ubuntu@<퍼블릭-IP>

# K8s 확인
kubectl get nodes
kubectl get ns
```

---

## 전체 실행 순서 요약

```bash
cd vm-ova-ami

# 1. OVA 생성 (~40 분)
bash 01-create-vbox-ova.sh

# 2. AMI 변환 (~30 분)
bash 02-import-ova-to-ami.sh \
  --s3-bucket my-vm-import-bucket \
  --region    ap-northeast-2

# 3. EC2 배포 (~2 분)
bash 03-deploy-ec2.sh \
  --ami-id  <Step 2 에서 출력된 AMI ID> \
  --region  ap-northeast-2
```

---

## 환경 변수 참조

스크립트 옵션 대신 환경 변수를 사용할 수 있습니다.

| 환경 변수 | 대응 스크립트 | 설명 |
|-----------|--------------|------|
| `VM_NAME` | 01 | VirtualBox VM 이름 |
| `VM_MEMORY` | 01 | VM RAM (MB) |
| `VM_CPUS` | 01 | VM CPU 코어 수 |
| `VM_DISK_MB` | 01 | VM 디스크 (MB) |
| `UBUNTU_ISO` | 01 | Ubuntu ISO 경로 |
| `OUTPUT_OVA` | 01 | 출력 OVA 경로 |
| `K8S_VERSION` | k8s-bootstrap | kubectl 버전 |
| `HELM_VERSION` | k8s-bootstrap | Helm 버전 |
| `KIND_VERSION` | k8s-bootstrap | kind 버전 |
| `OVA_PATH` | 02 | OVA 파일 경로 |
| `S3_BUCKET` | 02 | S3 버킷 이름 |
| `AWS_REGION` | 02, 03 | AWS 리전 |
| `AMI_ID` | 03 | 배포할 AMI ID |
| `INSTANCE_TYPE` | 03 | EC2 인스턴스 타입 |
| `KEY_NAME` | 03 | 키 페어 이름 |

---

## 관련 강의

- `lecture01` — Docker 이미지 준비 및 환경 구축
- `lecture02` — Kubernetes 아키텍처
- `lecture15` — 참고 자료 및 복습
