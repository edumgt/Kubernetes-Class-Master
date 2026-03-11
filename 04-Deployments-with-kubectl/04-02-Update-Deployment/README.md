# Kubernetes - Deployment 업데이트

## Step-00: 소개
- Deployment 업데이트 방법 두 가지
  - `set image` 명령으로 이미지 변경
  - `kubectl edit`로 선언형 수정

## Step-01: "set image"로 V1 -> V2 업데이트

### Deployment 업데이트
- **관찰 포인트:** `spec.template.spec.containers[].name` 값을 확인해 `kubectl set image`에 사용합니다.
```
# 현재 Deployment의 컨테이너 이름 확인
kubectl get deployment my-first-deployment -o yaml

# Deployment 업데이트
kubectl set image deployment/<Deployment-Name> <Container-Name>=<Container-Image> --record=true
kubectl set image deployment/my-first-deployment kubenginx=stacksimplify/kubenginx:2.0.0 --record=true
```

### 롤아웃 상태 확인
- **관찰 포인트:** 기본적으로 롤링 업데이트이므로 다운타임 없이 배포됩니다.
```
# 롤아웃 상태 확인
kubectl rollout status deployment/my-first-deployment

# Deployment 확인
kubectl get deploy
```

### Deployment 상세 확인
- **관찰 포인트:** 이벤트(Event)에서 롤링 업데이트가 진행되는지 확인합니다.
```
# Deployment 상세 확인
kubectl describe deployment my-first-deployment
```

### ReplicaSet 확인
- **관찰 포인트:** 새 버전의 ReplicaSet이 생성됩니다.
```
# ReplicaSet 확인
kubectl get rs
```

### Pod 확인
- **관찰 포인트:** 새 ReplicaSet의 해시 라벨을 가진 Pod가 생성됩니다.
```
# Pod 목록 확인
kubectl get po
```

### 롤아웃 히스토리 확인
- **관찰 포인트:** 롤백 시 필요한 revision 정보가 기록됩니다.
```
# Deployment 롤아웃 히스토리 확인
kubectl rollout history deployment/<Deployment-Name>
kubectl rollout history deployment/my-first-deployment
```

### 애플리케이션 접근
- 브라우저에서 `Application Version:V2`가 표시되는지 확인합니다.
```
# NodePort 확인
kubectl get svc
Observation: 3으로 시작하는 포트(예: 80:3xxxx/TCP)를 확인하세요.

# 워커 노드 Public IP 확인
kubectl get nodes -o wide
Observation: AWS EKS 환경에서는 EXTERNAL-IP를 확인하세요.

# 애플리케이션 URL
http://<worker-node-public-ip>:<Node-Port>
```

## Step-02: "edit"로 V2 -> V3 업데이트

### Deployment 편집
```
# Deployment 편집
kubectl edit deployment/<Deployment-Name> --record=true
kubectl edit deployment/my-first-deployment --record=true
```

```yml
# 변경 전 2.0.0
    spec:
      containers:
      - image: stacksimplify/kubenginx:2.0.0

# 변경 후 3.0.0
    spec:
      containers:
      - image: stacksimplify/kubenginx:3.0.0
```

### 롤아웃 상태 확인
- **관찰 포인트:** 롤링 업데이트로 다운타임 없이 배포됩니다.
```
# 롤아웃 상태 확인
kubectl rollout status deployment/my-first-deployment
```

### ReplicaSet 확인
- **관찰 포인트:** 버전별 ReplicaSet이 추가되어 3개가 보일 수 있습니다.
```
# ReplicaSet/Pod 확인
kubectl get rs
kubectl get po
```

### 롤아웃 히스토리 확인
```
# Deployment 롤아웃 히스토리 확인
kubectl rollout history deployment/<Deployment-Name>
kubectl rollout history deployment/my-first-deployment
```

### 애플리케이션 접근
- 브라우저에서 `Application Version:V3`가 표시되는지 확인합니다.
```
# NodePort 확인
kubectl get svc
Observation: 3으로 시작하는 포트(예: 80:3xxxx/TCP)를 확인하세요.

# 워커 노드 Public IP 확인
kubectl get nodes -o wide
Observation: AWS EKS 환경에서는 EXTERNAL-IP를 확인하세요.

# 애플리케이션 URL
http://<worker-node-public-ip>:<Node-Port>
```

## 추가 설명
- `--record=true` 옵션은 변경 이력을 남겨 롤백 시 도움이 됩니다.
- 실제 운영에서는 `kubectl apply -f`를 통한 선언형 업데이트가 더 안전합니다.
- 업데이트 시 이미지 태그뿐 아니라 리소스 제한/환경 변수 변경도 함께 확인하는 것이 안전합니다.
