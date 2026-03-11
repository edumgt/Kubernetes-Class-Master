# Kubernetes 커리큘럼 (주제 통합형)

기존 `lecture01~lecture15` 구조를 제거하고, 유사 주제 기준으로 폴더를 통합했습니다.
유사 문서는 병합했고(통합본 표기), 중복 파일은 정리했습니다.

## 1) 환경 구축: `topic01_setup`
- [0. wsl_po wershell_docker_k8s_cheatsheet.md](topic01_setup/0.%20wsl_po%20wershell_docker_k8s_cheatsheet.md)
- [1. virtualbox.md](topic01_setup/1.%20virtualbox.md) (통합본)
- [2. k3s.md](topic01_setup/2.%20k3s.md) (통합본)
- [3. ssh.md](topic01_setup/3.%20ssh.md) (통합본)
- [8. Config.md](topic01_setup/8.%20Config.md)
- 실습: [00-Docker-Images](topic01_setup/practice/00-Docker-Images)

## 2) 코어 워크로드: `topic02_core_workloads`
- [7. Node_Pod.md](topic02_core_workloads/7.%20Node_Pod.md) (통합본)
- [9. k8s-labels-annotations.md](topic02_core_workloads/9.%20k8s-labels-annotations.md)
- 실습: [01-Kubernetes-Architecture](topic02_core_workloads/practice/01-Kubernetes-Architecture), [02-PODs-with-kubectl](topic02_core_workloads/practice/02-PODs-with-kubectl), [03-ReplicaSets-with-kubectl](topic02_core_workloads/practice/03-ReplicaSets-with-kubectl), [04-Deployments-with-kubectl](topic02_core_workloads/practice/04-Deployments-with-kubectl)

## 3) 대시보드/관측: `topic03_dashboard_observability`
- [4. dashboard.md](topic03_dashboard_observability/4.%20dashboard.md) (통합본)
- [4.1 4번의 결과에 대한 분석.md](topic03_dashboard_observability/4.1%204%EB%B2%88%EC%9D%98%20%EA%B2%B0%EA%B3%BC%EC%97%90%20%EB%8C%80%ED%95%9C%20%EB%B6%84%EC%84%9D.md)
- [5. re-connect.md](topic03_dashboard_observability/5.%20re-connect.md) (통합본)

## 4) 스케일링/안정성: `topic04_scaling_reliability`
- [6. AutoScaleUp_Test.md](topic04_scaling_reliability/6.%20AutoScaleUp_Test.md) (통합본)
- [6.1 6번 실행 후 후속 테스트.md](topic04_scaling_reliability/6.1%206%EB%B2%88%20%EC%8B%A4%ED%96%89%20%ED%9B%84%20%ED%9B%84%EC%86%8D%20%ED%85%8C%EC%8A%A4%ED%8A%B8.md)
- [7.2 LivenessProbe_Restart_Explanation.md](topic04_scaling_reliability/7.2%20LivenessProbe_Restart_Explanation.md)
- 실습: [06-YAML-Basics](topic04_scaling_reliability/practice/06-YAML-Basics), [07-PODs-with-YAML](topic04_scaling_reliability/practice/07-PODs-with-YAML), [08-ReplicaSets-with-YAML](topic04_scaling_reliability/practice/08-ReplicaSets-with-YAML), [09-Deployments-with-YAML](topic04_scaling_reliability/practice/09-Deployments-with-YAML), [10-Services-with-YAML](topic04_scaling_reliability/practice/10-Services-with-YAML)

## 5) 네트워크/Ingress: `topic05_network_ingress`
- [6.2 cp-node 간 설정문제 kubectl API 에 대해 좀더 확인.md](topic05_network_ingress/6.2%20cp-node%20%EA%B0%84%20%EC%84%A4%EC%A0%95%EB%AC%B8%EC%A0%9C%20kubectl%20API%20%EC%97%90%20%EB%8C%80%ED%95%B4%20%EC%A2%80%EB%8D%94%20%ED%99%95%EC%9D%B8.md)
- [6.4 k3s_node_internal_clusterip_summary.md](topic05_network_ingress/6.4%20k3s_node_internal_clusterip_summary.md)
- [7.1.1 k3s-traefik-ingress-routing-debug.md](topic05_network_ingress/7.1.1%20k3s-traefik-ingress-routing-debug.md) (통합본)
- 실습: [05-Services-with-kubectl](topic05_network_ingress/practice/05-Services-with-kubectl)

## 6) 트러블슈팅: `topic06_troubleshooting`
- [7.1 k3s-edu-labs-troubleshooting.md](topic06_troubleshooting/7.1%20k3s-edu-labs-troubleshooting.md) (통합본)

## 7) 참고 자료: `topic07_reference`
- [6.3 kubectl_linux_k8s_mix_cheatsheet.md](topic07_reference/6.3%20kubectl_linux_k8s_mix_cheatsheet.md)
- [7.5 k8s_k3s_glossary_lab.md](topic07_reference/7.5%20k8s_k3s_glossary_lab.md)
- [10. k8s-sandbox-sites.md](topic07_reference/10.%20k8s-sandbox-sites.md)

---

## 참고
- 루트의 `temp.history.md`는 학습 문서에서 제외합니다.
