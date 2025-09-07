---
title: DiscoNAS Media Library
date: 2025-06-07
categories:
- "技术"
- "生活"
tags:
- "服务器"
- "自托管"
- "NAS"
- "媒体库"
toc: true
---

# Media Library

```jsx
version: "3"
services:
     jellyfin:
        image: nyanmisaka/jellyfin:250627-amd64
        container_name: media_library_jellyfin
        environment:
         - PUID=0
         - PGID=0
         - TZ=Asia/Shanghai
        volumes:
         - /share/CACHEDEV1_DATA/Container/container-station-data/application/media_library/jellyfin/config:/config
         - /share/CACHEDEV1_DATA/Container/container-station-data/application/media_library/jellyfin/cache:/cache
         - /share/CACHEDEV1_DATA/Weasley/Videos/:/videos
        ports:
         - 8096:8096
         - 8920:8920
        devices:
         - /dev/dri:/dev/dri
        restart: unless-stopped
     nastool:
        # image: hsuyelin/nas-tools:3.4.1
        image: razeencheng/nastool:2.9.1
        container_name: media_library_nastool
        environment:
         - PUID=0
         - PGID=0
         - UMASK=000
         - TZ=Asia/Shanghai
         - NASTOOL_AUTO_UPDATE=false
         - REPO_URL=https://ghproxy.com/https://github.com/hsuyelin/nas-tools.git
         # - ALPINE_MIRROR=mirrors.ustc.edu.cn
         # - LANG=C.UTF-8
         # - NASTOOL_AUTO_UPDATE=false
         # - NASTOOL_CN_UPDATE=false
         # - NASTOOL_CONFIG=/config/config.yaml
         # - NASTOOL_VERSION=master
         # - PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
         # - PYPI_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple
         # - REPO_URL=https://github.com/jxxghp/nas-tools.git
         # - WORKDIR=/nas-tools
        volumes:
         - /share/CACHEDEV1_DATA/Container/container-station-data/application/media_library/nastool/config:/config
         - /share/CACHEDEV1_DATA/Weasley/Videos/:/videos
        ports:
         - 3000:3000
        restart: unless-stopped
     jackett:
        image: linuxserver/jackett:amd64-0.22.2132
        container_name: media_library_jackett
        volumes:
         - /share/CACHEDEV1_DATA/Container/container-station-data/application/media_library/jackett/config:/config
         - /share/CACHEDEV1_DATA/Container/container-station-data/application/media_library/jackett/downloads:/downloads
        environment:
         - PUID=1000
         - PGID=1000
         - TZ=Asia/Shanghai
         - AUTO_UPDATE=true
         # - HOME=/root
         # - LSIO_FIRST_PARTY=true
         # - PATH=/lsiopy/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
         # - S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0
         # - S6_STAGE2_HOOK=/docker-mods
         # - S6_VERBOSITY=1
         # - TERM=xterm
         # - VIRTUAL_ENV=/lsiopy
         # - XDG_CONFIG_HOME=/config
         # - XDG_DATA_HOME=/config
        ports:
         - 9117:9117
        restart: unless-stopped
     qBittorrent:
        image: superng6/qbittorrentee:5.1.1.10
        container_name: media_library_qBittorrent
        environment:
          - PUID=1026
          - PGID=100
          - TZ=Asia/Shanghai
          - WEBUIPORT=8080
          - ENABLE_DOWNLOADS_PERM_FIX=true
        restart: unless-stopped
        volumes:
         - /share/CACHEDEV1_DATA/Container/container-station-data/application/media_library/qBittorrent/config:/config
         - /share/CACHEDEV1_DATA/Weasley/Videos/:/downloads
        ports:
         - 8080:8080
         - 26881:6881
         - 26881:6881/udp
```

## 1. qBittorrent

- 默认账号：admin
- 默认密码：需要查看 qBittorrent 容器日志

### 1.1 修改密码

![](image.png)

### 1.2 修改端口号

![](image_1.png)

### 1.3 修改下载路径

![](image_2.png)

### 1.4 修改语言

![](image_3.png)

### 1.5 添加分类

![](image_4.png)

## 2. Jackett

### 2.1 记住 API KEY

后面需要配置到 NASTOOL 中

![](image_5.png)

### 2.2 添加公开的 INDEXER

需要等待几分钟，才能添加完

![](image_6.png)

![](image_7.png)

## 3. Jellyfin

### 3.1 添加媒体库

- 选择 NASTOOL 链接后的目录

![](image_8.png)

![](image_9.png)

![](image_10.png)

### 3.2 生成API密钥

后面给 NASTOOL 用

![](image_11.png)

### 3.3 指定转码

![](image_12.png)

## 4. NASTOOL

### 4.1 TMDB

https://www.themoviedb.org/

![](image_13.png)

![](image_14.png)

![](image_15.png)

### 4.2 媒体库

- 注意要用NASTOOL链接后的目录

![](image_16.png)

### 4.3 目录同步

- 从 下载目录 到 转换后的目录

![](image_17.png)

### 4.4 索引器

![](image_18.png)

![](image_19.png)

### 4.5 下载器

![](image_20.png)

![](image_21.png)

### 4.6 媒体播放器

![](image_22.png)

![](image_23.png)

### 4.7 服务

- 可以手动目录同步，或者清理缓存

![](image_24.png)
