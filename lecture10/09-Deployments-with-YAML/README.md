# YAML로 Deployment 만들기

## Step-01: ReplicaSet 템플릿 재사용
- ReplicaSet 템플릿을 복사해 `kind: Deployment`로 변경합니다.
- 컨테이너 이미지 버전을 `3.0.0`으로 업데이트합니다.
- NodePort Service의 `nodePort`를 `31233`으로 변경합니다.
- 이름 및 라벨/셀렉터를 `myapp3`로 통일합니다.

```
# Deployment 생성
kubectl apply -f 02-deployment-definition.yml
kubectl get deploy
kubectl get rs
kubectl get po

# NodePort Service 생성
kubectl apply -f 03-deployment-nodeport-service.yml

# Service 목록 확인
kubectl get svc

# Public IP 확인
kubectl get nodes -o wide

# 애플리케이션 접근
http://<Worker-Node-Public-IP>:31233
```

## API 레퍼런스
- **Deployment:** https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#deployment-v1-apps

## 추가 설명
- Deployment는 ReplicaSet을 자동으로 관리하며 롤링 업데이트를 제공합니다.
- 라벨/셀렉터 불일치는 Pod가 Service에 연결되지 않는 주요 원인입니다.
- 배포 전략을 명시하려면 `spec.strategy`로 RollingUpdate/Recreate를 지정할 수 있습니다.
