# Kubernetes-Class-Master

## 실습 환경 선택

이 저장소는 다음 세 가지 환경에서 실습할 수 있도록 구성되어 있습니다.

| 환경 | 폴더 / 방법 | 권장 사양 |
|------|------------|-----------|
| **VirtualBox** (로컬 VM) | [`virtualbox/`](./virtualbox/) | RAM 8GB+, 4코어+ |
| **VMware** (로컬 VM) | [`vmware/`](./vmware/) | RAM 8GB+, 4코어+ |
| **GitHub Codespaces** (클라우드) | 이 저장소 → Code → Codespaces | 4 CPU / 16GB (자동 구성) |

---

## VirtualBox 다운로드 및 설치

[![VirtualBox](https://img.shields.io/badge/Oracle_VirtualBox-Download-183A61?logo=virtualbox&logoColor=white&style=for-the-badge)](https://www.virtualbox.org/wiki/Downloads)

> **공식 다운로드**: https://www.virtualbox.org/wiki/Downloads

```
[설치 단계 요약]

① OS 에 맞는 패키지 다운로드 (Windows .exe / macOS .dmg / Linux .deb/.rpm)
       ↓
② 설치 마법사 실행 (관리자/sudo 권한 필요)
       ↓
③ Extension Pack 설치 (USB 3.0, RDP 지원용)
   → 같은 페이지의 "VirtualBox Extension Pack" 다운로드 후 설치
       ↓
④ 설치 확인: VBoxManage --version
```

| OS | 직접 다운로드 |
|----|--------------|
| Windows 10/11 | https://download.virtualbox.org/virtualbox/7.1.4/VirtualBox-7.1.4-165100-Win.exe |
| macOS Intel | https://download.virtualbox.org/virtualbox/7.1.4/VirtualBox-7.1.4-165100-OSX.dmg |
| macOS Apple Silicon | https://download.virtualbox.org/virtualbox/7.1.4/VirtualBox-7.1.4-165100-macOSArm64.dmg |
| Ubuntu 24.04 | https://download.virtualbox.org/virtualbox/7.1.4/virtualbox-7.1_7.1.4-165100~Ubuntu~noble_amd64.deb |

→ VirtualBox 상세 K8s 설정: **[`virtualbox/README.md`](./virtualbox/README.md)**

---

## VMware 다운로드 및 설치

[![VMware Workstation](https://img.shields.io/badge/VMware_Workstation_Pro-Download-607078?logo=vmware&logoColor=white&style=for-the-badge)](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro)
[![VMware Fusion](https://img.shields.io/badge/VMware_Fusion_Pro-macOS-607078?logo=vmware&logoColor=white&style=for-the-badge)](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Fusion)

> **공식 다운로드 (Broadcom 계정 필요)**
> - Workstation Pro (Windows/Linux): https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro
> - Fusion Pro (macOS): https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Fusion

> **참고**: VMware Workstation Pro / Fusion Pro 는 2024년부터 개인 사용자에게 **무료** 제공됩니다.

```
[설치 단계 요약]

① Broadcom 계정 생성 또는 로그인 (https://profile.broadcom.com/web/registration)
       ↓
② 제품 페이지에서 최신 버전 설치 파일 다운로드
       ↓
③ Windows: .exe 실행 → 설치 마법사 진행 (Enhanced Keyboard Driver 포함 권장)
   macOS:  .dmg 열기 → Applications 이동 → 시스템 보안 승인
   Linux:  chmod +x *.bundle && sudo ./VMware-Workstation-Full-*.bundle
       ↓
④ 첫 실행 시 "Use for free" (개인 무료 라이선스) 선택
       ↓
⑤ 설치 확인: vmrun list
```

→ VMware 상세 K8s 설정: **[`vmware/README.md`](./vmware/README.md)**

---

## GitHub Codespaces 실습 (4 CPU / 16 GB)

이 저장소는 GitHub Codespaces 에서 **4 CPU / 16 GB** 머신으로  
Kubernetes Control Plane 단일 노드를 자동 구성합니다.

```
[Codespaces 시작 방법]

① GitHub 저장소 페이지 → "Code" 버튼 클릭
       ↓
② "Codespaces" 탭 → "..." 메뉴 → "New with options..."
       ↓
③ Machine type: "4-core" (4 CPU / 16 GB RAM) 선택
       ↓
④ "Create codespace" 클릭
       ↓
⑤ 컨테이너 빌드 완료 후 자동으로 k8s 단일 노드 클러스터 생성
       ↓
⑥ 아래 명령어로 클러스터 확인
```

```bash
# Codespaces 터미널에서 실행
kubectl config current-context   # kind-lecture
kubectl get nodes                 # control-plane Ready
kubectl get ns lecture            # lecture 네임스페이스
```

### Codespaces 자동 구성 내용

| 항목 | 값 |
|------|----|
| 머신 타입 | 4 CPU / 16 GB RAM |
| Kubernetes 배포 방식 | kind (Docker-in-Docker) |
| 클러스터 구성 | Control Plane 단일 노드 |
| 설치 도구 | kubectl, helm, kind |
| 기본 네임스페이스 | `lecture` |

---

## 학습 동선
- 통합 강의 폴더: `lecture01` ~ `lecture15`
- 각 강의는 해당 폴더의 `README.md`를 기준으로 진행
- 이론/실습 자료와 이미지가 lecture 폴더별로 함께 정리됨

## 강의 구성
- `lecture01`: 환경 구축과 Docker 이미지 준비
- `lecture02`: Kubernetes Architecture
- `lecture03`: Pods with kubectl
- `lecture04`: ReplicaSets with kubectl
- `lecture05`: Deployments with kubectl
- `lecture06`: Services with kubectl
- `lecture07`: YAML Basics와 Manifest
- `lecture08`: Pods with YAML와 Probe 안정성
- `lecture09`: ReplicaSets with YAML
- `lecture10`: Deployments with YAML
- `lecture11`: Services with YAML
- `lecture12`: Dashboard와 Observability
- `lecture13`: Auto Scaling (HPA)
- `lecture14`: Network, Ingress, Troubleshooting
- `lecture15`: Reference and Review

## 핵심 개념 요약

### Kubernetes의 어원
- Kubernetes는 고대 그리스어 `kubernētēs`(조타수/항해사)에서 유래
- `k8s`는 `K`와 `s` 사이 8글자를 줄인 표기

### VM (Virtual Machine)
- 하드웨어 가상화 기반으로 OS 단위 격리
- 장점: 격리/호환성 높음
- 단점: 자원 오버헤드 큼

### Container
- OS 커널 공유 + 프로세스 단위 격리
- 장점: 가볍고 빠른 배포
- 단점: 커널 공유로 보안/격리 설계 중요

### Docker
- 컨테이너 이미지 빌드/배포/실행 도구 생태계
- Dockerfile, 레지스트리, 실행/네트워크/볼륨 관리 제공

### OCI (Open Container Initiative)
- 컨테이너 이미지/런타임 표준
- 목적: 도구/런타임 간 호환성 확보

### Kubernetes (k8s)
- 컨테이너 오케스트레이션 플랫폼
- 배포/스케일링/복구/롤링업데이트/서비스 라우팅 자동화

## 비교 표

| 구분 | VM | Container | Docker | OCI | Kubernetes |
|---|---|---|---|---|---|
| 성격 | 하드웨어 가상화 | OS 수준 격리 | 컨테이너 도구 생태계 | 컨테이너 표준 | 오케스트레이션 플랫폼 |
| 격리 | 높음(OS 단위) | 중간(프로세스 단위) | 컨테이너 격리 기반 | 표준 자체는 실행 주체 아님 | Pod/Namespace 기반 |
| 자원 효율 | 낮음 | 높음 | 높음 | N/A | 높음 |
| 주요 목적 | 레거시/강격리 | 경량 앱 실행 | 빌드/배포 편의 | 호환성 | 대규모 운영 자동화 |

## Kubelet 정리
- kubelet은 각 노드의 에이전트로서 Pod를 실제 실행/유지
- API Server와 통신해 노드/Pod 상태 보고
- Liveness/Readiness/Startup probe 결과 반영
- metrics-server가 kubelet로부터 리소스 지표 수집

### 확인 명령
```bash
# kubeadm 계열 클러스터
sudo systemctl status kubelet
sudo journalctl -u kubelet -n 200 --no-pager

# k3s 계열 클러스터
sudo systemctl status k3s
sudo systemctl status k3s-agent
```

## 오케스트레이션 핵심 기능
- 배포(Deployment)
- 스케일링(HPA)
- 자동 복구(Self-Healing)
- 네트워킹(Service/Ingress)
- 구성 관리(ConfigMap/Secret)
- 롤링 업데이트 및 롤백

## CSP 관리형 서비스 예시

| CSP | 관리형 Kubernetes | 이미지 레지스트리 | 서버리스/관리형 컨테이너 |
|---|---|---|---|
| AWS | EKS | ECR | Fargate |
| GCP | GKE | Artifact Registry | Cloud Run |
| Azure | AKS | ACR | ACI |
| Oracle Cloud | OKE | OCIR | Virtual Nodes |

## GitHub Codespaces 실습
1. GitHub에서 이 저장소를 Codespaces로 엽니다 (4 CPU / 16 GB 머신 선택).
2. 컨테이너 생성 후 `postCreateCommand`가 실행되어 `kubectl`, `helm`, `kind`를 설치합니다.
3. kind Control Plane 단일 노드 클러스터(`kind-lecture`)가 없으면 자동 생성됩니다.
4. 클러스터 확인:
```bash
kubectl config current-context
kubectl get nodes
kubectl get ns lecture
```

## 활용 방법
1. `lecture01`부터 `lecture15` 순서로 진행합니다.
2. 각 lecture의 `README.md`에서 목표/순서를 먼저 확인합니다.
3. 실습 중 막히면 해당 lecture의 트러블슈팅 섹션부터 확인합니다.
4. 최종 복습은 `lecture15`의 치트시트/용어집/샌드박스로 마무리합니다.
