# Kubernetes 학습용 커리큘럼 (Lecture 01~15)

중복/유사 주제 문서는 같은 강의 폴더로 묶어 학습 흐름에 맞게 재배치했습니다.

## Lecture 01. 실습 환경 사전 개요
- [0. wsl_po wershell_docker_k8s_cheatsheet.md](lecture01/0.%20wsl_po%20wershell_docker_k8s_cheatsheet.md)

## Lecture 02. VirtualBox 기반 실습 환경 구축
- [1. virtualbox.md](lecture02/1.%20virtualbox.md)
- [1. virtualbox_hostonly_k8s_guide.md](lecture02/1.%20virtualbox_hostonly_k8s_guide.md)

## Lecture 03. K3s 멀티노드 클러스터 설치
- [2. k3s.md](lecture03/2.%20k3s.md)
- [2. k3s_multinode_hostonly_guide.md](lecture03/2.%20k3s_multinode_hostonly_guide.md)

## Lecture 04. SSH 접속 및 운영 기본
- [3. ssh.md](lecture04/3.%20ssh.md)
- [3. ssh_access_troubleshooting_guide.md](lecture04/3.%20ssh_access_troubleshooting_guide.md)

## Lecture 05. kubeconfig와 Context 이해
- [8. Config.md](lecture05/8.%20Config.md)

## Lecture 06. Ingress/Metrics/Dashboard 구성
- [4. dashboard.md](lecture06/4.%20dashboard.md)
- [4. k3s_ingress_metrics_dashboard_guide.md](lecture06/4.%20k3s_ingress_metrics_dashboard_guide.md)
- [4.1 4번의 결과에 대한 분석.md](lecture06/4.1%204%EB%B2%88%EC%9D%98%20%EA%B2%B0%EA%B3%BC%EC%97%90%20%EB%8C%80%ED%95%9C%20%EB%B6%84%EC%84%9D.md)

## Lecture 07. Dashboard 재접속/포트포워딩 복구
- [5. re-connect.md](lecture07/5.%20re-connect.md)
- [5. dashboard_reconnect_portforward_guide.md](lecture07/5.%20dashboard_reconnect_portforward_guide.md)

## Lecture 08. Node/Pod 핵심 개념과 상태
- [7. Node_Pod.md](lecture08/7.%20Node_Pod.md)
- [7.3 Kubernetes Pod 상태.md](lecture08/7.3%20Kubernetes%20Pod%20%EC%83%81%ED%83%9C.md)

## Lecture 09. Label/Annotation 메타데이터
- [9. k8s-labels-annotations.md](lecture09/9.%20k8s-labels-annotations.md)

## Lecture 10. HPA 오토스케일과 부하 테스트
- [6. AutoScaleUp_Test.md](lecture10/6.%20AutoScaleUp_Test.md)
- [6.5 fortio_k3s_notes.md](lecture10/6.5%20fortio_k3s_notes.md)

## Lecture 11. Manifest와 Probe 기반 안정성
- [6.1 6번 실행 후 후속 테스트.md](lecture11/6.1%206%EB%B2%88%20%EC%8B%A4%ED%96%89%20%ED%9B%84%20%ED%9B%84%EC%86%8D%20%ED%85%8C%EC%8A%A4%ED%8A%B8.md)
- [7.2 LivenessProbe_Restart_Explanation.md](lecture11/7.2%20LivenessProbe_Restart_Explanation.md)

## Lecture 12. 노드/클러스터 네트워크 내부 동작
- [6.4 k3s_node_internal_clusterip_summary.md](lecture12/6.4%20k3s_node_internal_clusterip_summary.md)
- [6.2 cp-node 간 설정문제 kubectl API 에 대해 좀더 확인.md](lecture12/6.2%20cp-node%20%EA%B0%84%20%EC%84%A4%EC%A0%95%EB%AC%B8%EC%A0%9C%20kubectl%20API%20%EC%97%90%20%EB%8C%80%ED%95%B4%20%EC%A2%80%EB%8D%94%20%ED%99%95%EC%9D%B8.md)

## Lecture 13. Ingress 라우팅 디버깅 실습
- [7.1.1 k3s-traefik-ingress-routing-debug.md](lecture13/7.1.1%20k3s-traefik-ingress-routing-debug.md)
- [7.1.2 test-local-apache-ingress.md](lecture13/7.1.2%20test-local-apache-ingress.md)

## Lecture 14. 종합 장애 분석 실습
- [7.1 k3s-edu-labs-troubleshooting.md](lecture14/7.1%20k3s-edu-labs-troubleshooting.md)
- [7.4 k8s_beginner_troubleshooting_playbook.md](lecture14/7.4%20k8s_beginner_troubleshooting_playbook.md)

## Lecture 15. 최종 치트시트/용어/샌드박스
- [6.3 kubectl_linux_k8s_mix_cheatsheet.md](lecture15/6.3%20kubectl_linux_k8s_mix_cheatsheet.md)
- [7.5 k8s_k3s_glossary_lab.md](lecture15/7.5%20k8s_k3s_glossary_lab.md)
- [10. k8s-sandbox-sites.md](lecture15/10.%20k8s-sandbox-sites.md)

---

## 참고
- 기존 루트의 `README.md`, `temp.history.md`는 학습 커리큘럼 본문에서 제외하고 루트에 유지했습니다.
