# Kubernetes - Deployment 생성/스케일링/노출

## Step-01: Deployment 소개
- **Deployment란?**
  - ReplicaSet을 선언형으로 관리하며 롤링 업데이트/롤백을 지원합니다.
- **Deployment로 할 수 있는 것**
  - ReplicaSet 생성 및 변경
  - Pod 복제 수 조절(스케일링)
  - Service로 노출하여 외부 접근 제공

## Step-02: Deployment 생성
- Deployment를 생성해 ReplicaSet을 롤아웃합니다.
- Deployment, ReplicaSet, Pod를 확인합니다.
- **Docker 이미지 위치:** https://hub.docker.com/repository/docker/stacksimplify/kubenginx
```
# Deployment 생성
kubectl create deployment <Deplyment-Name> --image=<Container-Image>
kubectl create deployment my-first-deployment --image=stacksimplify/kubenginx:1.0.0

# Deployment 확인
kubectl get deployments
kubectl get deploy

# Deployment 상세 확인
kubectl describe deployment <deployment-name>
kubectl describe deployment my-first-deployment

# ReplicaSet 확인
kubectl get rs

# Pod 확인
kubectl get po
```

## Step-03: Deployment 스케일링
- 복제 수를 늘리거나 줄여 트래픽 변화에 대응합니다.
```
# 스케일 업
kubectl scale --replicas=20 deployment/<Deployment-Name>
kubectl scale --replicas=20 deployment/my-first-deployment

# 상태 확인
kubectl get deploy
kubectl get rs
kubectl get po

# 스케일 다운
kubectl scale --replicas=10 deployment/my-first-deployment
kubectl get deploy
```

## Step-04: Deployment를 Service로 노출
- NodePort Service로 외부 접근을 가능하게 합니다.
```
# Deployment를 Service로 노출
kubectl expose deployment <Deployment-Name> --type=NodePort --port=80 --target-port=80 --name=<Service-Name-To-Be-Created>
kubectl expose deployment my-first-deployment --type=NodePort --port=80 --target-port=80 --name=my-first-deployment-service

# Service 정보 확인
kubectl get svc
Observation: 포트가 3으로 시작하는 값(예: 80:3xxxx/TCP)을 확인하세요.

# 워커 노드 Public IP 확인
kubectl get nodes -o wide
Observation: AWS EKS 환경에서는 EXTERNAL-IP를 확인하세요.
```
- **접근 예시**
```
http://<worker-node-public-ip>:<Node-Port>
```

## 추가 설명
- NodePort는 간단한 실습에 적합하지만, 운영에서는 LoadBalancer/Ingress 사용이 일반적입니다.
- 스케일링 시 ReplicaSet이 필요한 Pod 수를 자동으로 맞춰줍니다.
- 배포 후 `kubectl rollout status`로 상태를 확인하면 실패 원인을 빠르게 파악할 수 있습니다.
