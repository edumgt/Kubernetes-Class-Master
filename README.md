## 학습 동선 (재배치)
- 학습용 커리큘럼 인덱스: [CURRICULUM.md](CURRICULUM.md)
- 강의 폴더: `lecture01` ~ `lecture15`

## Kubernetes의 어원
```
Kubernetes라는 용어는 고대 그리스어 'κυβερνήτης(kubernētēs)'에서 유래하였습니다. 이는 '조타수(helmsman)' 또는 '항해사(pilot)'를 의미하며, 배의 방향을 제어하고 안내하는 역할을 상징합니다. 이 용어는 2014년 Google에서 개발된 오픈소스 컨테이너 오케스트레이션 플랫폼의 이름으로 채택되었으며, 시스템이 복잡한 컨테이너 환경을 효과적으로 '조종'한다는 개념을 반영합니다. 'k8s'는 Kubernetes의 약자로, 'K'와 's' 사이에 8개의 글자('ubernete')가 있음을 나타내는 표기법입니다.
```
## 가상 머신(VM)의 개념
```
가상 머신(Virtual Machine, VM)은 물리적 하드웨어를 소프트웨어적으로 에뮬레이션하여 여러 운영 체제(OS)를 하나의 물리적 서버에서 독립적으로 실행할 수 있게 하는 기술입니다. 하이퍼바이저(hypervisor)라는 소프트웨어 계층(예: VMware, Hyper-V, KVM)이 이를 관리하며, 각 VM은 자체 OS 커널, 파일 시스템, 프로세스, 메모리 등을 할당받습니다. VM의 주요 특징은 다음과 같습니다:

자원 격리: 각 VM은 완전한 OS를 포함하므로, 다른 VM과의 간섭이 최소화됩니다.
자원 소비: OS 전체를 가상화하므로 메모리와 CPU 사용량이 높아, 오버헤드가 큽니다.
용도: 서버 가상화, 테스트 환경 구축, 레거시 애플리케이션 호스팅 등에 적합합니다.
장점: 높은 보안성과 호환성.
단점: 부팅 시간이 길고, 자원 효율성이 낮습니다.
```

## 컨테이너(Container)의 개념
```
컨테이너는 애플리케이션과 그 실행에 필요한 모든 종속성(라이브러리, 바이너리, 구성 파일 등)을 하나의 패키지로 묶어, 호스트 OS의 커널을 공유하면서 격리된 환경에서 실행하는 경량화된 가상화 기술입니다. Linux의 cgroups, namespaces, chroot 등의 OS 수준 기능을 활용합니다. 컨테이너의 주요 특징은 다음과 같습니다:

자원 격리: 프로세스 수준에서 격리되며, 호스트 OS의 커널을 공유하므로 VM보다 가볍습니다.
자원 소비: OS를 공유하므로 오버헤드가 적고, 빠른 시작이 가능합니다.
용도: 마이크로 서비스 아키텍처, CI/CD 파이프라인, 개발/프로덕션 환경 일치 등에 적합합니다.
장점: 이식성(portability)이 높아, 다양한 환경에서 동일하게 실행됩니다.
단점: 호스트 OS와 커널을 공유하므로, 보안 취약점이 발생할 수 있습니다.
```
## Docker의 개념
```
Docker는 컨테이너 기술을 기반으로 한 오픈소스 플랫폼으로, 컨테이너 이미지의 생성, 배포, 실행을 간소화합니다. 2013년에 출시된 Docker는 컨테이너 런타임(예: containerd)을 포함하며, Docker Hub와 같은 레지스트리를 통해 이미지를 공유합니다. Docker의 주요 특징은 다음과 같습니다:

이미지 기반: Dockerfile을 사용해 애플리케이션을 이미지로 빌드하며, 이를 기반으로 컨테이너를 생성합니다.
자원 관리: Docker Engine이 호스트 OS 위에서 컨테이너를 관리합니다.
용도: 개발자 도구로서, 애플리케이션 패키징과 배포를 자동화합니다.
장점: 간단한 CLI(예: docker run, docker build)로 사용이 용이하며, 생태계가 방대합니다.
단점: 단일 컨테이너 관리에 초점이 맞춰져 있어, 대규모 클러스터 관리는 추가 도구(예: Kubernetes)가 필요합니다.

Docker는 컨테이너의 한 구현체로, 다른 컨테이너 런타임(예: Podman, CRI-O)과 호환될 수 있습니다.
```

## OCI(Open Container Initiative)의 개념
```
OCI(Open Container Initiative)는 컨테이너 기술의 표준화를 목적으로 2015년에 Linux Foundation 산하에 설립된 오픈소스 프로젝트입니다. Docker와 같은 컨테이너 도구들이 서로 호환되도록 이미지 형식(OCI Image Specification)과 런타임(OCI Runtime Specification)을 정의합니다. OCI의 주요 특징은 다음과 같습니다:

표준화: 컨테이너 이미지를 빌드, 저장, 배포하는 포맷을 규정하며, 런타임은 컨테이너 실행 방식을 표준화합니다.
호환성: Docker, containerd, CRI-O 등의 런타임이 OCI를 준수하여, 벤더 락인을 방지합니다.
용도: 컨테이너 에코시스템의 상호 운용성을 높이는 데 초점 맞춤.
장점: 산업 표준으로 채택되어, 다양한 도구 간 이식성을 보장합니다.
단점: 표준 준수가 복잡성을 증가시킬 수 있습니다.

OCI는 Kubernetes와 같은 오케스트레이션 도구가 다양한 컨테이너 런타임을 지원할 수 있게 하는 기반입니다.
```

## Kubernetes(k8s)의 개념
```
Kubernetes(k8s)는 Google의 Borg 시스템에서 영감을 받아 개발된 오픈소스 컨테이너 오케스트레이션 플랫폼으로, 여러 노드(서버)에서 컨테이너를 자동으로 배포, 스케일링, 관리합니다. 2015년에 Cloud Native Computing Foundation(CNCF)에 기부되었으며, 현재 산업 표준입니다. Kubernetes의 주요 구성 요소는 다음과 같습니다:

마스터 노드: API 서버, 스케줄러, 컨트롤러 매니저 등으로 클러스터를 제어합니다.
워커 노드: Kubelet, Kube-proxy가 컨테이너(Pod)를 실행합니다.
Pod: 하나 이상의 컨테이너를 그룹화한 최소 배포 단위입니다.
용도: 클라우드 네이티브 애플리케이션 관리, 고가용성 클러스터 구축 등.
장점: 자동 복구(self-healing), 로드 밸런싱, 롤링 업데이트를 지원합니다.
단점: 학습 곡선이 가파르며, 초기 설정이 복잡합니다.
```
---
### Kubelet
- kubelet은 **각 노드(Worker/Control-plane 노드 포함)에 올라가는 쿠버네티스 “노드 에이전트”**입니다. 
- 한마디로 **“이 노드에서 Pod를 실제로 띄우고, 상태를 계속 보고하는 담당자”**예요.

kubelet이 하는 일
1) Pod를 “실제로 실행”시키는 실행 관리자

스케줄러가 “이 Pod를 이 노드에 올려라”라고 결정하면,

API 서버를 통해 그 지시가 노드에 전달되고,

kubelet이 그 Pod를 **컨테이너 런타임(containerd/CRI-O 등)**에 요청해서 실행합니다.

이미지 pull, 컨테이너 생성/시작/정지

2) 원하는 상태를 유지(자가치유의 핵심 축)

kubelet은 노드에 배치된 Pod가 스펙대로 살아있는지 계속 확인합니다.

컨테이너가 죽으면 재시작 정책에 따라 다시 띄웁니다.

Readiness/Liveness Probe 결과에 따라 “트래픽 받을 준비 됐는지/죽었는지”를 반영합니다.

3) 노드/Pod 상태를 API 서버에 보고

노드의 Ready/NotReady, 디스크 압박(DiskPressure) 같은 상태

각 Pod의 상태(Running/CrashLoopBackOff 등)

이벤트(Event) 생성(예: 이미지 풀 실패, 프로브 실패)

4) 네트워크/볼륨을 Pod에 붙이는 실행 단계 담당

CNI 플러그인을 호출해 Pod 네트워크 인터페이스를 붙이고 IP를 할당받게 합니다.

PVC를 쓰는 Pod라면 CSI/볼륨 플러그인 경로를 통해 노드에 볼륨 attach/mount가 이뤄지도록 관여합니다(환경에 따라 node plugin이 따로 있음).

5) 리소스/메트릭의 “원천”에 가까운 역할

kubectl top nodes/pods에서 metrics-server가 kubelet로부터 리소스 사용량을 수집합니다.

즉 kubelet은 노드에서 돌아가는 컨테이너들의 사용량 정보를 제공하는 쪽입니다(수집/집계는 metrics-server).

kubelet이 “어디에” 있고 “무엇과” 붙어 있나

위치: 각 노드

붙는 대상:

kube-apiserver: “지시를 받고, 상태를 보고”

container runtime(containerd/CRI-O): “컨테이너 실행”

CNI: “Pod 네트워크 구성”

CSI/볼륨 시스템: “스토리지 마운트”

(옵션) metrics-server: “리소스 사용량 제공 대상”

자주 헷갈리는 포인트

스케줄러가 “어느 노드에 배치할지” 결정

kubelet은 “결정된 Pod를 그 노드에서 실제로 띄우고 유지”

그래서 kubelet이 없으면 노드는 사실상 “일 못 하는 노드”가 됩니다.

### 실전 확인 명령(노드에서)
```
kubelet 상태
sudo systemctl status kubelet
```
---
kubelet.service could not be found가 뜨는 건 **kubeadm 방식이 아니라 k3s(또는 rke2/microk8s 같은 “통합 배포판”)**일 때 아주 흔한 상황입니다.

당신 로그/이전 맥락에 /etc/rancher/k3s/k3s.yaml이 있었죠 → 이 노드는 k3s 기반이고, 이 경우 kubelet이 별도 systemd 서비스(kubelet.service)로 존재하지 않고, k3s 서비스 안에서 같이 떠요.

1) k3s에서 “kubelet은 어떻게 에이전팅하나?”

systemd 서비스: k3s.service(서버/컨트롤플레인) 또는 k3s-agent.service(워커)

그 서비스가 실행되면 내부적으로 kubelet, kube-proxy(옵션), CNI 등을 함께 실행합니다.

### 그래서 systemctl status kubelet이 아니라 **systemctl status k3s**를 봐야 합니다
---


로그(문제 원인 찾을 때 핵심)
sudo journalctl -u kubelet -n 200 --no-pager
---


# VM, Docker, Container, OCI, Kubernetes(k8s) 차이점 비교 정리

> 이 문서는 **VM / Container / Docker / OCI(Open Container Initiative) / Kubernetes(k8s)** 를 개념·기술 관점에서 비교 정리한 자료입니다.  
> ※ 주의: **OCI**는 문맥에 따라 **Open Container Initiative(표준)** 또는 **Oracle Cloud Infrastructure(클라우드)** 를 의미하기도 합니다.  
> 이 문서에서 **OCI = Open Container Initiative** 를 뜻하며, 클라우드의 OCI(Oracle Cloud Infrastructure)는 **Oracle Cloud(오라클 클라우드)** 로 표기합니다.

---

## 1) 한 줄 요약

- **VM**: 하이퍼바이저로 **하드웨어를 가상화**하여 “OS까지 통째로” 격리 실행
- **Container(컨테이너)**: 호스트 OS의 **커널을 공유**하면서 “프로세스 단위”로 격리 실행
- **Docker**: 컨테이너를 **쉽게 빌드/배포/실행**하도록 만든 생태계(도구+포맷) *(현재는 containerd 등과 함께 표준 중심으로 재편)*
- **OCI(Open Container Initiative)**: 컨테이너의 **이미지/런타임 표준** (호환성 규격)
- **Kubernetes(k8s)**: 컨테이너를 대규모로 **배포/확장/복구/네트워킹** 하는 오케스트레이션 플랫폼

---

## 2) 비교 표 (핵심 차이)

| 측면 | VM (Virtual Machine) | Container | Docker | OCI (Open Container Initiative) | k8s (Kubernetes) |
|---|---|---|---|---|---|
| 가상화 수준 | 하드웨어 수준 (하이퍼바이저) | OS 수준 (커널 공유) | OS 수준 (컨테이너 런타임/툴체인) | 표준 사양 (이미지·런타임 규정) | OS 수준 (컨테이너 오케스트레이션) |
| 자원 효율성 | 낮음 (전체 OS 포함, 오버헤드 큼) | 높음 (경량, 커널 공유) | 높음 (컨테이너 기반) | N/A (표준화에 초점) | 높음 (대규모 클러스터 관리) |
| 격리 수준 | 높음 (완전 OS 격리) | 중간 (프로세스 격리) | 중간 (컨테이너 격리) | 중간 (런타임 표준 준수) | 중간 (Pod 단위 격리) |
| 시작 시간 | 느림 (OS 부팅 필요) | 빠름 (초 단위) | 빠름 | N/A (표준 정의) | 빠름 (자동 스케일링) |
| 관리 범위 | 단일 VM 또는 하이퍼바이저 클러스터 | 단일 컨테이너 | 단일/소규모 컨테이너 그룹 | 컨테이너 호환/표준 | 대규모 컨테이너 클러스터 |
| 주요 용도 | 서버 가상화, 멀티 OS 지원 | 앱 패키징/이식성 | 컨테이너 빌드/실행/배포 편의 | 호환성 보장, 생태계 표준 | 오케스트레이션/운영 자동화 |
| 예시 도구 | VMware, VirtualBox, KVM | LXC, Linux namespaces/cgroups | Docker Engine, Docker Compose | containerd, CRI-O 등(표준 준수) | kubectl, Helm |
| 장단점 요약 | 보안/격리 강함, 비용/오버헤드 큼 | 효율적, 커널 공유로 보안 주의 | 사용 편리, 단독 운영 스케일 한계 | 호환성↑, 구현·검증 필요 | 강력한 운영 기능, 학습·구성 복잡 |

---

## 3) 개념을 더 정확히 잡기 (헷갈리는 포인트 정리)

### 3.1 VM vs Container
- **VM**은 “하드웨어를 가상화”해서 **각 VM이 자기 OS를 갖습니다.**  
  → 격리 강하고, 서로 다른 OS(예: Windows/Linux)를 한 호스트에서 섞어 돌리기 좋습니다.
- **컨테이너**는 “OS 커널을 공유”하면서 **프로세스 단위로 격리**합니다.  
  → 더 가볍고 빠르며, 앱 배포/이식성이 뛰어납니다.

### 3.2 Docker는 컨테이너 그 자체가 아니라 “도구+생태계”
- 컨테이너 기술(네임스페이스, cgroups)은 **리눅스 커널 기능**입니다.
- Docker는 이를 편하게 쓰도록 **이미지 빌드(Dockerfile)**, **이미지 레지스트리**, **실행/네트워크/볼륨**, **Compose** 같은 개발·배포 경험을 묶었습니다.
- 현재는 컨테이너 생태계가 **OCI 표준 중심 + containerd/CRI-O 등**으로 정리되는 흐름이 강합니다.

### 3.3 OCI(Open Container Initiative)의 역할
- OCI는 “컨테이너의 표준 규격”입니다.
  - **OCI Image Spec**: 이미지 포맷 표준
  - **OCI Runtime Spec**: 런타임 동작 표준
- 결과적으로 “어떤 도구로 만들었든” **표준을 따르면 실행 호환성이 보장**됩니다.

### 3.4 Kubernetes는 “컨테이너 운영 자동화(오케스트레이션)”
- Kubernetes는 컨테이너를 “어디에, 몇 개를, 어떻게, 장애 나면 어떻게”를 **자동으로 관리**합니다.
- 직접 컨테이너를 실행하는 런타임(예: containerd)이 아니라, **클러스터 운영 계층**입니다.

---

## 4) 언제 무엇을 쓰는가? (실전 선택 가이드)

### VM이 유리한 경우
- 서로 다른 OS가 필요하거나(OS 격리), 커널 수준 격리가 특히 중요할 때
- 레거시/모놀리식 시스템을 그대로 올려야 할 때
- 규정/컴플라이언스 요구로 강한 격리가 필요할 때

### 컨테이너(Docker 포함)가 유리한 경우
- 배포 빈도가 높고, 환경 차이를 줄여야 할 때(개발/스테이징/운영 일치)
- 마이크로서비스, CI/CD 기반 운영
- 빠른 스케일 아웃(수평 확장) 및 빠른 롤백이 중요할 때

### OCI가 중요한 경우
- 런타임/도구가 바뀌어도 호환 가능한 이미지/실행 표준이 필요할 때
- 멀티 플랫폼·멀티 런타임 환경에서 표준 기반 운영을 원할 때

### Kubernetes가 유리한 경우
- 컨테이너가 “여럿”이고, 운영 자동화(배포/확장/복구/라우팅/설정 관리)가 필요할 때
- 고가용성/관측(모니터링)/정책 기반 운영이 필요한 프로덕션 환경

---

## 5) 오케스트레이션(Orchestration) 설명

오케스트레이션(orchestration)은 여러 컨테이너/서비스를 **자동으로 배포, 관리, 스케일링**하는 프로세스를 의미합니다.  
교향악단의 지휘자(orchestrator)가 각 악기를 조화롭게 이끄는 것에 비유할 수 있습니다.

Kubernetes 같은 오케스트레이션 도구에서 대표적으로 포함되는 기능은 다음과 같습니다.

- **배포(Deployment)**  
  - YAML/JSON 매니페스트로 Pod, ReplicaSet 등을 정의하고 배포  
  - 여러 복제본을 운영하여 **고가용성** 확보
- **스케일링(Scaling)**  
  - 트래픽 증가 시 Pod 수를 자동/수동으로 증감  
  - 예: **HPA(Horizontal Pod Autoscaler)** 가 CPU/메모리 등을 기준으로 확장
- **자동 복구(Self-Healing)**  
  - 실패한 Pod 감지 후 재시작/교체  
  - 예: **Liveness/Readiness Probe** 로 건강 상태 판단
- **네트워킹(Networking)**  
  - Service/Ingress 등으로 내부/외부 트래픽 라우팅  
  - ClusterIP / NodePort / LoadBalancer 등 서비스 타입 활용
- **구성 관리(Configuration Management)**  
  - ConfigMap/Secret으로 설정값·민감정보 주입
- **롤링 업데이트(Rolling Updates)**  
  - 다운타임 최소화하며 점진 배포, 문제 시 롤백

> 이점: 수동 작업 자동화로 운영 효율↑, 안정성↑  
> 주의: 복잡한 환경에서는 **관측(Observability)** 도구(예: Prometheus) 및 로깅/트레이싱 체계가 사실상 필수

---

## 6) CSP(Cloud Service Provider)에서 제공하는 컨테이너/오케스트레이션 서비스

클라우드 서비스 제공자(CSP)는 Kubernetes/컨테이너를 기반으로 한 **관리형 서비스**를 제공하여, 사용자가 클러스터를 직접 운영하지 않고도 앱을 배포할 수 있게 합니다.

### 주요 CSP 서비스 요약

| CSP | 관리형 Kubernetes | 컨테이너 이미지 레지스트리 | 서버리스/관리형 컨테이너 실행 예 |
|---|---|---|---|
| AWS | EKS | ECR | Fargate |
| GCP | GKE | Artifact Registry | Cloud Run |
| Azure | AKS | ACR | ACI |
| Oracle Cloud(오라클 클라우드) | OKE | OCI Registry | Virtual Nodes 등(옵션) |
| 기타 | IKS(IBM), ACK(Alibaba) 등 | 각사 제공 | 각사 제공 |

### 공통적으로 강조되는 포인트
- **비용 최적화**(오토스케일, 스팟/예약 인스턴스 등)
- **보안/컴플라이언스**(IAM 통합, 네트워크 정책, 감사 로깅, 표준 준수)
- **CI/CD 통합**(GitOps, 파이프라인 연계, 이미지 스캐닝 등)
- **업그레이드/운영 자동화**(관리형 컨트롤 플레인, 자동 패치 등)

---

## 7) 그림으로 보는 관계 (매우 단순화)

```
[VM]  : 하드웨어 가상화  ->  VM마다 OS 포함
[Container] : OS 커널 공유 -> 프로세스 단위 격리

Docker = 컨테이너를 편하게 쓰는 빌드/배포/실행 도구 생태계
OCI    = 컨테이너 이미지/런타임 표준 (호환성 규격)
k8s    = 컨테이너를 대규모로 운영하는 오케스트레이션 플랫폼
```

---

## 8) 결론

- **VM**은 전통적인 가상화로 **안정성과 격리**를 우선시합니다.
- **컨테이너(Docker 포함)** 는 클라우드 네이티브에서 **효율성과 이식성**을 강조합니다.
- **OCI**는 컨테이너 생태계의 **표준(호환성)** 을 제공합니다.
- **Kubernetes**는 이를 대규모로 **조율(오케스트레이션)** 하여 운영 자동화를 가능하게 합니다.


# Kube-Local 문서 모음

이 저장소는 Windows 환경에서 **VirtualBox + Ubuntu + K3s**로 로컬 Kubernetes 실습 환경을 구성하고 운영하는 과정을 정리한 문서 모음입니다. WSL/PowerShell 네트워크 점검부터 멀티노드 K3s 설치, SSH 접속, Ingress/대시보드 구성, 대시보드 재접속, HPA 오토스케일 실습까지 단계별로 안내합니다.

## 문서 구성

- **WSL/PowerShell/Docker/Kubernetes 치트시트**: `0. wsl_po wershell_docker_k8s_cheatsheet.md`
- **VirtualBox 설치 안내**: `1. virtualbox.md`
- **VirtualBox Host-Only 네트워크 구성 가이드**: `1. virtualbox_hostonly_k8s_guide.md`
- **K3s 기본 설치 메모**: `2. k3s.md`
- **K3s 멀티노드 설치 가이드**: `2. k3s_multinode_hostonly_guide.md`
- **SSH 접속 메모**: `3. ssh.md`
- **SSH 접속/트러블슈팅 가이드**: `3. ssh_access_troubleshooting_guide.md`

- **Ingress/대시보드 구성 메모**: `4. dashboard.md`
- **Ingress + Metrics Server + Dashboard 가이드**: `4. k3s_ingress_metrics_dashboard_guide.md`

- **대시보드 재접속/포트포워딩 문제 해결**: `5. dashboard_reconnect_portforward_guide.md`
- **재부팅 후 대시보드 재접속 메모**: `5. re-connect.md`
- **HPA 오토스케일 실습**: `6. AutoScaleUp_Test.md`

## 이미지 자료

실습 과정에서 사용한 스크린샷이 루트에 `image*.png` 형식으로 포함되어 있습니다.

## 활용 방법

1. **VirtualBox 설치 및 Host-Only 네트워크 구성**부터 시작합니다.
2. **K3s 멀티노드 설치 가이드**를 따라 cp1/w1/w2 노드를 구성합니다.
3. **SSH 접속 가이드**로 운영 터미널을 준비합니다.
4. **Ingress/대시보드 가이드**와 **재접속 문서**로 운영 환경을 점검합니다.
5. **HPA 오토스케일 실습**으로 자동 확장 동작을 확인합니다.

필요한 문서만 발췌하여 참고해도 되며, 각 문서는 독립적으로 읽을 수 있도록 구성되어 있습니다.
