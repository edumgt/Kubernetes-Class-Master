# Docker 이미지 빌드

## Step-01: 사전 준비
- Docker Hub 계정을 생성합니다.
- https://hub.docker.com/
- **중요:** 아래 명령어의 `stacksimplify`는 본인의 Docker Hub 계정으로 대체 가능합니다.

## Step-02: Dockerfile 생성 및 커스텀 Nginx 설정 복사
- **Dockerfile**
```Dockerfile
FROM nginx
COPY default.conf /etc/nginx/conf.d
```
- **default.conf**
  - `proxy_pass`에 Backend ClusterIP Service 이름과 포트를 지정합니다.
```conf
server {
    listen       80;
    server_name  localhost;
    location / {
    # Backend ClusterIP Service 이름과 포트를 업데이트
    # proxy_pass http://<Backend-ClusterIp-Service-Name>:<Port>;
    proxy_pass http://my-backend-service:8080;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```

## Step-03: Docker 이미지 빌드
```
# Docker 이미지 빌드
docker build -t stacksimplify/kube-frontend-nginx:1.0.0 .

# 본인 Docker Hub 계정으로 빌드
docker build -t <your-docker-hub-id>/kube-frontend-nginx:1.0.0 .
```

## Step-04: Docker Hub에 이미지 푸시
```
# Docker Hub에 이미지 푸시
docker push stacksimplify/kube-frontend-nginx:1.0.0

# 본인 Docker Hub 계정으로 푸시
docker push <your-docker-hub-id>/kube-frontend-nginx:1.0.0
```

## Step-05: Docker Hub에서 확인
- Docker Hub에 로그인하여 업로드된 이미지를 확인합니다.
- https://hub.docker.com/repositories

## 추가 설명
- Backend Service 이름이 변경되면 `default.conf`의 `proxy_pass`도 반드시 수정해야 합니다.
- 로컬 테스트 시 `docker run -p 8080:80`로 동작 여부를 확인할 수 있습니다.
- 이미지 태그를 환경/버전별로 분리하면 롤백과 재현성이 좋아집니다.
