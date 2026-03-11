
### 필요 사항
```
REGION=ap-northeast-2
ACCOUNT_ID=<내_aws_account_id>
REPO=fastapi-health
TAG=1.0
IMAGE_LOCAL=$REPO:$TAG
IMAGE_ECR=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO:$TAG
```
---
```
root@DESKTOP-D6A344Q:/home/Kube-Local/fastapi# ls -al
total 28
drwxr-xr-x 2 root root 4096 Jan 31 15:12 .
drwxr-xr-x 5 root root 4096 Jan 31 15:13 ..
-rw-r--r-- 1 root root  206 Jan 31 15:01 Dockerfile
-rw-r--r-- 1 root root  168 Jan 31 15:12 Readme.md
-rw-r--r-- 1 root root  564 Jan 31 15:00 main.py
-rw-r--r-- 1 root root  549 Jan 31 15:11 regecr.sh
-rw-r--r-- 1 root root   42 Jan 31 15:01 requirements.txt
root@DESKTOP-D6A344Q:/home/Kube-Local/fastapi# chmod +x regecr.sh
```
---
```
apt-get update
apt-get install -y docker.io
docker --version
```
---
```
root@DESKTOP-D6A344Q:/home/Kube-Local/fastapi# ./regecr.sh

WARNING! Your credentials are stored unencrypted in '/root/.docker/config.json'.
Configure a credential helper to remove this warning. See
https://docs.docker.com/go/credential-store/

Login Succeeded
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon   7.68kB


생략

523062ea36b5: Pushed 
e50a58335e13: Pushed 
1.0: digest: sha256:2e8681c1e1c3d1246b07988ecce03aad0d0ecd45d656fe263a745a3dfaaa8c15 size: 1991
Pushed: 086015456585.dkr.ecr.ap-northeast-2.amazonaws.com/fastapi-health:1.0
```
