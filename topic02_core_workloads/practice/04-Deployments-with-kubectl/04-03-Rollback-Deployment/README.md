# Deployment 롤백

## Step-00: 소개
- Deployment 롤백 방식
  - 이전 버전으로 롤백
  - 특정 버전으로 롤백

## Step-01: 이전 버전으로 롤백

### 롤아웃 히스토리 확인
```
# Deployment 롤아웃 히스토리
kubectl rollout history deployment/<Deployment-Name>
kubectl rollout history deployment/my-first-deployment
```

### 각 revision 변경 사항 확인
- **관찰 포인트:** "Annotations"와 "Image"를 비교해 변경 내용을 확인합니다.
```
# revision별 상세 히스토리 확인
kubectl rollout history deployment/my-first-deployment --revision=1
kubectl rollout history deployment/my-first-deployment --revision=2
kubectl rollout history deployment/my-first-deployment --revision=3
```

### 이전 버전으로 롤백
- **관찰 포인트:** 롤백 시 revision 번호가 증가합니다.
```
# Deployment 롤백
kubectl rollout undo deployment/my-first-deployment

# 롤아웃 히스토리 확인
kubectl rollout history deployment/my-first-deployment
```

### Deployment/Pod/ReplicaSet 확인
```
kubectl get deploy
kubectl get rs
kubectl get po
kubectl describe deploy my-first-deployment
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

## Step-02: 특정 revision으로 롤백

### 롤아웃 히스토리 확인
```
# Deployment 롤아웃 히스토리
kubectl rollout history deployment/<Deployment-Name>
kubectl rollout history deployment/my-first-deployment
```

### 특정 revision으로 롤백
```
# 특정 revision으로 롤백
kubectl rollout undo deployment/my-first-deployment --to-revision=3
```

### 히스토리 확인
- **관찰 포인트:** revision 번호가 증가하며 히스토리에 기록됩니다.
```
# Deployment 롤아웃 히스토리
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

## Step-03: 롤링 재시작
- 롤링 재시작은 기존 Pod를 순차적으로 종료하고 새 Pod를 생성합니다.
```
# 롤링 재시작
kubectl rollout restart deployment/<Deployment-Name>
kubectl rollout restart deployment/my-first-deployment

# Pod 목록 확인
kubectl get po
```

## 추가 설명
- 롤백은 잘못된 이미지 배포나 설정 오류 발생 시 빠른 복구를 지원합니다.
- 운영 환경에서는 롤백 전후 메트릭/로그 확인이 중요합니다.
- 잦은 롤백이 필요하다면 배포 전 자동화된 테스트와 헬스체크를 강화하는 것이 좋습니다.
