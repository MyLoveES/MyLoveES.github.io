title: DiscoNAS Media Library
date: 2025-06-07
tags: [Life, Technology, NAS]
categories: [Life, Technology, NAS]
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

{% asset_img image.png %}

### 1.2 修改端口号

{% asset_img image%201.png %}

### 1.3 修改下载路径

{% asset_img image%202.png %}

### 1.4 修改语言

{% asset_img image%203.png %}

### 1.5 添加分类

{% asset_img image%204.png %}

## 2. Jackett

### 2.1 记住 API KEY

后面需要配置到 NASTOOL 中

{% asset_img image%205.png %}

### 2.2 添加公开的 INDEXER

需要等待几分钟，才能添加完

{% asset_img image%206.png %}

{% asset_img image%207.png %}

## 3. Jellyfin

### 3.1 添加媒体库

- 选择 NASTOOL 链接后的目录

{% asset_img image%208.png %}

{% asset_img image%209.png %}

{% asset_img image%2010.png %}

### 3.2 生成API密钥

后面给 NASTOOL 用

{% asset_img image%2011.png %}

### 3.3 指定转码

{% asset_img image%2012.png %}

## 4. NASTOOL

### 4.1 TMDB

https://www.themoviedb.org/

{% asset_img image%2013.png %}

{% asset_img image%2014.png %}

{% asset_img image%2015.png %}

### 4.2 媒体库

- 注意要用NASTOOL链接后的目录

{% asset_img image%2016.png %}

### 4.3 目录同步

- 从 下载目录 到 转换后的目录

{% asset_img image%2017.png %}

### 4.4 索引器

{% asset_img image%2018.png %}

{% asset_img image%2019.png %}

### 4.5 下载器

{% asset_img image%2020.png %}

{% asset_img image%2021.png %}

### 4.6 媒体播放器

{% asset_img image%2022.png %}

{% asset_img image%2023.png %}

### 4.7 服务

- 可以手动目录同步，或者清理缓存

{% asset_img image%2024.png %}
