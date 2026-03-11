# Deployment 일시정지(Pause) & 재개(Resume)

## Step-00: 소개
- **왜 Pause/Resume이 필요한가?**
  - 여러 변경 사항을 한 번에 적용하기 전에 배포를 잠시 멈춰 일괄 업데이트할 수 있습니다.
- 이 실습에서는 애플리케이션 버전을 **V3 -> V4**로 업데이트합니다.

## Step-01: Deployment 일시정지/재개

### 현재 Deployment/애플리케이션 상태 확인
```
# Deployment 롤아웃 히스토리 확인
kubectl rollout history deployment/my-first-deployment
Observation: 마지막 버전 번호를 기록해두세요.

# ReplicaSet 목록 확인
kubectl get rs
Observation: ReplicaSet 개수를 기록해두세요.

# 애플리케이션 접근
http://<worker-node-ip>:<Node-Port>
Observation: 현재 애플리케이션 버전을 확인하세요.
```

### Deployment 일시정지 후 변경 2가지 적용
```
# Deployment 일시정지
kubectl rollout pause deployment/<Deployment-Name>
kubectl rollout pause deployment/my-first-deployment

# 애플리케이션 버전 V3 -> V4 업데이트
kubectl set image deployment/my-first-deployment kubenginx=stacksimplify/kubenginx:4.0.0 --record=true

# 롤아웃 히스토리 확인
kubectl rollout history deployment/my-first-deployment
Observation: 새 롤아웃이 진행되지 않고 기존 버전 수가 유지되어야 합니다.

# ReplicaSet 확인
kubectl get rs
Observation: 새로운 ReplicaSet이 생성되지 않아야 합니다.

# 추가 변경: 리소스 제한 설정
kubectl set resources deployment/my-first-deployment -c=kubenginx --limits=cpu=20m,memory=30Mi
```

### Deployment 재개
```
# Deployment 재개
kubectl rollout resume deployment/my-first-deployment

# 롤아웃 히스토리 확인
kubectl rollout history deployment/my-first-deployment
Observation: 새 버전이 생성되어야 합니다.

# ReplicaSet 확인
kubectl get rs
Observation: 새 ReplicaSet이 생성되어야 합니다.
```

### 애플리케이션 접근
```
# 애플리케이션 접근
http://<node1-public-ip>:<Node-Port>
Observation: Application V4 버전이 보여야 합니다.
```

## Step-02: 정리(Clean-Up)
```
# Deployment 삭제
kubectl delete deployment my-first-deployment

# Service 삭제
kubectl delete svc my-first-deployment-service

# default 네임스페이스의 모든 객체 확인
kubectl get all
```

## 추가 설명
- Pause/Resume는 대규모 변경을 일괄 적용할 때 유용합니다.
- 여러 변경 사항을 적용한 뒤 Resume하면 한 번의 롤아웃으로 처리됩니다.
- Pause 상태에서 변경을 누적하면 실제 배포 시점과 변경 시점을 분리할 수 있습니다.
