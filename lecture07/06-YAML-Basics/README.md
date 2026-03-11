# YAML 기본 문법

## Step-01: 주석과 Key-Value
- 콜론 뒤에는 **공백**이 있어야 키/값이 구분됩니다.
```yml
# 단순 key-value 정의
name: kalyan
age: 23
city: Hyderabad
```

## Step-02: Dictionary / Map
- 하나의 키 아래 여러 속성을 묶어서 표현합니다.
- 동일한 깊이의 항목은 **같은 들여쓰기**가 필요합니다.
```yml
person:
  name: kalyan
  age: 23
  city: Hyderabad
```

## Step-03: Array / List
- `-` 기호가 배열 요소를 의미합니다.
```yml
person: # Dictionary
  name: kalyan
  age: 23
  city: Hyderabad
  hobbies: # List
    - cycling
    - cookines
  hobbies: [cycling, cooking]   # 다른 표기 방식의 List
```

## Step-04: 중첩 리스트
- 리스트 안에 딕셔너리를 넣어 구조화할 수 있습니다.
```yml
person: # Dictionary
  name: kalyan
  age: 23
  city: Hyderabad
  hobbies: # List
    - cycling
    - cooking
  hobbies: [cycling, cooking]   # 다른 표기 방식의 List
  friends:
    - name: friend1
      age: 22
    - name: friend2
      age: 25
```

## Step-05: Pod 템플릿 예시
- Kubernetes 매니페스트는 보통 `apiVersion`, `kind`, `metadata`, `spec`로 구성됩니다.
```yml
apiVersion: v1 # String
kind: Pod  # String
metadata: # Dictionary
  name: myapp-pod
  labels: # Dictionary
    app: myapp
spec:
  containers: # List
    - name: myapp
      image: stacksimplify/kubenginx:1.0.0
      ports:
        - containerPort: 80
          protocol: "TCP"
        - containerPort: 81
          protocol: "TCP"
```

## 추가 설명
- YAML은 들여쓰기에 민감하므로 탭 대신 **스페이스**를 사용합니다.
- Kubernetes 매니페스트에서는 라벨(labels)과 셀렉터(selectors)가 매우 중요합니다.
- 배열/딕셔너리 구조를 정확히 맞추면 `kubectl apply` 시 검증 오류를 줄일 수 있습니다.

# Kubernetes 매니페스트에서 Labels & Selectors가 중요한 이유 (상세)

Kubernetes는 “리소스 간 연결(매칭)”을 **라벨(labels)** 과 **셀렉터(selectors)** 로 합니다.  
즉, 라벨은 **붙이는 태그(메타데이터)** 이고, 셀렉터는 **그 태그를 기준으로 대상을 고르는 규칙** 입니다.

---

## 1. Labels(라벨)이란?

- 리소스(Pod, Deployment, Service, Node, Namespace 등)에 붙이는 **key=value 형태의 메타데이터**
- 라벨은 Kubernetes가 **리소스를 분류/그룹화/검색** 하는 핵심 수단
- 라벨은 **사람(운영자)** 도 보고, **Kubernetes 컨트롤러** 도 봅니다.

### 1) 라벨의 특징
- **자유롭게 추가/수정 가능**(대부분의 리소스에서 가능)
- **조회/필터링/자동화**에 매우 유용  
  예: `kubectl get pods -l app=web`
- “이게 어떤 앱인지 / 어떤 환경인지 / 어떤 버전인지 / 어떤 팀 소속인지”를 설명하는 데 사용

### 2) 라벨과 혼동하기 쉬운 것: Annotations
- **Labels**: 선택/필터링(셀렉터) 대상이 될 수 있음 (인덱싱 대상)
- **Annotations**: 선택/필터링 목적이 아니라 **부가 메타데이터** 저장(예: 빌드 정보, 설명, 체크섬 등)

---

## 2. Selectors(셀렉터)란?

셀렉터는 “라벨이 이런 것들을 골라라”라는 **조건식** 입니다.  
대표적으로 아래 리소스들이 셀렉터를 사용해 “대상”을 선택합니다.

- **Service → Pod** (트래픽을 전달할 Pod를 선택)
- **Deployment/ReplicaSet → Pod** (관리할 Pod를 선택)
- **NetworkPolicy → Pod** (정책 적용 대상 Pod 선택)
- **HPA → Scale Target** (스케일 대상 리소스 지정)
- **Affinity/Anti-Affinity, TopologySpreadConstraints** 등 (노드/파드 배치 규칙에도 라벨 기반 선택이 사용됨)

---

## 3. Labels & Selectors가 “매우 중요”한 이유

### A) Service가 어떤 Pod로 트래픽을 보낼지 결정
Service는 셀렉터로 “엔드포인트(백엔드 Pod)”를 자동 구성합니다.

- 셀렉터가 맞으면 → Endpoints/EndpointSlice에 Pod IP가 등록 → 트래픽 전달
- 셀렉터가 틀리면 → 엔드포인트가 비어있음 → **서비스는 존재하지만 접속하면 실패**

✅ 확인 명령:
```bash
kubectl get svc -n <ns> <svc-name> -o yaml
kubectl get endpoints -n <ns> <svc-name>
kubectl get endpointslices -n <ns> -l kubernetes.io/service-name=<svc-name>
```

### B) Deployment/ReplicaSet이 관리할 Pod를 식별
Deployment는 ReplicaSet을 만들고, ReplicaSet은 셀렉터로 “내가 관리할 Pod”를 식별합니다.

- 셀렉터와 Pod 라벨이 맞지 않으면 → Pod를 “내 것”으로 인식 못함 → 기대한 복제/롤링업데이트 실패
- 셀렉터가 너무 넓으면 → 다른 Pod까지 관리 대상으로 잡을 위험(매우 위험)

> **Deployment의 selector는 생성 후 변경이 거의 불가능(사실상 immutable)** 로 보는 게 안전합니다.  
> 잘못 만들면 재생성(새 Deployment)으로 해결해야 하는 경우가 많습니다.

### C) 운영/모니터링/배포 자동화의 기준
라벨은 “현장 운영 자동화”에서 표준 키로 쓰입니다.

- `app`, `component`, `tier`, `env`, `version`, `team` 같은 라벨은
  - 대시보드/로그/모니터링(예: Prometheus 라벨링, 로그 필터링)
  - 배포 전략(예: canary, blue/green)
  - 비용/소유권(팀별 비용 추적)
  - 접근 제어(네임스페이스/정책)
  에 다 연결됩니다.

---

## 4. 흔한 라벨 설계 예시(권장)

실무에서 자주 쓰는 패턴은 “Kubernetes 권장 레이블(Recommended Labels)” 스타일입니다.

예시:
- `app.kubernetes.io/name`: 애플리케이션 이름
- `app.kubernetes.io/instance`: 인스턴스(릴리즈/배포 단위)
- `app.kubernetes.io/component`: 구성요소(backend, frontend, worker 등)
- `app.kubernetes.io/part-of`: 상위 시스템/제품
- `app.kubernetes.io/version`: 버전
- `app.kubernetes.io/managed-by`: Helm, ArgoCD 등

추가로 자주 쓰는 커스텀 라벨:
- `env`: dev/stage/prod
- `team`: 소유 팀
- `tier`: frontend/backend/db 등

---

## 5. Selector 종류와 매칭 방식

### 1) matchLabels (가장 흔함)
정확히 일치하는 key=value 집합을 매칭합니다.

```yaml
selector:
  matchLabels:
    app: web
    env: prod
```

### 2) matchExpressions (조건식)
더 정교한 조건을 표현할 수 있습니다.

```yaml
selector:
  matchExpressions:
    - key: env
      operator: In
      values: ["prod", "stage"]
    - key: tier
      operator: NotIn
      values: ["db"]
```

지원되는 operator 예:
- `In`, `NotIn`
- `Exists`, `DoesNotExist`

---

## 6. “정상 동작”을 위한 핵심 규칙(실무 체크리스트)

### 규칙 1) Pod 템플릿 라벨과 컨트롤러 셀렉터는 반드시 일치
Deployment(ReplicaSet)가 만드는 Pod 라벨이 selector와 맞아야 합니다.

✅ 안전 패턴:
- `spec.selector.matchLabels` 값이 `spec.template.metadata.labels`에 **포함**되어야 함
- 보통은 **완전히 동일하게 유지**하는 것이 가장 안전

### 규칙 2) Service selector는 “대상 Pod만” 정확히 잡아야 한다
- 너무 좁으면: 서비스 엔드포인트 0개
- 너무 넓으면: 의도치 않은 Pod까지 포함(보안/장애 위험)

### 규칙 3) 라벨은 “불변 ID” vs “가변 상태”를 구분
- **불변(Identity)**: `app`, `component`, `team`, `part-of` 등
- **가변(State/Version)**: `version`, `track=canary`, `release` 등  
  → 가변 라벨을 셀렉터에 쓰면, 배포/롤백 시 매칭이 끊길 수 있습니다.

### 규칙 4) 이름은 다르지만 라벨은 같아도 된다
Pod 이름은 바뀌어도(ReplicaSet hash) 라벨이 같으면 셀렉터로 계속 매칭됩니다.  
Kubernetes가 “동적 객체”를 안정적으로 붙잡는 방식이 라벨/셀렉터입니다.

---

## 7. 대표 시나리오별 예시

### (1) Deployment + Service의 정석 패턴

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: demo
  labels:
    app: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:1.27-alpine
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: demo
spec:
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

#### 무엇이 연결되는가?
- Deployment.selector(app=web) → “내가 관리할 Pod 선택”
- Service.selector(app=web) → “트래픽 보낼 Pod 선택”
- 둘 다 **Pod의 라벨(app=web)** 을 기준으로 동작

---

### (2) canary(카나리) 배포에서 라벨을 활용하는 패턴

#### 방법 A: Service는 안정 트래픽만(안전)
- stable 파드만 잡는 서비스, canary는 별도 서비스/Ingress로 분리

```yaml
# stable
labels: { app: web, track: stable }
# canary
labels: { app: web, track: canary }
```

Service selector를 `app=web, track=stable`로 하면 canary를 포함하지 않습니다.

#### 방법 B: 일부 트래픽을 canary로 분산(고급)
- Ingress/Service Mesh(예: Istio) 등에서 라벨/subset 기반 라우팅을 사용

---

## 8. 자주 발생하는 장애/실수 패턴

### 1) Service는 있는데 접속이 안 됨
- 원인: Service selector가 Pod 라벨과 불일치
- 결과: Endpoints 0개

✅ 빠른 확인:
```bash
kubectl get pods -n <ns> --show-labels
kubectl describe svc -n <ns> <svc-name>
kubectl get endpoints -n <ns> <svc-name>
```

### 2) Deployment가 Pod를 “안 관리”하는 것처럼 보임
- 원인: Deployment selector와 template.labels 불일치
- 결과: ReplicaSet이 원하는 Pod를 매칭 못함 → scaling/rollout 이상

### 3) 너무 넓은 selector로 다른 Pod까지 잡음(최악)
- 예: `selector: app=web` 만 써서, 같은 app 라벨을 가진 다른 팀/다른 컴포넌트까지 서비스에 붙음
- 해결: `component`, `tier`, `env` 같은 라벨을 추가해 범위를 좁힘

---

## 9. 운영 팁: 라벨/셀렉터 점검 명령 모음

### 라벨 확인
```bash
kubectl get pod -n <ns> --show-labels
kubectl get pod -n <ns> -l app=web
kubectl get all -n <ns> -l app=web
```

### 셀렉터 확인(리소스 YAML)
```bash
kubectl get deploy -n <ns> <name> -o yaml | sed -n '1,200p'
kubectl get svc -n <ns> <name> -o yaml | sed -n '1,200p'
```

### 서비스 엔드포인트 확인
```bash
kubectl get endpoints -n <ns> <svc-name>
kubectl get endpointslices -n <ns> -l kubernetes.io/service-name=<svc-name>
```

---

## 10. 요약

- **Labels**: 리소스에 붙이는 key=value 태그 (분류/검색/운영 자동화의 기준)
- **Selectors**: 그 라벨을 기준으로 “대상을 고르는 규칙”
- Service/Deployment/NetworkPolicy 등 핵심 동작이 모두 “라벨 매칭”에 의존
- 셀렉터가 틀리면: **서비스가 있어도 트래픽이 못 가거나**, 컨트롤러가 Pod를 **관리하지 못하는 문제**가 생김
- 실무에선 라벨 체계를 표준화하고(규칙/컨벤션), 셀렉터 범위를 정확하게 설계하는 것이 매우 중요

---

원하시면, 지금 사용 중인 실습 YAML(Deployment/Service/Ingress 등)을 붙여주시면  
**라벨/셀렉터 설계가 안전한지 점검**하고 “현업 스타일”로 개선한 버전까지 만들어 드릴게요.

