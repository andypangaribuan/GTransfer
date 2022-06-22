##
<p align="center">
  <b style="font-size: 30px;">GTransfer</b>
  <br>
  <b>GTransfer</b> is an Google Cloud Storage + Samba + SFTP.<br>
  Mounting GCS bucket using <a href="https://github.com/GoogleCloudPlatform/gcsfuse">GCSFuse</a> and serving it using samba server and/or SFTP.
  <br>
  <a href="https://github.com/andypangaribuan/GTransfer">
    <img height="20px" src="https://badges.frapsoft.com/os/v1/open-source.svg?v=103">
  </a>
  <a>
    <img alt="Docker Image Size (latest semver)" src="https://img.shields.io/docker/image-size/andypangaribuan/gtransfer?sort=semver">
  </a>
  <a href="https://hub.docker.com/r/andypangaribuan/gtransfer">
    <img alt="Docker Image Version (latest semver)" src="https://img.shields.io/docker/v/andypangaribuan/gtransfer?sort=semver">
  </a>
</p>

## ⚙️ Installation
Build with:
```shell
docker build -t andypangaribuan/gtransfer .
```
Please refer to <a href="https://github.com/andypangaribuan/GTransfer/blob/main/docker-compose.yaml">docker-compose.yaml</a>


## 👀 Integration
```yaml
version: "3.8"

services:
  nginx:
    image: nginx:1.22.0-alpine
    container_name: al-temp
    restart: always
    volumes:
      - gt-vol:/nginx-logs

volumes:
  gt-vol:
    name: gt-vol
    driver_opts:
      type: cifs
      o: "username={SMB_USER},password={SMB_PASSWORD},port={SMB PORT},iocharset=utf8,file_mode=0777,dir_mode=0777"
      device: "//{IP}/{SMB_SHARED_NAME}"
```

## ⚠️ License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/andypangaribuan/GTransfer/blob/main/LICENSE) 


[//]: # ( docker registry
build using: 
  $ docker build -t andypangaribuan/gtransfer:1.0.0 .
  $ docker push andypangaribuan/gtransfer:1.0.0
)