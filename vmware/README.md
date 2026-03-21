# VMware 환경 Kubernetes 실습 가이드

이 폴더는 **VMware Workstation Pro** (Windows/Linux) 또는  
**VMware Fusion Pro** (macOS) 를 사용하여 로컬 PC 에서  
Kubernetes 실습 환경을 구성하는 방법을 안내합니다.

> **참고**: VMware Workstation Pro / Fusion Pro 는 2024년부터 개인 사용자에게 **무료**로 제공됩니다.

---

## 1. VMware 다운로드 및 설치

### 공식 다운로드 페이지

[![VMware Workstation Download](https://img.shields.io/badge/VMware_Workstation_Pro-Download-607078?logo=vmware&logoColor=white&style=for-the-badge)](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro)

[![VMware Fusion Download](https://img.shields.io/badge/VMware_Fusion_Pro-Download_macOS-607078?logo=vmware&logoColor=white&style=for-the-badge)](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Fusion)

> **다운로드 URL (Broadcom 계정 필요)**:
> - Workstation Pro (Windows/Linux): https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro
> - Fusion Pro (macOS): https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Fusion

### 설치 절차

#### Windows — VMware Workstation Pro

```
[VMware Workstation 설치 흐름]

1. Broadcom 계정 생성 / 로그인
   → https://profile.broadcom.com/web/registration
       ↓
2. VMware Workstation Pro 설치 파일 다운로드
   (예: VMware-workstation-full-17.x.x-xxxxxxxx.exe)
       ↓
3. 설치 마법사 실행
   → Typical 설치 선택
   → Enhanced Keyboard Driver 포함 체크
       ↓
4. 설치 완료 후 라이선스 키 입력 (개인 무료 사용 시 "Use for free" 선택)
       ↓
5. VMware Workstation 실행 확인
```

#### macOS — VMware Fusion Pro

```
[VMware Fusion 설치 흐름]

1. Broadcom 계정 생성 / 로그인
       ↓
2. VMware Fusion Pro DMG 다운로드
   (예: VMware-Fusion-13.x.x-xxxxxxxx_universal.dmg)
       ↓
3. DMG 열기 → VMware Fusion.app 을 Applications 폴더로 이동
       ↓
4. 첫 실행 시 macOS 시스템 환경설정에서 보안 승인
   (시스템 환경설정 → 개인 정보 보호 및 보안 → "VMware" 허용)
       ↓
5. 개인 무료 사용 라이선스 선택
```

#### Linux — VMware Workstation Pro

```bash
# 설치 파일 실행 권한 부여 후 설치
chmod +x VMware-Workstation-Full-17.x.x-xxxxxxxx.x86_64.bundle
sudo ./VMware-Workstation-Full-17.x.x-xxxxxxxx.x86_64.bundle

# 커널 모듈 컴파일 (헤더 필요)
sudo apt-get install -y linux-headers-$(uname -r) build-essential
sudo vmware-modconfig --console --install-all
```

---

## 2. VM 이미지 준비

### 방법 A — OVA/OVF 임포트 (권장)

```bash
# VMware 에서 OVA 임포트 방법:
# 1. File → Open 또는 Import
# 2. .ova 파일 선택
# 3. 저장 위치 및 이름 설정 후 Import 클릭
```

#### vmrun CLI 를 사용한 자동 임포트

```bash
# vmrun 경로 (Windows)
# "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"

# OVF Tool 로 OVA 변환 및 임포트
ovftool \
  --name="k8s-control-plane" \
  --memorySize:1=4096 \
  --numCPUs:1=2 \
  k8s-ubuntu24.ova \
  "C:\Users\<사용자>\Documents\Virtual Machines\k8s-control-plane"
```

### 방법 B — Ubuntu 24.04 신규 VM 생성

```
[VMware Workstation 신규 VM 생성 절차]

1. File → New Virtual Machine → Custom (Advanced)
       ↓
2. Hardware compatibility: Workstation 17.x
       ↓
3. Guest OS: Ubuntu 64-bit
       ↓
4. VM 이름: k8s-control-plane
       ↓
5. Processors: 2 cores / Memory: 4096 MB
       ↓
6. Network: NAT (기본) 또는 Bridged
       ↓
7. Disk: 40 GB, Store as a single file
       ↓
8. Ubuntu 24.04 ISO 마운트 → 설치 진행
```

---

## 3. VMware Tools / open-vm-tools 설치

```bash
# VM 내부에서 실행
sudo apt-get update
sudo apt-get install -y open-vm-tools
```

---

## 4. VM 내부 Kubernetes 설치

VM 접속 후 아래 순서로 Kubernetes Control Plane 을 구성합니다.

```bash
# ---- VM 내부 명령 ----

# containerd 설치
sudo apt-get update
sudo apt-get install -y containerd

# containerd 기본 설정
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# kubeadm / kubelet / kubectl 설치
KUBE_VERSION="1.31"
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${KUBE_VERSION}/deb/Release.key" \
  | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
  https://pkgs.k8s.io/core:/stable:/v${KUBE_VERSION}/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# swap 비활성화
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# 네트워크 커널 모듈
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# Control Plane 초기화 (단일 노드)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# kubectl 설정
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 단일 노드에서 Control Plane taint 제거
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# Flannel CNI 설치
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# 확인
kubectl get nodes
kubectl get pods -A
```

---

## 5. 네트워크 구성

```
[VMware 네트워크 모드 비교]

NAT (기본, vmnet8):
  - 인터넷 접속 O
  - 호스트→VM: 포트포워딩 필요
  → 단순 실습 환경에 적합

Bridged (vmnet0):
  - 물리 네트워크와 동일 대역 IP 획득
  - 호스트/외부→VM 접근 O
  → 다중 노드 클러스터, 실제 서비스 테스트에 적합

Host-Only (vmnet1):
  - 호스트↔VM 만 통신
  → 보안이 필요한 내부 테스트 환경
```

### NAT 포트포워딩 설정 (SSH 접속)

```
VMware Workstation:
  Edit → Virtual Network Editor → VMnet8 (NAT) → NAT Settings
  → Port Forwarding → Add
     Host Port: 2222
     VM IP:     <VM의 NAT IP, 예: 192.168.182.131>
     VM Port:   22
```

```bash
# 포트포워딩 설정 후 SSH 접속
ssh -p 2222 ubuntu@localhost
```

---

## 6. 실습 연결 (lecture 폴더)

| 강의 | 주제 | 경로 |
|------|------|------|
| lecture01 | Docker 이미지 준비 / 환경 구축 | [`../lecture01`](../lecture01) |
| lecture02 | Kubernetes Architecture | [`../lecture02`](../lecture02) |
| lecture03 | Pods with kubectl | [`../lecture03`](../lecture03) |
| lecture04 | ReplicaSets with kubectl | [`../lecture04`](../lecture04) |
| lecture05 | Deployments with kubectl | [`../lecture05`](../lecture05) |
| lecture06 | Services with kubectl | [`../lecture06`](../lecture06) |
| lecture07 | YAML Basics | [`../lecture07`](../lecture07) |
| lecture08 | Pods with YAML | [`../lecture08`](../lecture08) |
| lecture09 | ReplicaSets with YAML | [`../lecture09`](../lecture09) |
| lecture10 | Deployments with YAML | [`../lecture10`](../lecture10) |
| lecture11 | Services with YAML | [`../lecture11`](../lecture11) |
| lecture12 | Dashboard / Observability | [`../lecture12`](../lecture12) |
| lecture13 | Auto Scaling (HPA) | [`../lecture13`](../lecture13) |
| lecture14 | Network / Ingress | [`../lecture14`](../lecture14) |
| lecture15 | Reference and Review | [`../lecture15`](../lecture15) |

---

## 7. 문제 해결

### VMware 가상화 중첩 (Nested Virtualization)

```bash
# VMware Workstation 에서 중첩 가상화 활성화
# VM 설정 → Processors → Virtualize Intel VT-x/EPT 체크

# 또는 .vmx 파일에 직접 추가
echo 'vhv.enable = "TRUE"' >> k8s-control-plane.vmx
```

### kubeadm init 실패

```bash
# 사전 조건 확인
sudo kubeadm init --dry-run
# 컨테이너 런타임 확인
sudo systemctl status containerd
# swap 확인
free -h
```

### 네트워크 플러그인 Pod CrashLoopBackOff

```bash
# flannel 로그 확인
kubectl logs -n kube-flannel -l app=flannel
# 인터페이스 확인 (vmxnet3)
ip link show
```

---

## 관련 링크

- VMware Workstation Pro: https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro
- VMware Fusion Pro: https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Fusion
- OVF Tool: https://developer.broadcom.com/tools/open-virtualization-format-ovf-tool/
- kubeadm 설치 가이드: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/
- Kubernetes 공식 문서: https://kubernetes.io/docs/
