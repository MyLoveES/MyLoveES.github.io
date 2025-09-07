---
title: Install and deploy bitwarden - Linux
date: 2022-01-28
categories:
- "技术"
tags:
- "服务器"
- "自托管"
- "Bitwarden"
- "密码管理"
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

### 1. Download the Bitwarden installation script (bitwarden.sh) to your machine:
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

### 2. Run the installer script. A ./bwdata directory will be created relative to the location of bitwarden.sh.
```
./bitwarden.sh install
```

### 3. Complete the prompts in the installer
- Enter the domain name for your Bitwarden instance:  
Typically, this value should be the configured DNS record.

- Do you want to use Let's Encrypt to generate a free SSL certificate? (y/n):  
  Specify y to generate a trusted SSL certificate using Let's Encrypt. You will be prompted to enter an email address for expiration reminders from Let's Encrypt. For more information, see Certificate Options.
  Alternatively, specify n and use the Do you have a SSL certificate to use? option.

- Enter your installation id:  
  Retrieve an installation id using a valid email at https://bitwarden.com/host. For more information, see What are my installation id and installation key used for?.

- Enter your installation key:  
  Retrieve an installation key using a valid email at https://bitwarden.com/host. For more information, see What are my installation id and installation key used for?.

- Do you have a SSL certificate to use? (y/n):  
  If you already have your own SSL certificate, specify y and place the necessary files in the ./bwdata/ssl/your.domain directory. You will be asked whether it is a trusted SSL certificate (y/n). For more information, see Certificate Options.

  Alternatively, specify n and use the self-signed SSL certificate? option, which is only recommended for testing purposes.

- Do you want to generate a self-signed SSL certificate? (y/n):  
  Specify y to have Bitwarden generate a self-signed certificate for you. This option is only recommended for testing. For more information, see Certificate Options.

  If you specify n, your instance will not use an SSL certificate and you will be required to front your installation with a HTTPS proxy, or else Bitwarden applications will not function properly.

### 4. Post-Install Configuration

- Environment Variables
```
...
globalSettings__mail__smtp__host=<placeholder>
globalSettings__mail__smtp__port=<placeholder>
globalSettings__mail__smtp__ssl=<placeholder>
globalSettings__mail__smtp__username=<placeholder>
globalSettings__mail__smtp__password=<placeholder>
...
adminSettings__admins=
...
```

Replacing `globalSettings__mail__smtp...=` placeholdesr will configure the SMTP Mail Server that will be used to send verification emails to new users and invitations to Organizations. Adding an email address to `adminSettings__admins=` will provision access to the Admin Portal.

After editing `global.override.env`, run the following command to apply your changes:

```
./bitwarden.sh restart
```

### 5. Installation File

The Bitwarden installation script uses settings in `./bwdata/config.yml` to generate the necessary assets for installation. Some installation scenarios (e.g. installations behind a proxy with alternate ports) may require adjustments to `config.yml` that were not provided during standard installation.

Edit `config.yml` as necessary and apply your changes by running:

```
./bitwarden.sh rebuild
```

### Start Bitwarden

Once you've completed all previous steps, start your Bitwarden instance:

```
./bitwarden.sh start
```

The first time you start Bitwarden it may take some time as it downloads all of the images from Docker Hub.

Verify that all containers are running correctly:

```
docker ps
```

Congratulations! Bitwarden is now up and running at `https://your.domain.com`. Visit the web vault in your web browser to confirm that it's working.

You may now register a new account and log in. You will need to have configured `smtp` environment variables (see [Environment Variables](#environment-variable)) in order to verify the email for your new account.

## Script Commands Reference

The Bitwarden installation script (`bitwarden.sh` or `bitwarden.ps1`) has the following commands available:

PowerShell users will run the commands with a prefixed `-` (switch). For example `.\bitwarden.ps1 -start`.

| Command    | Description                                                    |
|------------|----------------------------------------------------------------|
| install    | Start the installer.                                           |
| start      | Start all containers.                                          |
| restart    | Restart all containers (same as start).                        |
| stop       | Stop all containers.                                           |
| update     | Update all containers and the database.                        |
| updatedb   | Update/initialize the database.                                |
| updateself | Update this main script.                                       |
| updateconf | Update all containers without restarting the running instance. |
| renewcert  | Renew certificates.                                            |
| rebuild    | Rebuild generated installation assets from `config.yml`.       |
| help       | List all commands.                                             |
