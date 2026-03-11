# Lecture 06 - Services with kubectl

## 학습 목표
- ClusterIP/NodePort Service 구성
- 프론트-백엔드 연결 및 라우팅 흐름 이해

## 실습 폴더
- [05-Services-with-kubectl](./05-Services-with-kubectl)

## 연계 이론 문서
- [6.4 k3s_node_internal_clusterip_summary.md](../topic05_network_ingress/6.4%20k3s_node_internal_clusterip_summary.md)
- [7.1.1 k3s-traefik-ingress-routing-debug.md](../topic05_network_ingress/7.1.1%20k3s-traefik-ingress-routing-debug.md)

## 권장 순서
1. Backend Deployment + ClusterIP 구성
2. Frontend Deployment + NodePort 구성
3. 스케일링 후 분산 동작 확인
