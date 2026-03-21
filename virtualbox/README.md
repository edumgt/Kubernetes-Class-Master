# VirtualBox 환경 Kubernetes 실습 가이드

이 폴더는 **Oracle VM VirtualBox** 를 사용하여 로컬 PC 에서  
Kubernetes 실습 환경을 구성하는 방법을 안내합니다.

---

## 1. VirtualBox 다운로드 및 설치

### 공식 다운로드 페이지

[![VirtualBox Download](https://img.shields.io/badge/VirtualBox-Download-183A61?logo=virtualbox&logoColor=white&style=for-the-badge)](https://www.virtualbox.org/wiki/Downloads)

> **다운로드 URL**: https://www.virtualbox.org/wiki/Downloads

| OS | 다운로드 링크 |
|----|--------------|
| Windows | https://download.virtualbox.org/virtualbox/7.1.4/VirtualBox-7.1.4-165100-Win.exe |
| macOS (Intel) | https://download.virtualbox.org/virtualbox/7.1.4/VirtualBox-7.1.4-165100-OSX.dmg |
| macOS (Apple Silicon) | https://download.virtualbox.org/virtualbox/7.1.4/VirtualBox-7.1.4-165100-macOSArm64.dmg |
| Ubuntu / Debian | https://download.virtualbox.org/virtualbox/7.1.4/virtualbox-7.1_7.1.4-165100~Ubuntu~noble_amd64.deb |

### 설치 절차

```
[VirtualBox 설치 흐름]

1. 위 링크에서 OS에 맞는 설치 파일 다운로드
       ↓
2. 설치 마법사 실행 (Next → Next → Install)
       ↓
3. VirtualBox Extension Pack 설치 (USB 3.0 / RDP 지원)
   → https://www.virtualbox.org/wiki/Downloads  (All supported platforms)
       ↓
4. VirtualBox 재시작
       ↓
5. 설치 확인: VBoxManage --version
```

#### VirtualBox Extension Pack 설치

```bash
# Extension Pack 다운로드 후 VBoxManage 로 설치 (버전 일치 필수)
VBoxManage extpack install Oracle_VirtualBox_Extension_Pack-7.1.4.vbox-extpack
```

---

## 2. VM 이미지 준비

### 방법 A — 기존 OVA 임포트 (권장)

저장소의 `vm-ova-ami/` 스크립트로 생성한 OVA 를 임포트합니다.

```bash
# VirtualBox 에 OVA 임포트
VBoxManage import k8s-ubuntu24.ova \
  --vsys 0 \
  --vmname "k8s-control-plane" \
  --memory 4096 \
  --cpus 2

# NAT 포트포워딩 (SSH)
VBoxManage modifyvm "k8s-control-plane" \
  --natpf1 "ssh,tcp,,2222,,22"

# VM 시작
VBoxManage startvm "k8s-control-plane" --type headless
```

### 방법 B — Ubuntu 24.04 신규 VM 생성

```bash
# Ubuntu 24.04 Server ISO 다운로드
curl -fLo ubuntu-24.04-server.iso \
  "https://releases.ubuntu.com/24.04/ubuntu-24.04.1-live-server-amd64.iso"

# VirtualBox VM 생성 (스크립트 사용)
cd vm-ova-ami
bash 01-create-vbox-ova.sh \
  --vm-name   k8s-cp-vbox \
  --memory    4096 \
  --cpus      2 \
  --disk-size 40960
```

---

## 3. VM 내부 Kubernetes 설치

VM 접속 후 아래 순서로 Kubernetes Control Plane 을 구성합니다.

```bash
# SSH 접속 (NAT 포워딩 기준)
ssh -p 2222 ubuntu@localhost

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

# 단일 노드에서 Control Plane taint 제거 (워커 없는 경우)
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# Flannel CNI 설치
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# 확인
kubectl get nodes
kubectl get pods -A
```

---

## 4. 네트워크 구성 (선택)

```
[VirtualBox 네트워크 모드 비교]

NAT (기본):
  - 인터넷 접속 O  /  외부→VM 접근 X
  - 포트포워딩으로 SSH 접속 가능
  → 단순 실습 환경에 적합

Bridged Adapter:
  - 물리 네트워크와 동일 대역 IP 획득
  - 외부→VM 접근 O
  → 다중 VM 클러스터 구성 시 권장

Host-Only:
  - 호스트↔VM 만 통신
  - 인터넷 X (NAT와 조합 사용)
  → Control + Worker 노드 내부 통신
```

---

## 5. 실습 연결 (lecture 폴더)

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

## 6. 문제 해결

### VM 부팅 안 됨
```bash
# VT-x/AMD-V 가상화 활성화 확인 (호스트 BIOS)
VBoxManage list hostinfo | grep "Processor"

# VM 하드웨어 가속 설정
VBoxManage modifyvm "k8s-control-plane" --hwvirtex on --nested-hw-virt on
```

### 디스크 공간 부족
```bash
# VDI 디스크 확장 (VM 종료 후)
VBoxManage modifymedium disk "k8s-control-plane.vdi" --resize 81920
# VM 내부에서 파티션 확장
sudo growpart /dev/sda 1
sudo resize2fs /dev/sda1
```

### kubeadm init 실패
```bash
# 사전 조건 확인
sudo kubeadm init --dry-run
# containerd 상태 확인
sudo systemctl status containerd
# swap 확인
free -h
```

---

## 관련 링크

- VirtualBox 공식 문서: https://www.virtualbox.org/manual/
- kubeadm 설치 가이드: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/
- Kubernetes 공식 문서: https://kubernetes.io/docs/
