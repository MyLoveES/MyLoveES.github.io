title: Install and deploy bitwarden - Linux
date: 2022-01-28
tags: [Linux, Server]
categories: [Linux, Server]
toc: true
---
# 云服务器安装 bitwarden

## [官方文档 Install and Deploy - Linux](https://bitwarden.com/help/install-on-premise-linux/#docker-post-installation-linux-only)

## 创建`bitwarden`本地用户和目录（SKIP）
```
1. Create a bitwarden user:
sudo adduser bitwarden

2. Set password for bitwarden user (strong password):
sudo passwd bitwarden

3. Create a docker group (if it doesn’t already exist):
sudo groupadd docker

4. Add the bitwarden user to the docker group:
sudo usermod -aG docker bitwarden

5. Create a bitwarden directory:
sudo mkdir /opt/bitwarden

6. Set permissions for the /opt/bitwarden directory:
sudo chmod -R 700 /opt/bitwarden

7. Set the bitwarden user ownership of the /opt/bitwarden directory:
sudo chown -R bitwarden:bitwarden /opt/bitwarden
```
## 安装

```
curl -Lso bitwarden.sh https://go.btwrdn.co/bw-sh && chmod 700 bitwarden.sh

全文：
#!/usr/bin/env bash
set -e

cat << "EOF"
 _     _ _                         _
| |__ (_) |___      ____ _ _ __ __| | ___ _ __
| '_ \| | __\ \ /\ / / _` | '__/ _` |/ _ \ '_ \
| |_) | | |_ \ V  V / (_| | | | (_| |  __/ | | |
|_.__/|_|\__| \_/\_/ \__,_|_|  \__,_|\___|_| |_|

EOF

cat << EOF
Open source password management solutions
Copyright 2015-$(date +'%Y'), 8bit Solutions LLC
https://bitwarden.com, https://github.com/bitwarden

===================================================

EOF

# Setup

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME=$(basename "$0")
SCRIPT_PATH="$DIR/$SCRIPT_NAME"
OUTPUT="$DIR/bwdata"
if [ $# -eq 2 ]
then
    OUTPUT=$2
fi

SCRIPTS_DIR="$OUTPUT/scripts"
GITHUB_BASE_URL="https://raw.githubusercontent.com/bitwarden/server/master"

# Please do not create pull requests modifying the version numbers.
COREVERSION="1.45.2"
WEBVERSION="2.25.0"
KEYCONNECTORVERSION="1.0.0"

echo "bitwarden.sh version $COREVERSION"
docker --version
docker-compose --version

echo ""

# Functions

function downloadSelf() {
    if curl -s -w "http_code %{http_code}" -o $SCRIPT_PATH.1 $GITHUB_BASE_URL/scripts/bitwarden.sh | grep -q "^http_code 20[0-9]"
    then
        mv $SCRIPT_PATH.1 $SCRIPT_PATH
        chmod u+x $SCRIPT_PATH
    else
        rm -f $SCRIPT_PATH.1
    fi
}

function downloadRunFile() {
    if [ ! -d "$SCRIPTS_DIR" ]
    then
        mkdir $SCRIPTS_DIR
    fi
    curl -s -o $SCRIPTS_DIR/run.sh $GITHUB_BASE_URL/scripts/run.sh
    chmod u+x $SCRIPTS_DIR/run.sh
    rm -f $SCRIPTS_DIR/install.sh
}

function checkOutputDirExists() {
    if [ ! -d "$OUTPUT" ]
    then
        echo "Cannot find a Bitwarden installation at $OUTPUT."
        exit 1
    fi
}

function checkOutputDirNotExists() {
    if [ -d "$OUTPUT/docker" ]
    then
        echo "Looks like Bitwarden is already installed at $OUTPUT."
        exit 1
    fi
}

function listCommands() {
cat << EOT
Available commands:

install
start
restart
stop
update
updatedb
updaterun
updateself
updateconf
renewcert
rebuild
help

See more at https://bitwarden.com/help/article/install-on-premise/#script-commands-reference

EOT
}

# Commands

case $1 in
    "install")
        checkOutputDirNotExists
        mkdir -p $OUTPUT
        downloadRunFile
        $SCRIPTS_DIR/run.sh install $OUTPUT $COREVERSION $WEBVERSION $KEYCONNECTORVERSION
        ;;
    "start" | "restart")
        checkOutputDirExists
        $SCRIPTS_DIR/run.sh restart $OUTPUT $COREVERSION $WEBVERSION $KEYCONNECTORVERSION
        ;;
    "update")
        checkOutputDirExists
        downloadRunFile
        $SCRIPTS_DIR/run.sh update $OUTPUT $COREVERSION $WEBVERSION $KEYCONNECTORVERSION
        ;;
    "rebuild")
        checkOutputDirExists
        $SCRIPTS_DIR/run.sh rebuild $OUTPUT $COREVERSION $WEBVERSION $KEYCONNECTORVERSION
        ;;
    "updateconf")
        checkOutputDirExists
        $SCRIPTS_DIR/run.sh updateconf $OUTPUT $COREVERSION $WEBVERSION $KEYCONNECTORVERSION
        ;;
    "updatedb")
        checkOutputDirExists
        $SCRIPTS_DIR/run.sh updatedb $OUTPUT $COREVERSION $WEBVERSION $KEYCONNECTORVERSION
        ;;
    "stop")
        checkOutputDirExists
        $SCRIPTS_DIR/run.sh stop $OUTPUT $COREVERSION $WEBVERSION $KEYCONNECTORVERSION
        ;;
    "renewcert")
        checkOutputDirExists
        $SCRIPTS_DIR/run.sh renewcert $OUTPUT $COREVERSION $WEBVERSION $KEYCONNECTORVERSION
        ;;
    "updaterun")
        checkOutputDirExists
        downloadRunFile
        ;;
    "updateself")
        downloadSelf && echo "Updated self." && exit
        ;;
    "help")
        listCommands
        ;;
    *)
        echo "No command found."
        echo
        listCommands
esac

```