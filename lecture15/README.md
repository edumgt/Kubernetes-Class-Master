# Lecture 15 - Reference and Review

> 이 README는 lecture15 폴더의 개별 MD를 통합한 강의 노트입니다.

## 강의 목표
- kubectl/Linux 실전 명령 패턴 복습
- 핵심 용어와 샌드박스 실습 경로 정리

## 포함 문서
- 6.3 kubectl_linux_k8s_mix_cheatsheet.md
- 7.5 k8s_k3s_glossary_lab.md
- 10. k8s-sandbox-sites.md

## 권장 순서
1. 치트시트(6.3)로 명령 흐름 복습
2. 용어집(7.5)으로 개념 재정리
3. 샌드박스(10)에서 반복 연습

## 통합 문서 목록
- `10. k8s-sandbox-sites.md`
- `6.3 kubectl_linux_k8s_mix_cheatsheet.md`
- `7.5 k8s_k3s_glossary_lab.md`

---

# Kubernetes(k8s) kubectl 명령어 연습용 Sandbox 사이트 (2026-03-11 점검)

k8s `kubectl` 실습용 브라우저 환경을 실제 접속 기준으로 점검하고, 대체/신규 사이트를 보완했습니다.

## 기존 사이트 점검 결과

| 사이트 | 상태 | 메모 |
|---|---|---|
| Killercoda Kubernetes Playground | 정상(접속 가능) | 브라우저 JS 활성화 필요 |
| Play with Kubernetes (PWK) | 종료 예정 공지 확인 | 2026-03-01부터 unavailable 공지 |
| PWK Classroom | 접속 가능 | 워크숍 안내형 페이지, PWK 종료 영향 가능 |
| KodeKloud Free Labs (K8s) | 정상(접속 가능) | `Pods/ReplicaSets/Deployments/Services/YAML` 랩 확인 |
| KodeKloud Public Playgrounds | 정상(접속 가능) | 멀티노드 Playground 버전 선택 가능 |
| iximiuz Labs K8s Playgrounds | 정상(접속 가능) | kubeadm/k3s/k0s 등 다양한 클러스터 playground 제공 |
| GitHub Codespaces | 정상(접속 가능) | 전용 k8s playground는 아니며, 직접 kind/k3d 구성 방식 |

## 신규 발굴 사이트 (보완)

### 1) AWS EKS Workshop
- EKS 실습 가이드 + 브라우저 IDE 기반 워크숍 흐름
- 이벤트 환경 또는 개인 AWS 계정에서 진행 가능
- 주의: 개인 계정 경로는 비용 발생 가능

바로가기:
- https://www.eksworkshop.com/docs/introduction/setup/
- https://www.eksworkshop.com/docs/introduction/setup/your-account/

### 2) Google Cloud Skills Boost - Kubernetes Labs
- Kubernetes 카테고리 랩을 브라우저 기반으로 제공
- 실습형 가이드가 많은 편
- 주의: 과정별로 무료/유료/크레딧 정책이 다름

바로가기:
- https://www.cloudskillsboost.google/catalog?category=Containers

### 3) K8sGPT Playground (Killercoda 기반)
- 단순 kubectl 실습을 넘어 장애 분석/진단 시나리오까지 확장 가능
- Killercoda에서 K8sGPT CLI 시나리오 제공

바로가기:
- https://docs.k8sgpt.ai/tutorials/playground/

## 2026 기준 추천 우선순위
1. KodeKloud (Free Labs + Public Playgrounds)
2. Killercoda Kubernetes Playground
3. iximiuz Labs Kubernetes Playgrounds
4. (심화) AWS EKS Workshop / K8sGPT Playground

## 업데이트된 주소 모음

```text
[활성/권장]
Killercoda Kubernetes Playground: https://killercoda.com/playgrounds/scenario/kubernetes
KodeKloud Free Labs (K8s):       https://kodekloud.com/free-labs/kubernetes
KodeKloud Public Playgrounds:    https://kodekloud.com/public-playgrounds
iximiuz Labs K8s Playgrounds:    https://labs.iximiuz.com/playgrounds?category=kubernetes&filter=all
GitHub Codespaces:               https://github.com/features/codespaces
AWS EKS Workshop:                https://www.eksworkshop.com/docs/introduction/setup/
Google Skills Boost (K8s):       https://www.cloudskillsboost.google/catalog?category=Containers
K8sGPT Playground:               https://docs.k8sgpt.ai/tutorials/playground/

[상태 변경/참고]
Play with Kubernetes (PWK):      https://labs.play-with-k8s.com/  (2026-03-01부터 unavailable 공지)
PWK Classroom:                   https://training.play-with-kubernetes.com/
```
## kubectl + Linux 혼합 명령어 치트시트 (현장 패턴 정리)

> **핵심 요약**
- `kubectl ...`로 시작하면 **Kubernetes API(클러스터 리소스)**를 조회/조작하는 흐름이 시작됩니다.

- `kubectl exec POD -- <cmd>`에서 `--` **뒤의 `<cmd>`는 Linux 명령이지만 “컨테이너(파드) 내부”**에서 실행됩니다.
- 위의 내용은 6.2 에서 연습함.

- `| grep/awk/sed/sort/head/tail`, `$()`, 변수(`POD=...`)가 보이면 **Linux 쉘이 kubectl 출력(텍스트)을 가공** 중입니다.

---

## 1) “대상(리소스)”로 먼저 구분하기

### A. Linux 명령어(호스트/로컬 OS 대상)
```
`ls`, `cd`, `grep`, `awk`, `sed`, `tail`, `journalctl`, `systemctl`, `ps`, `curl`, `ssh`
```

---

# Linux 명령어 정리: `ls`, `cd`, `grep`, `awk`, `sed`, `tail`, `journalctl`, `systemctl`, `ps`, `curl`, `ssh`

> 목적: 현장에서 **자주 쓰는 리눅스 기본 명령어 11개**를 “무엇을 하는지 / 옵션 / 실전 예시 / 자주 하는 실수” 중심으로 정리했습니다.  
> 각 명령어는 `man <command>` 로 더 깊게 확인할 수 있습니다.

---

## 1) `ls` — 디렉터리/파일 목록 보기

### 하는 일
- 현재(또는 지정한) 디렉터리의 파일/디렉터리 목록을 출력합니다.

### 자주 쓰는 옵션
- `-l` : 자세히(권한/소유자/크기/시간)
- `-a` : 숨김 파일 포함(`.`로 시작)
- `-h` : 사람이 읽기 쉬운 크기(주로 `-l`과 함께)
- `-t` : 수정 시간 기준 정렬(최신 먼저)
- `-r` : 정렬 역순
- `-S` : 파일 크기 기준 정렬
- `-R` : 하위 디렉터리 재귀
- `--color=auto` : 타입별 색상 표시(배포판 기본 적용 많음)

### 실전 예시
```bash
ls
ls -l
ls -alh
ls -lt | head
ls -lhS
ls -al --time-style=long-iso
ls -R ./logs
```

### 팁/주의
- `ls -l`의 첫 글자: `d`(directory), `-`(file), `l`(symlink)
- 파일명에 공백이 있으면 파이프라인에서 예상과 다르게 처리될 수 있어 주의(스크립트에서는 `find -print0` + `xargs -0` 추천).

---

## 2) `cd` — 작업 디렉터리 이동

### 하는 일
- 현재 쉘의 작업 디렉터리를 변경합니다(프로세스 내부 상태 변화).

### 자주 쓰는 패턴
- `cd` : 홈 디렉터리로 이동
- `cd -` : 직전 디렉터리로 이동
- `cd ..` : 상위 디렉터리
- `cd ~user` : 특정 사용자 홈으로 이동(권한/존재 여부에 따라 실패 가능)

### 실전 예시
```bash
cd /var/log
cd ..
cd ~
cd -
cd ~/projects/myapp
```

### 팁/주의
- 스크립트에서 `cd` 실패 시 이후 명령이 엉뚱한 경로에서 실행될 수 있음 → `set -e` 또는 `cd ... || exit 1` 습관화.
- `pwd`로 현재 위치 확인.

---

## 3) `grep` — 텍스트 검색(라인 단위 매칭)

### 하는 일
- 파일/표준입력에서 **패턴(정규식/문자열)**을 찾아 매칭되는 줄을 출력합니다.

### 자주 쓰는 옵션
- `-n` : 라인 번호 표시
- `-i` : 대소문자 무시
- `-r` / `-R` : 디렉터리 재귀 검색(`-R`은 심볼릭 링크도 따라감)
- `-E` : 확장 정규식(Egrep 스타일) 사용
- `-F` : 정규식이 아닌 “고정 문자열”로 검색(빠르고 안전)
- `-v` : 매칭되지 않는 줄 출력(반전)
- `-w` : 단어 단위 매칭
- `-o` : 매칭된 부분만 출력
- `-C 3` / `-A 3` / `-B 3` : 문맥 출력(앞뒤 줄)
- `--line-buffered` : 파이프에서 즉시 출력(실시간 로그에서 유용)

### 실전 예시
```bash
# 파일에서 에러 라인 찾기
grep -n "ERROR" app.log

# 여러 파일에서 대소문자 무시 검색
grep -Rin "timeout" ./configs

# 정규식(확장)로 여러 패턴
grep -E "ERROR|WARN" app.log

# 고정 문자열로 안전 검색(정규식 특수문자 포함될 때)
grep -F "[INFO]" app.log

# 특정 단어만(예: "cat"이 "catch"에 걸리지 않도록)
grep -w "cat" words.txt

# 제외(노이즈 제거)
grep -v "healthcheck" access.log
```

### 팁/주의
- `[` `.` `*` `?` 같은 문자가 포함된 검색어는 기본적으로 정규식으로 해석됨 → 그냥 찾고 싶으면 `-F` 사용.
- 바이너리 파일/권한 문제로 에러가 나면 `2>/dev/null`로 stderr를 별도 처리할 수 있음.

---

## 4) `awk` — 텍스트 처리(필드 기반)

### 하는 일
- 줄을 읽어 **필드(기본 공백 구분)**로 나누고, 조건/연산/출력을 수행하는 강력한 텍스트 처리기입니다.

### 핵심 개념
- `$0` : 전체 줄
- `$1`, `$2`, … : 1번째/2번째 필드
- `FS` : 입력 필드 구분자(기본 공백), `-F`로 지정 가능
- `NR` : 현재 레코드(줄) 번호
- `NF` : 현재 줄의 필드 개수
- `BEGIN {}` : 처리 시작 전 1회 실행
- `{}` : 각 줄마다 실행
- `END {}` : 처리 종료 후 1회 실행

### 실전 예시
```bash
# 1) 특정 컬럼 출력
awk '{print $1, $3}' file.txt

# 2) 콤마 CSV에서 2번째 필드만
awk -F, '{print $2}' data.csv

# 3) 조건 필터링(3번째 컬럼이 500 이상)
awk '$3 >= 500 {print}' metrics.txt

# 4) 합계/평균
awk '{sum += $3} END {print "sum=", sum, "avg=", sum/NR}' metrics.txt

# 5) 헤더 출력 + 서식 지정
awk 'BEGIN{printf "%-20s %s\n", "USER", "PID"} {printf "%-20s %s\n", $1, $2}' ps.out
```

### 팁/주의
- 공백이 “연속 공백”이어도 기본 FS는 잘 처리하지만, 탭/다른 구분자면 `-F '\t'` 또는 `-F:` 등 명시.
- 복잡해지면 스크립트 파일로 분리(`awk -f script.awk input`).

---

## 5) `sed` — 스트림 편집기(치환/삭제/추출)

### 하는 일
- 입력 스트림을 받아 **라인 단위로 편집**(치환, 삭제, 특정 줄만 출력 등)합니다.

### 자주 쓰는 옵션/명령
- `s/OLD/NEW/` : 치환
- `g` : 한 줄에서 전체 치환(기본은 첫 번째만)
- `-n` : 기본 출력 끄고 `p` 명령으로 필요한 것만 출력
- `p` : 출력(print)
- `d` : 삭제(delete)
- `-i` : 파일을 직접 수정(in-place)  
  - GNU sed: `-i` 가능, macOS(BSD sed): `-i ''` 필요

### 실전 예시
```bash
# 1) 한 줄에서 첫 매칭만 치환
sed 's/http/https/' urls.txt

# 2) 한 줄에서 전체 치환
sed 's/http/https/g' urls.txt

# 3) 특정 줄 범위만 출력(10~20줄)
sed -n '10,20p' file.txt

# 4) 특정 패턴 포함 줄 삭제
sed '/DEBUG/d' app.log

# 5) 파일 직접 수정(주의!)
sed -i 's/old_value/new_value/g' config.ini
```

### 팁/주의
- `/`가 포함된 문자열(경로 등) 치환 시 구분자를 바꾸면 편함:
```bash
sed 's|/var/www|/srv/www|g' paths.txt
```
- `-i`는 되돌리기 어렵습니다 → 백업 옵션(`-i.bak`) 사용 권장:
```bash
sed -i.bak 's/foo/bar/g' file.txt
```

---

## 6) `tail` — 파일 끝부분 보기/실시간 팔로우

### 하는 일
- 파일의 마지막 N줄을 출력하거나, 로그를 **실시간으로 따라가며(follow)** 출력합니다.

### 자주 쓰는 옵션
- `-n 200` : 마지막 200줄
- `-f` : 추가되는 내용을 계속 출력
- `-F` : `-f` + 파일 교체(로그 로테이션)에도 계속 추적
- `--pid=<PID>` : 해당 PID가 종료되면 tail도 종료(GNU coreutils)

### 실전 예시
```bash
tail -n 50 /var/log/syslog
tail -f /var/log/nginx/access.log
tail -F /var/log/nginx/access.log

# 실시간 tail + 필터(버퍼링 주의)
tail -F app.log | grep --line-buffered -i error
```

### 팁/주의
- 로그 로테이션이 있는 파일은 보통 `-F`가 안전합니다.
- `tail -f`는 끊을 때 `Ctrl + C`.

---

## 7) `journalctl` — systemd 저널 로그 조회

```
systemd는 리눅스에서 부팅부터 서비스(데몬) 관리까지 담당하는 “초기화(init) + 서비스 관리자”예요. Ubuntu 22.04도 기본이 systemd입니다.

1) systemd가 하는 일

부팅 시 서비스 시작 순서/의존성 관리

프로세스(서비스) 시작/중지/재시작, 자동재시작

로그 수집(journald)

타이머(cron 대체 가능), 마운트/네트워크 등 “시스템 상태”를 단위(Unit)로 관리

2) systemd의 핵심 개념: Unit(유닛)

systemd는 모든 걸 Unit 파일로 다룹니다.

자주 보는 타입:

service : 서비스(예: k3s.service, k3s-agent.service)

socket : 소켓 활성화(요청 오면 서비스 띄움)

timer : 스케줄러(예: 매일/매시간 실행)

mount : 마운트

target : “상태/단계” 묶음(예: multi-user.target)

Unit 파일 위치(대표):

/etc/systemd/system/ (관리자가 만든/수정한 것 우선)

/lib/systemd/system/ (패키지 기본 제공)

3) 서비스 관리 명령(실전에서 가장 많이 씀)
상태/로그
sudo systemctl status k3s
sudo journalctl -u k3s -n 200 --no-pager

시작/중지/재시작
sudo systemctl start k3s
sudo systemctl stop k3s
sudo systemctl restart k3s

부팅 시 자동 시작(enable)
sudo systemctl enable --now k3s-agent   # enable + 즉시 시작
sudo systemctl disable k3s-agent        # 부팅 자동 시작 해제

4) systemd가 “의존성/순서”를 잡는 방식(간단히)

Unit 파일 안에 이런 키워드가 들어갑니다.

After=network-online.target : 네트워크 준비된 뒤 시작

Wants=... / Requires=... : 같이 띄우거나(약/강 의존)

Restart=always : 죽으면 다시 살림

그래서 k3s 같은 데몬도 systemd가 “서비스로” 관리하면서, 죽으면 재시작하고 부팅 때 자동으로 올려줍니다.

5) 너 상황(k3s)에서 systemd가 왜 중요?

워커가 NotReady일 때, 대부분 워커에서 k3s-agent.service가 죽었거나 cp1에 붙지 못한 상태라서

아래 2개로 바로 원인 파악합니다:

sudo systemctl status k3s-agent
sudo journalctl -u k3s-agent -n 200 --no-pager
```

### 하는 일
- systemd 기반 시스템에서 **저널(journald)** 로그를 조회합니다.

### 자주 쓰는 옵션
- `-u <unit>` : 특정 서비스(unit)만 보기
- `-b` : 부팅 기준(현재 부팅)
- `-k` : 커널 로그만
- `-f` : 실시간 follow
- `-n 200` : 마지막 200줄
- `--since "2026-01-24 09:00"` / `--until ...` : 시간 범위
- `-p err` : 우선순위 필터(예: `emerg|alert|crit|err|warning|notice|info|debug`)
- `-o cat` : 포맷 간소화(메시지 본문 위주)
- `--no-pager` : 페이저(less) 없이 출력

### 실전 예시
```bash
# 전체 로그(최근)
journalctl -n 200 --no-pager

# 특정 서비스(k3s, nginx, docker 등)
journalctl -u k3s -n 200 --no-pager
journalctl -u ssh -n 200 --no-pager

# 부팅 이후 로그
journalctl -b -n 200

# 오늘 오전 9시 이후의 에러만
journalctl --since "today 09:00" -p err --no-pager

# 실시간 모니터링
journalctl -u k3s -f
```

### 팁/주의
- 권한이 필요할 수 있습니다: `sudo journalctl ...`
- 저널 보관 정책은 `/etc/systemd/journald.conf`에 의해 달라집니다(디스크 제한/영구 보관 등).

---

## 8) `systemctl` — systemd 서비스/유닛 관리

### 하는 일
- systemd의 유닛(서비스, 타이머, 소켓 등)을 조회/시작/중지/재시작/자동실행 설정합니다.

### 자주 쓰는 명령
- 상태 확인: `systemctl status <unit>`
- 시작/중지/재시작: `start|stop|restart`
- 설정 다시 읽기: `daemon-reload` (유닛 파일 수정 후)
- 자동 시작: `enable|disable`
- 부팅 시 즉시 적용 포함: `enable --now`
- 전체 유닛 보기: `systemctl list-units --type=service`
- 실패한 것만: `systemctl --failed`

### 실전 예시
```bash
# 상태 확인
systemctl status k3s
```
```
ubuntu@cp1:~$ systemctl status k3s
● k3s.service - Lightweight Kubernetes
     Loaded: loaded (/etc/systemd/system/k3s.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2026-01-03 02:08:48 UTC; 3 weeks 2 days ago
       Docs: https://k3s.io
    Process: 1855 ExecStartPre=/sbin/modprobe br_netfilter (code=exited, status=0/SUCCESS)
    Process: 1860 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
   Main PID: 1864 (k3s-server)
      Tasks: 277
     Memory: 1.9G
        CPU: 1h 41min 20.766s
     CGroup: /system.slice/k3s.service
             ├─ 1864 "/usr/local/bin/k3s server" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""
             ├─ 1955 "containerd

             이하 생략
```
```
systemctl status nginx

# 재시작
sudo systemctl restart nginx

# 부팅 시 자동 시작 설정 + 즉시 시작
sudo systemctl enable --now docker

# 유닛 파일 수정 후 반영
sudo systemctl daemon-reload
sudo systemctl restart myapp.service

# 실패한 서비스 확인
systemctl --failed
```

### 팁/주의
- 서비스명은 보통 `nginx.service`인데 `.service`는 생략 가능.


---

## 9) `ps` — 프로세스 목록/상태 확인

### 하는 일
- 현재 시스템에서 실행 중인 프로세스 정보를 출력합니다.

### 자주 쓰는 옵션/조합
- `ps aux` : BSD 스타일 전체 목록(리눅스에서 흔히 사용)
- `ps -ef` : SysV 스타일 전체 목록(리눅스에서 흔히 사용)
- `ps -p <pid> -o ...` : 특정 PID의 원하는 컬럼만 출력
- `--sort=-%cpu` : CPU 사용량으로 정렬(내림차순)

### 컬럼 자주 보는 것
- `PID` : 프로세스 ID
- `%CPU`, `%MEM` : 사용률
- `RSS` : 실제 메모리 사용(Resident Set Size)
- `STAT` : 상태(예: `R` 실행, `S` 슬립, `D` I/O 대기, `Z` 좀비)
- `COMMAND` : 실행 명령

### 실전 예시
```bash
# 전체 목록
ps aux | head
ps -ef | head

# 특정 프로세스 찾기(패턴 검색)
ps aux | grep -i nginx

# CPU 많이 쓰는 순
ps aux --sort=-%cpu | head

# 특정 PID 상세
ps -p 1234 -o pid,ppid,user,%cpu,%mem,etime,cmd
```

### 팁/주의
- `ps aux | grep nginx`는 grep 프로세스 자신도 걸릴 수 있음:
```bash
ps aux | grep -i '[n]ginx'
```

---

## 10) `curl` — HTTP(S) 요청/테스트/다운로드

### 하는 일
- URL로 요청을 보내고 응답을 출력/저장하는 도구(REST API 테스트에도 매우 흔함).

### 자주 쓰는 옵션
- `-I` : 헤더만(HEAD 요청)
- `-i` : 응답 헤더 + 바디 함께 출력
- `-v` : 상세 로그(디버깅)
- `-sS` : 조용히(`-s`) 하되 에러는 표시(`-S`)
- `-L` : 리다이렉트 따라가기
- `-o file` : 파일로 저장
- `-O` : 원래 파일명으로 저장
- `-X METHOD` : HTTP 메서드 지정(GET/POST/PUT/DELETE…)
- `-H` : 헤더 추가
- `-d` : 바디 데이터 전송(POST/PUT 등에 사용)
- `--connect-timeout`, `--max-time` : 타임아웃

### 실전 예시
```bash
# 단순 GET
curl http://example.com

# 헤더만 보기
curl -I https://example.com

# JSON API 호출(헤더 + 바디)
curl -sS -H "Accept: application/json" https://api.example.com/health | jq .

# POST JSON
curl -sS -X POST https://api.example.com/items \
  -H "Content-Type: application/json" \
  -d '{"name":"apple","qty":3}'

# 파일 다운로드
curl -L -o file.zip https://example.com/file.zip

# 연결/응답 타임아웃
curl --connect-timeout 3 --max-time 10 https://example.com
```

### 팁/주의
- HTTPS 인증서 문제 테스트(임시): `-k`(보안상 위험, 개발/검증용으로만)
- API 디버깅은 `-v`가 유용하지만 민감정보(토큰 등)가 노출될 수 있으니 주의.

---

## 11) `ssh` — 원격 서버 접속/명령 실행/포트 포워딩

### 하는 일
- 안전한 채널로 원격 서버에 접속하거나 원격 명령을 실행합니다(SCP/SFTP와 함께 사용 빈도 높음).

### 자주 쓰는 옵션
- `user@host` : 접속 대상(사용자 생략 시 현재 사용자)
- `-p <port>` : 포트 지정(기본 22)
- `-i <keyfile>` : 개인키 지정
- `-o ...` : 옵션 직접 지정(예: StrictHostKeyChecking)
- `-L local:host:remote` : 로컬 포트 포워딩(로컬 → 원격)
- `-R remote:host:local` : 리버스 포워딩(원격 → 로컬)
- `-J jump` : 점프 호스트(바스천) 경유
- `-T` : pseudo-tty 비활성(스크립트용)
- `-t` : tty 강제(원격에서 상호작용 명령 필요할 때)

### 실전 예시
```bash
# 기본 접속
ssh ubuntu@192.168.56.10

# 포트 지정
ssh -p 2222 ubuntu@host

# 키 파일 지정
ssh -i ~/.ssh/id_ed25519 ubuntu@host

# 원격에서 명령 1회 실행
ssh ubuntu@host "uname -a && df -h"

# 로컬 포트 포워딩(로컬 8080 -> 원격 127.0.0.1:80)
ssh -L 8080:127.0.0.1:80 ubuntu@host

# 점프 호스트(바스천) 경유
ssh -J ubuntu@bastion ubuntu@private-host
```

### 팁/주의
- “REMOTE HOST IDENTIFICATION HAS CHANGED!” 경고는 **호스트키가 바뀌었거나 MITM 가능성**을 의미 → 확실히 서버 재설치 등으로 변경된 것이 맞을 때만 `known_hosts` 정리.
- 서버마다 옵션을 고정하려면 `~/.ssh/config` 사용:
```sshconfig
Host mylab
  HostName 192.168.56.10
  User ubuntu
  IdentityFile ~/.ssh/id_ed25519
  Port 22
```

---

# 빠른 치트시트(현장 조합)

```bash
# 최근 에러 로그 빠르게 보기(시스템 서비스)
sudo journalctl -u nginx -n 200 --no-pager | grep -i error

# 실시간 로그 + 키워드 필터
sudo journalctl -u k3s -f | grep --line-buffered -i "warn\|error"

# 특정 프로세스/포트 디버깅(프로세스 찾기)
ps aux | grep -i '[n]ginx'

# HTTP 헬스체크
curl -sS -I http://localhost:8080

# SSH로 원격에서 로그 조회
ssh ubuntu@host "sudo journalctl -u k3s -n 100 --no-pager"
```

---

## 참고
- 각 명령의 상세 옵션: `man ls`, `man grep`, `man awk`, `man sed`, `man tail`, `man journalctl`, `man systemctl`, `man ps`, `man curl`, `man ssh`
- 도움말: `command --help` (예: `grep --help`)

---

### B. Kubernetes 명령어(k8s API 대상)
`kubectl get/describe/logs/exec/apply/delete/top ...`
- **클러스터 리소스(Pod/Service/Deployment/Node 등)**를 다룸  
- `kubectl`은 결국 **API Server에 요청**을 보냅니다.

### C. 컨테이너 안(Linux이지만 Pod 내부) 대상
예: `kubectl exec POD -- ls /var/log`
- `exec` 뒤의 명령은 **Pod 내부 Linux**
- 헷갈리기 쉬운 포인트: **명령은 Linux인데, 실행 “대상”이 Pod 내부**
---
```
ubuntu@w2:~$ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
my-first-pod             1/1     Running   0          5h19m
nginx-66686b6766-7x2d9   1/1     Running   0          21d
nginx-66686b6766-d4xtt   1/1     Running   0          14d
nginx-66686b6766-frj65   1/1     Running   0          13d
whoami-b85fc56b4-fk6p4   1/1     Running   0          13d

ubuntu@w2:~$ kubectl exec my-first-pod -- ls /var/log
apt
btmp
dpkg.log
faillog
lastlog
nginx
wtmp
```

---

## 2) 가장 흔한 혼합 패턴: “kubectl 출력”을 Linux 파이프로 가공

### 예시 A) Running Pod만 보기
```sh
kubectl get pods -n demo | grep Running
```
- **k8s:** `kubectl get pods -n demo`
- **Linux:** `| grep Running`
- 의미: k8s에서 목록을 가져오고 → Linux 도구로 텍스트 필터링

### 예시 B) 특정 컬럼만 뽑기
```sh
kubectl get pods -n demo -o wide | awk '{print $1, $6, $7}'
```
- **k8s:** `kubectl get ...`
- **Linux:** `awk ...`
- 의미: “가져오기(k8s)” + “가공(Linux 텍스트 처리)”

> **팁:** 가능하면 `-o jsonpath=...` / `-o go-template=...`처럼 **kubectl 출력 옵션으로 구조적으로 뽑는 방식이 더 안전**합니다.

---

## 3) “호스트 Linux” vs “Pod 내부 Linux” 섞어 쓰기

### 예시 C) 호스트에서 실행(내 서버)
```sh
tail -n 50 /var/log/syslog
```
- **전부 Linux(호스트)**

### 예시 D) Pod 안에서 실행(컨테이너 내부 Linux)
```sh
kubectl exec -n demo mypod -- tail -n 50 /var/log/nginx/access.log
```
- **k8s:** `kubectl exec -n demo mypod --`
- **Linux(컨테이너 내부):** `tail -n 50 ...`

> **구분 포인트:** `kubectl exec POD --` 뒤는 Linux 명령이지만 **호스트가 아니라 Pod 내부**에서 실행됩니다.

---

## 4) “kubectl 결과를 변수로 받아” Linux 흐름에서 재사용

### 예시 E) 첫 번째 Pod 이름을 가져와서 로그 보기
```sh
POD=$(kubectl get pods -n demo -l app=nginx -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n demo "$POD" | tail -n 50
```
- **Linux:** `POD=$( ... )` (쉘 변수/커맨드 치환)
- **k8s:** `kubectl get ...`
- **k8s:** `kubectl logs ...`
- **Linux:** `| tail -n 50`

---

## 5) “리소스 상태 파악 + 원인 분석” 혼합 대표 흐름

### 예시 F) CrashLoopBackOff Pod 찾고, 이벤트/로그 확인
```sh
kubectl get pods -n demo | egrep 'CrashLoopBackOff|Error'
kubectl describe pod -n demo <pod-name> | less
kubectl logs -n demo <pod-name> --previous | tail -n 100
```
- **k8s:** `kubectl get/describe/logs`
- **Linux:** `egrep`, `less`, `tail`
- 의미: k8s 정보 수집 후 → Linux 도구로 읽기/검색/요약

---

## 6) Node(리눅스) 문제와 Pod 문제를 같이 볼 때

### 예시 G) Node 상태 확인(k8s) + 노드 OS 로그 보기(Linux)
```sh
kubectl get nodes -o wide
kubectl describe node <node-name> | egrep 'Conditions|Ready|Pressure'
ssh <node-ip> "sudo journalctl -u kubelet -n 200 --no-pager"
```
- **k8s:** `kubectl get/describe`
- **Linux:** `egrep`
- **Linux(노드 OS):** `ssh ... journalctl ...`
- 의미: “클러스터 관점(k8s)”과 “노드 OS 관점(Linux)”을 교차 확인

---

## 7) 헷갈림 방지용 3줄 규칙

1. `kubectl`이 앞에 오면 **k8s 리소스 조회/조작**이 시작된다.  
2. `--` 뒤에 오는 명령은 **컨테이너 내부 Linux 명령**이다.  
3. `|`, `grep/awk/sed`, `$()`가 보이면 **Linux 쉘이 kubectl 출력(텍스트)을 가공** 중이다.

---

## 작업 흐름별 “혼합 명령어 세트” (Cheat Sheet)

- 아래는 현장에서 특히 많이 쓰는 4개 시나리오를 기준으로, 
- **kubectl(K8s) + Linux(쉘/텍스트/네트워크)**가 섞인 형태로 정리했습니다.

---

#### 이상 Pod 빠르게 찾기
```sh
kubectl get pod -A | egrep 'CrashLoopBackOff|Error|ImagePullBackOff|Pending|Evicted'
```
- **k8s:** `kubectl get pod -A`
- **Linux:** `egrep ...`

#### 이벤트/원인(스케줄링, 이미지, 볼륨 등) 확인
```sh
kubectl describe pod -n demo mypod | egrep -n 'Events|Warning|Failed|Back-off|OOM|Pull'
```
- **k8s:** `describe`
- **Linux:** `egrep -n`

#### 로그 확인(현재/이전 컨테이너)
```sh
kubectl logs -n demo mypod --tail=200
kubectl logs -n demo mypod --previous --tail=200 | tail -n 50
```
- **k8s:** `logs`
- **Linux:** `tail`(후처리)

#### Pod 내부에서 프로세스/파일 확인(컨테이너 내부 Linux)
```sh
kubectl exec -n demo mypod -- sh -lc "ps aux | head"
kubectl exec -n demo mypod -- sh -lc "ls -al /app && df -h"
```
- **k8s:** `exec ... --`
- **Linux(컨테이너 내부):** `ps/ls/df/head`

#### 리소스/메모리 압박(OOM) 의심 시(top + 정렬)
```sh
kubectl top pod -n demo | sort -k3 -hr | head
```
- **k8s:** `top pod`
- **Linux:** `sort/head`

#### 노드 레벨 확인(노드 상태 + kubelet 로그)
```sh
kubectl get node -o wide
kubectl describe node <node> | egrep -n 'Ready|Pressure|Disk|Memory|PID|Events'
ssh <node-ip> "sudo journalctl -u kubelet -n 200 --no-pager | tail -n 80"
```
- **k8s:** node 조회/describe
- **Linux:** `egrep`, `ssh/journalctl/tail`

---

#### Service/Endpoints - ep 가 실제로 붙었는지
```sh
kubectl get svc,ep -n demo -o wide
```
```
ubuntu@cp1:~$ kubectl get svc,ep -n demo -o wide
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/web-svc   ClusterIP   10.43.31.179   <none>        80/TCP    2d    app=web

NAME                ENDPOINTS                    AGE
endpoints/web-svc   10.42.1.8:80,10.42.2.14:80   2d
```
---
```
kubectl get ep -n demo my-svc -o yaml | egrep -n 'subsets|addresses|ports'
```
- **k8s:** `get svc,ep`, `get ep -o yaml`
- **Linux:** `egrep`

> **Endpoints가 비어있으면** 높은 확률로 `selector ↔ pod label` 불일치입니다.
```
Endpoints가 <none>(비어 있음) 이면, 실무에서 제일 많이 맞는 원인이 Service의 selector가 매칭되는 Pod가 “0개”인 것이고, 그중 대부분이 selector ↔ pod labels 불일치예요. 왜 그런지/어떻게 생기는지/어떻게 확정하는지까지 자세히 정리해볼게요.

1) Service selector와 Pod label이 뭐가 다른데?

Service는 “어떤 Pod들에게 트래픽을 보낼지”를 spec.selector로 정합니다.

Pod는 “내가 누구인지”를 metadata.labels로 표시합니다.

컨트롤러는 Service.spec.selector에 매칭되는 Pod들 중 Ready인 것을 찾아서 Endpoints(또는 EndpointSlice) 를 채웁니다.

즉, 공식은 이거예요:

Endpoints = (labels가 selector를 만족하는 Pod) ∩ (Ready Pod)

그래서 labels ⊄ selector면 (매칭 0개) Endpoints가 비어요.

2) “불일치”가 생기는 대표 패턴 (진짜 자주 나옴)
패턴 A) label 키/값 오타

Service selector: app=web

Pod label: app=wep 또는 apps=web

한 글자만 달라도 매칭 0개입니다.

패턴 B) Deployment/Pod 템플릿 라벨과 Service selector가 서로 다름

예를 들어 Deployment가:

template.labels: app=nginx

인데 Service는:

selector: app=web

이면 영원히 매칭이 안 됩니다.

패턴 C) 같은 app이지만 tier/version 등 추가 라벨 조건이 있음

Service selector가 여러 개면 AND 조건입니다.

Service selector: app=web, tier=frontend

Pod labels: app=web만 있음 (tier 없음)
→ 매칭 실패 (Endpoints 비어 있음)

패턴 D) Helm/템플릿에서 라벨 체계가 바뀜

예: 이전엔 app: web이었는데 Helm chart가
app.kubernetes.io/name: web 같은 “표준 라벨”로 바뀐 경우
Service selector가 예전 라벨을 보고 있으면 매칭 0개.

패턴 E) Namespace 착각

Service는 demo에 있는데

Pod는 default에 있음
→ 같은 클러스터여도 네임스페이스가 다르면 매칭이 안 됩니다. (Endpoints 비어 있음)

3) “Endpoints 비었는데 라벨은 맞는 것 같은데?”인 경우

selector가 맞아도 Endpoints가 비는 케이스가 있습니다.

케이스 1) Pod가 Ready가 아님

Pod는 Running이어도 readinessProbe 실패면 Endpoints에 안 들어갈 수 있어요.

kubectl get pod에서 READY 0/1 같은 상태

케이스 2) Service가 selector가 없는 타입(수동 백엔드)

예: selector 없는 Service(수동 Endpoints), ExternalName 등
이 경우 Endpoints가 자동으로 채워지지 않습니다.

4) “불일치인지”를 10초 만에 확정하는 방법
1) Service selector 확인
kubectl -n <ns> get svc <svc-name> -o jsonpath='{.spec.selector}{"\n"}'


또는 describe:

kubectl -n <ns> describe svc <svc-name>


여기서 Selector: 줄을 봅니다.

2) 그 selector로 Pod를 직접 조회해보기 (가장 확실)

예를 들어 selector가 app=web,tier=frontend면:

kubectl -n <ns> get pod -l app=web,tier=frontend -o wide


여기 결과가 0개면 → selector↔label 불일치 확정

결과가 있는데 Endpoints가 비면 → Ready/조건/정책 문제로 넘어갑니다.

3) Pod 라벨을 직접 확인
kubectl -n <ns> get pod <pod-name> --show-labels
# 또는
kubectl -n <ns> get pod <pod-name> -o jsonpath='{.metadata.labels}{"\n"}'

4) Endpoints 확인
kubectl -n <ns> get endpoints <svc-name> -o wide
# 최신: EndpointSlice
kubectl -n <ns> get endpointslice -l kubernetes.io/service-name=<svc-name>

5) 해결 방법(정석)

Service selector를 Pod 라벨에 맞춘다 (대부분 이게 안전)

또는 Pod(Deployment template.labels)를 Service selector에 맞춘다

현장에서는 보통:

“서비스 라우팅 기준이 되는 라벨(예: app=web)을 하나 정하고”

Deployment와 Service가 같은 라벨 세트를 공유하도록 관리합니다.
```
---
#### 오류 yaml - vi 로 mismatch-endpoints.yaml 만듭니다.
```
apiVersion: v1
kind: Namespace
metadata:
  name: demo
---
# ❌ Service selector는 app=web 인데,
# ✅ 실제 Pod(Deployment)는 app=nginx 라벨을 씀
# => 매칭되는 Pod가 0개라 Endpoints가 비게 됨
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: demo
spec:
  selector:
    app: web          # <-- 불일치 포인트(여기)
  ports:
    - name: http
      port: 80
      targetPort: 80
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx       # <-- Pod 라벨(app=nginx)
  template:
    metadata:
      labels:
        app: nginx     # <-- Pod 라벨(app=nginx)
    spec:
      containers:
        - name: nginx
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
```
---
```
ubuntu@cp1:~$ kubectl apply -f mismatch-endpoints.yaml
Warning: resource namespaces/demo is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
namespace/demo configured
service/web-svc configured
The Deployment "web" is invalid: spec.selector: Invalid value: {"matchLabels":{"app":"nginx"}}: field is immutable
```
---
#### 올바른 수정 버젼
```
apiVersion: v1
kind: Namespace
metadata:
  name: demo
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: demo
spec:
  selector:
    app: nginx        # ✅ 수정: Pod 라벨과 일치
  ports:
    - name: http
      port: 80
      targetPort: 80
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
```
---
```
ubuntu@cp1:~$ kubectl apply -f web.yaml
kubectl -n demo get pods -o wide
kubectl -n demo get endpoints web-svc -o wide
kubectl -n demo describe svc web-svc | egrep -n "Selector|Endpoints"
deployment.apps/web unchanged
service/web-svc configured
NAME                   READY   STATUS    RESTARTS   AGE   IP           NODE   NOMINATED NODE   READINESS GATES
web-79ffc79c64-7lczb   1/1     Running   0          22h   10.42.2.14   w2     <none>           <none>
web-79ffc79c64-wgc5c   1/1     Running   0          2d    10.42.1.8    w1     <none>           <none>
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME      ENDPOINTS                    AGE
web-svc   10.42.1.8:80,10.42.2.14:80   2d
5:Selector:                 app=web
13:Endpoints:                10.42.2.14:80,10.42.1.8:80
```


#### selector/label 매칭 검증
```sh
kubectl -n demo get pods -o wide
kubectl -n demo get svc web-svc -o wide
kubectl -n demo get endpoints web-svc -o wide   # <-- ENDPOINTS: <none> 확인
kubectl -n demo describe svc web-svc | egrep -n "Selector|Endpoints"

kubectl get svc -n demo my-svc -o jsonpath='{.spec.selector}'; echo
kubectl get pod -n demo --show-labels | grep app=
```
- **k8s:** `jsonpath` 출력, pod 조회
- **Linux:** `echo`, `grep`

#### 클러스터 내부에서 curl로 라우팅 테스트(임시 디버그 Pod)
```sh
kubectl run -n demo tmp --rm -it --image=curlimages/curl -- sh
# (Pod 안에서)
curl -sS http://my-svc:8080/health | head
```
- **k8s:** `kubectl run ...`
- **Linux(컨테이너 내부):** `sh/curl/head`

#### DNS 확인(CoreDNS)
```sh
kubectl run -n demo dns --rm -it --image=busybox:1.36 -- sh
```
```
ubuntu@cp1:~$ kubectl run -n demo dns --rm -it --image=busybox:1.36 -- sh
All commands and output from this session will be recorded in container logs, including credentials and sensitive information passed through the command prompt.
If you don't see a command prompt, try pressing enter.
/ #
/ #
/ #
```

## (Pod 안에서)

```
nslookup my-svc
nslookup my-svc.demo.svc.cluster.local
```

```
ubuntu@cp1:~$ kubectl run -n demo dns --rm -it --image=busybox:1.36 -- sh
All commands and output from this session will be recorded in container logs, including credentials and sensitive information passed through the command prompt.
If you don't see a command prompt, try pressing enter.
/ #
/ #
/ # nslookup my-svc
Server:         10.43.0.10
Address:        10.43.0.10:53

** server can't find my-svc.demo.svc.cluster.local: NXDOMAIN

** server can't find my-svc.svc.cluster.local: NXDOMAIN

** server can't find my-svc.svc.cluster.local: NXDOMAIN

** server can't find my-svc.cluster.local: NXDOMAIN

** server can't find my-svc.demo.svc.cluster.local: NXDOMAIN

** server can't find my-svc.cluster.local: NXDOMAIN

/ # nslookup my-svc.demo.svc.cluster.local
Server:         10.43.0.10
Address:        10.43.0.10:53

** server can't find my-svc.demo.svc.cluster.local: NXDOMAIN

** server can't find my-svc.demo.svc.cluster.local: NXDOMAIN

/ #
```
### 위의 오류는 DNS 서버(10.43.0.10 = CoreDNS/kube-dns)까지는 정상적으로 질의가 도달했습니다.
### 그런데 CoreDNS가 **“그 이름의 Service가 존재하지 않는다”**고 답해서 NXDOMAIN이 난 겁니다.
### 즉, **네트워크 문제(차단/타임아웃)**가 아니라, 거의 항상 이름이 틀렸거나(Service가 없음/다른 네임스페이스/오타) 입니다.

### 터미날 새로 실행하여, web-svc 확인 후 위의 pod 에서 재실행
```
ubuntu@cp1:~$ kubectl -n demo get svc
NAME      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
web-svc   ClusterIP   10.43.31.179   <none>        80/TCP    2d1h
```
```
/ # nslookup web-svc.demo.svc.cluster.local
Server:         10.43.0.10
Address:        10.43.0.10:53

Name:   web-svc.demo.svc.cluster.local
Address: 10.43.31.179


/ #
```

### nslookup 이해
```
nslookup은 DNS(이름 → IP) 가 제대로 되는지 확인하는 “질의 도구”예요. Kubernetes에선 서비스 이름이 DNS로 풀리는지(CoreDNS가 응답하는지) 확인할 때 자주 씁니다.

1) nslookup이 하는 일

nslookup <이름> → DNS 서버에 “이 이름의 IP(A/AAAA 레코드) 뭐야?”라고 묻습니다.

응답이 오면 Name / Address(IP) 를 보여줘요.

예:

nslookup web-svc.demo.svc.cluster.local


→ web-svc 서비스의 ClusterIP가 나오면 정상.

2) 출력에서 보는 핵심 항목

예시(너 로그 기준):

Server: 10.43.0.10 / Address: 10.43.0.10:53

지금 질의한 DNS 서버(CoreDNS/kube-dns) 주소

Name: web-svc.demo.svc.cluster.local

최종적으로 질의된 도메인(서비스의 FQDN)

Address: 10.43.31.179

그 이름에 대한 결과 IP(여기서는 Service의 ClusterIP)

3) 왜 nslookup web-svc에서 NXDOMAIN이 섞여 나와?

짧은 이름(예: web-svc)을 주면, 시스템은 /etc/resolv.conf의 search 목록을 붙여서 여러 후보를 순서대로 물어봅니다.

즉, 내부적으로 이런 식으로 여러 번 시도합니다:

web-svc.<현재ns>.svc.cluster.local

web-svc.svc.cluster.local

web-svc.cluster.local
…등

그래서:

맞는 후보는 성공(Name/Address 출력)

나머지는 NXDOMAIN(그 이름 없음) 이 섞여 보일 수 있어요.

Kubernetes에서 “현재 네임스페이스”가 demo라면 보통 이게 성공합니다:

✅ web-svc.demo.svc.cluster.local

4) 자주 보는 결과/의미

성공(Name + Address): DNS 정상, 그 이름의 IP를 찾았음

NXDOMAIN: “그 이름 자체가 없음”
(서비스명 오타 / 다른 namespace / 서비스 미생성일 때 흔함)

timeout / no servers could be reached: DNS 서버에 도달 못함
(CoreDNS 문제, CNI/네트워크, NetworkPolicy, 노드 문제 등)

5) Kubernetes에서 nslookup 실전 팁
FQDN으로 테스트하면 가장 깔끔
nslookup web-svc.demo.svc.cluster.local

짧은 이름이 되는지 확인(네임스페이스 search 덕분)
nslookup web-svc

search 확인(왜 짧은 이름이 되는지)
cat /etc/resolv.conf
```

#### Pod/Node 리소스 실측(top) + 정렬
```sh
kubectl top pod -n demo | sort -k3 -hr | head
kubectl top node | sort -k3 -hr | head
```
- **k8s:** `top`
- **Linux:** `sort/head`

#### requests/limits 확인(Deployment → Pod 템플릿)
```sh
kubectl get deploy -n demo myapp -o yaml | egrep -n 'resources:|requests:|limits:'
```
- **k8s:** `get deploy -o yaml`
- **Linux:** `egrep`


#### 부하를 줘서 스케일 테스트(임시 load generator)
```sh
kubectl run -n demo load --rm -it --image=busybox:1.36 -- sh -lc "while true; do wget -qO- http://my-svc:8080/ >/dev/null; done"
```
```
ubuntu@cp1:~$ kubectl run -n demo load --rm -it --image=busybox:1.36 -- sh -lc "while true; do wget -qO- http://my-svc:8080/ >/dev/null; done"
All commands and output from this session will be recorded in container logs, including credentials and sensitive information passed through the command prompt.
If you don't see a command prompt, try pressing enter.
wget: bad address 'my-svc:8080'
wget: bad address 'my-svc:8080'
wget: bad address 'my-svc:8080'
```

- **k8s:** `kubectl run ...`
- **Linux(컨테이너 내부):** `sh/while/wget`


---

# Kubernetes(k3s) 핵심 용어/기능 정리 (실습용 Glossary)

본 문서는 대화에서 다룬 Kubernetes(k3s) 핵심 기능을 **단어(개념)별로 상세 정리**한 자료입니다.  
실습 환경 예시: `cp1(컨트롤플레인)`, `w1`, `w2` / k3s / `containerd`

---

## 1. Cluster (클러스터)

### 의미
- Kubernetes의 **전체 시스템 단위**.
- 구성 요소:
  - **Control Plane**: API Server, Scheduler, Controller Manager, (etcd 또는 k3s 내장 저장소 등)
  - **Worker Node**: 실제 Pod가 실행되는 노드들
  - **애드온**: CoreDNS, Ingress(예: Traefik), Metrics Server 등

### 무엇을 “변경”한다는 뜻인가?
- 클러스터의 네트워크(CNI), 인증/인가, 버전 업그레이드, 스토리지 구성 등 **전반**에 영향.
- 영향 범위가 크기 때문에 운영에서는 절차(백업/점검/단계적 업그레이드)를 따름.

### 확인 명령
```bash
kubectl cluster-info
kubectl get nodes -o wide
```

---

## 2. Node (노드)

### 의미
- 클러스터에 참여하는 **물리/가상 머신**.
- kubelet + 컨테이너 런타임(containerd 등)이 Pod를 실행.

### 자주 하는 변경/운영 작업
- 라벨/태인트(taint) 변경 → 스케줄링에 영향
- cordon/drain → 유지보수/교체 시 안전하게 Pod 이동
- 노드 추가/제거 → 클러스터 용량 변화

### 확인 명령
```bash
kubectl get nodes -o wide
kubectl describe node <NODE>
```

---

## 3. Namespace (네임스페이스, NS)

### 의미
- 리소스를 논리적으로 분리하는 **구역(격리 단위)**.
- 팀/서비스별로 자원/권한/정책(NetworkPolicy, ResourceQuota 등)을 나누기 좋음.

### 중요한 제약
- 대부분의 리소스는 **다른 Namespace로 “이동”이 불가**(보통 재생성).
- Namespace 삭제 시 내부 리소스가 함께 삭제될 수 있어 주의.

### 확인/생성 명령
```bash
kubectl get ns
kubectl create ns <NAME>
```

---

## 4. Pod

### 의미
- Kubernetes의 **최소 실행 단위**.
- 1개 이상의 컨테이너가 같은 네트워크/스토리지 네임스페이스를 공유.

### 운영 관점
- Pod를 직접 수정하기보다 **Deployment/StatefulSet 같은 컨트롤러를 수정**해 롤링 업데이트가 정석.
- Pod는 많은 필드가 immutable이라 “수정”이라기보다 “재생성”되는 형태가 많음.
- immutable은 **“한번 만들어지면 값을 바꿀 수 없는(불변) 속성”**이라는 뜻

### 확인 명령
```bash
kubectl get pod -A -o wide
kubectl describe pod <POD> -n <NS>
kubectl logs <POD> -n <NS>
```

---

## 5. Service (서비스, SVC)

### 의미
- Pod 집합에 대한 **고정 접근점(가상 IP + DNS 이름)**.
- Pod는 IP가 바뀌어도 Service는 유지 → 안정적인 통신 제공

### 핵심 구성
- `selector`: 어떤 Pod 라벨을 백엔드로 삼을지
- `ports`: 어떤 포트를 열고 Pod의 targetPort로 보낼지
- 타입:
  - ClusterIP: 클러스터 내부 가상 IP
  - NodePort: 노드의 포트를 열어 외부에서 접근
  - LoadBalancer: 클라우드/환경에 따라 외부 LB 제공(또는 k3s ServiceLB 사용)

### 확인 명령
```bash
kubectl get svc -A -o wide
kubectl get ep  -A -o wide    # Endpoints(서비스 뒤 실제 Pod IP 목록)
```

---

## 6. Endpoint / Endpoints(서비스 뒤의 실제 대상)

### 의미
- Service가 트래픽을 보낼 실제 Pod IP/Port 목록.
- Service selector가 맞지 않거나 Pod가 준비되지 않으면 Endpoint가 비어 트래픽이 실패.

### 확인 명령
```bash
kubectl get ep <SVC> -n <NS> -o wide
kubectl describe svc <SVC> -n <NS>
```

---

## 7. CNI (Container Network Interface)

### 의미
- “Pod 네트워크를 실제로 구성하는 플러그인 표준/구현체”.
- Kubernetes는 “Pod 간 통신이 되어야 한다”는 요구만 하고, 실제 구현은 CNI가 담당.

### CNI가 하는 일
- Pod 생성 시:
  - Pod에 IP 할당
  - 네트워크 인터페이스 연결(veth 등)
  - 라우팅/오버레이 구성
- 플러그인에 따라:
  - NetworkPolicy 적용(트래픽 제어)
  - 관측/보안 기능 제공 등

### 장애 시 증상(대표)
- Pod가 IP를 못 받음
- 노드 간 Pod 통신 불가
- DNS/Service 통신이 꼬임

---

## 8. Flannel

### 의미
- 대표적인 CNI 구현체 중 하나.
- 노드 간 Pod 네트워크를 오버레이(VXLAN 등)로 구성해 **Pod ↔ Pod 통신**을 가능하게 함.

### k3s에서 “Pod/DaemonSet로 안 보일 수 있는 이유”
- k3s는 환경에 따라 Flannel이 “별도 DS로 보이는 형태”가 아니라,
  k3s 프로세스가 CNI 설정을 노드에 배치하여 동작시키는 경우가 있어
  `kube-system`에서 `kube-flannel-ds`가 안 보일 수 있음.

### 간접 확인(예)
- Pod IP가 `10.42.x.x`처럼 k3s 기본 Pod CIDR 대역인 경우가 많음
- Pod 내부에서 라우팅/인터페이스 확인:
```bash
kubectl -n <NS> exec -it <POD> -- ip addr
kubectl -n <NS> exec -it <POD> -- ip route
```

---

## 9. veth (Virtual Ethernet pair)

### 의미
- 리눅스의 “가상 이더넷 케이블”.
- **쌍(pair)** 으로 생성되며, 한쪽으로 들어간 트래픽이 다른쪽으로 나오는 구조.

### Kubernetes에서의 역할(개념)
- Pod 네임스페이스 안의 `eth0`는 veth 한쪽 끝.
- 노드(호스트) 네임스페이스에 veth 반대쪽 끝이 존재.
- CNI가 이를 브릿지/라우팅/오버레이에 연결해 통신을 성립시킴.

### kubectl로 확인 가능한 범위
- Pod 내부에서 `eth0` 및 라우팅 확인:
```bash
kubectl -n <NS> exec -it <POD> -- ip link
kubectl -n <NS> exec -it <POD> -- ip addr
```

---

## 10. Taint (테인트)

### 의미
- **노드에 붙이는 “거부/제한 규칙”**.
- “이 노드에는 특정 Pod만 올라오게 하겠다”를 강제.

### 형식
- `key=value:effect`

### effect 종류
- `NoSchedule`: toleration 없는 Pod는 스케줄링 불가(강제)
- `PreferNoSchedule`: 가능하면 피함(soft)
- `NoExecute`: toleration 없으면 기존 Pod도 퇴거(evict)

### 사용 예
- GPU 전용 노드
- 특정 서비스 전용 노드
- 컨트롤플레인 노드에 일반 워크로드 제한 등

### 명령
```bash
kubectl taint nodes <NODE> dedicated=lab:NoSchedule
kubectl taint nodes <NODE> dedicated=lab:NoSchedule-   # 제거
```

---

## 11. Toleration (톨러레이션)

### 의미
- Pod 쪽에서 “이 taint를 견딜 수 있다”고 선언하는 규칙.
- taint(노드) + toleration(Pod)이 맞아야 스케줄 가능.

### 예(개념)
- 노드: `dedicated=lab:NoSchedule`
- Pod: `tolerations: [{key: dedicated, value: lab, effect: NoSchedule}]`

---

## 12. Cordon

### 의미
- 노드를 **Unschedulable(새 Pod 배치 금지)** 로 만드는 것.
- 이미 떠 있는 Pod는 그대로 두고, **새로 생기는 Pod만** 다른 노드로 가게 함.

### 명령
```bash
kubectl cordon <NODE>
kubectl uncordon <NODE>
```

---

## 13. Drain

### 의미
- 노드를 유지보수/교체하기 위해 **노드 위의 Pod를 안전하게 비우는 절차**.
- 보통 drain 과정에서 cordon이 함께 적용됨.

### 동작(개념)
- 기존 Pod를 **evict(퇴거)** → 컨트롤러가 다른 노드에 재생성(Deployment 등)
- Node 오브젝트 자체는 삭제되지 않음

### 자주 막히는 이유: DaemonSet
- drain은 기본적으로 **DaemonSet-managed Pod는 삭제하지 않음**
- 그래서 아래 옵션을 자주 사용:
```bash
kubectl drain <NODE> --ignore-daemonsets --delete-emptydir-data
```

---

## 14. Delete

### 의미
- “리소스 자체를 삭제(없애기)”.
- drain과 다름:
  - **drain**: 노드는 남기고 Pod를 옮김(퇴거)
  - **delete**: 대상 리소스를 제거

### 예
```bash
kubectl delete pod <POD> -n <NS>
kubectl delete deploy <DEPLOY> -n <NS>
kubectl delete svc <SVC> -n <NS>
kubectl delete node <NODE>   # 클러스터에서 노드 오브젝트 제거 (주의)
```

---

## 15. DaemonSet

### 의미
- “**노드마다 1개씩 Pod를 반드시 실행**”하는 워크로드.
- 노드가 늘면 자동으로 해당 노드에 Pod 1개가 추가됨.

### 주 사용처
- 로그 수집 에이전트
- 모니터링 에이전트
- CNI/CSI 노드 플러그인
- k3s ServiceLB(klipper-lb) 계열

### 확인 명령
```bash
kubectl get ds -A
kubectl -n kube-system describe ds <DS_NAME>
```

---

## 16. k3s의 `svclb-traefik-*` (ServiceLB / klipper-lb)

### 의미
- k3s 환경에서 `LoadBalancer` 타입 Service를 지원하기 위해
  노드마다 떠서 트래픽을 프록시/포워딩하는 **DaemonSet Pod** 계열.
- 당신 환경의 에러 메시지:
  - `cannot delete DaemonSet-managed Pods ... kube-system/svclb-traefik-...`
  - drain이 DaemonSet Pod를 기본으로 삭제하지 못해 발생.

### 관련 확인
```bash
kubectl -n kube-system get ds
kubectl -n kube-system get pods -o wide | grep svclb
```

---

## 17. Provisioning (프로비저닝)

### 의미
- “필요한 자원을 **준비/생성/할당**하는 것”.
- drain의 반대 개념이 아님(대상이 다름).

### (A) 스토리지 프로비저닝(가장 흔함)
- PVC 생성 시 PV를 자동 생성/바인딩하는 **동적 프로비저닝**.
- 구성: StorageClass + (CSI 또는 프로비저너)

### (B) 노드(컴퓨트) 프로비저닝
- 노드를 자동으로 늘려 Pod 수용.
- Kubernetes 핵심만으로 자동 생성되기보다, Cluster Autoscaler/Karpenter 등 도구가 담당.

---

## 18. local-path-provisioner (k3s 기본 스토리지 프로비저너)

### 의미
- k3s에서 자주 쓰이는 “로컬 디스크 기반” 동적 스토리지 프로비저너.
- PVC 만들면 노드의 특정 경로에 PV를 만들어 붙여줌.

### 관련 ConfigMap
- `kube-system/local-path-config`: local-path-provisioner 설정

### 확인
```bash
kubectl get storageclass
kubectl -n kube-system get deploy local-path-provisioner
kubectl -n kube-system get cm local-path-config -o yaml
```

---

## 19. ConfigMap (CM) - kube-system에 보이는 것들의 의미

### `coredns`
- CoreDNS의 핵심 설정(Corefile)이 들어있음.
- 서비스 DNS(`*.svc.cluster.local`) 해석과 외부 DNS 포워딩 등을 담당.

### `cluster-dns`
- k3s에서 클러스터 DNS 관련 파라미터(도메인/서비스 IP 등)를 담는 경우가 많음(환경별 차이).

### `extension-apiserver-authentication`
- 확장 API 서버/애그리게이션/웹훅 등이 API Server 인증을 위해 참고하는 공용 설정.

### `kube-root-ca.crt`
- 클러스터 Root CA 인증서(네임스페이스별로도 자동 생성되는 경우 많음).

### `chart-content-traefik`, `chart-content-traefik-crd`
- k3s가 Traefik을 HelmChart 방식으로 관리할 때 남는 흔적(환경에 따라 DATA=0일 수 있음).

---

# 부록 A) “drain vs delete” 한눈에 비교

- **drain**
  - 노드 유지보수 목적
  - Pod를 evict하여 다른 노드로 이동(컨트롤러가 재생성)
  - 노드 오브젝트는 유지

- **delete**
  - 리소스를 제거
  - 대상에 따라 영향 범위가 큼(Pod/Deploy/SVC/Node 등)

---

# 부록 B) 실습 환경에서 실제로 나온 상황 정리

- 노드: `cp1`, `w1`, `w2`
- `kubectl drain w1` 실행 시:
  - `node/w1 cordoned` (cordon은 됨)
  - DaemonSet Pod `kube-system/svclb-traefik-...` 때문에 drain이 중단
- 해결:
```bash
kubectl drain w1 --ignore-daemonsets --delete-emptydir-data
# 실습 후 복구:
kubectl uncordon w1
```

---

# 부록 C) 실습 체크용 빠른 명령 모음

```bash
# 노드/파드 현황
kubectl get nodes -o wide
kubectl get pods -A -o wide

# 서비스/엔드포인트
kubectl get svc -A -o wide
kubectl get ep  -A -o wide

# DaemonSet 확인
kubectl get ds -A
kubectl -n kube-system get pods -o wide | grep svclb

# cordon / drain / uncordon
kubectl cordon <NODE>
kubectl drain <NODE> --ignore-daemonsets --delete-emptydir-data
kubectl uncordon <NODE>

# taint / untaint
kubectl taint nodes <NODE> dedicated=lab:NoSchedule
kubectl taint nodes <NODE> dedicated=lab:NoSchedule-
```

