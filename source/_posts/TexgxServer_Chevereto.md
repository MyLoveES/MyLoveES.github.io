title: Install and deploy Chevereto - Linux
date: 2022-02-15
tags: [Linux, Server]
categories: [Linux, Server]
toc: true
---

## Docker Image
[nmtan/chevereto](https://hub.docker.com/r/nmtan/chevereto/)

## Environment variables
The most essentials environments variables are listed below
- CHEVERETO_DB_HOST - Hostname of the Database machine that you wish to connect, default to db
- CHEVERETO_DB_PORT - The port of the Database machine to connect to, default to 3306
- CHEVERETO_DB_USERNAME - Username to authenticate to MySQL database, default to chevereto
- CHEVERETO_DB_PASSWORD - Password of the user when connect to MySQL database, default to chevereto
- CHEVERETO_DB_NAME - Name of the database in MySQL server, default to chevereto
- CHEVERETO_DB_PREFIX - Table prefix (you can use this to run multiple instance of Chevereto using the same Database), default to chv_

For other environment variables, please consult the file [settings.php](https://github.com/tanmng/docker-chevereto/blob/master/settings.php) and the section "Advanced configuration" below.

## Persistent storage
Chevereto stores images uploaded by users in /var/www/html/images directory within the container.  
You can mount a data volume at this location to ensure that you don't lose your images if you relaunch/remove container.

## Max image size
By default, PHP allow a maximum file upload to be 2MB. You can change such behaviour by updating the php.ini in your container, either by bind-mount the file, or build a new image with the updated file, that way you can reuse the image on demand.

Note that by default, Chevereto set a file upload limit of 10MB, so after you modify your php.ini, you should also update this settings in Chevereto settings page (available at CHEVERETO_URL/dashboard/settings/image-upload)

The customized php.ini should set the values of upload_max_filesize, post_max_size and potentially memory_limit, as showed in the discussion from Chevereto Forum. Further details on these parameters are available from PHP documentation

An example of this is available in the examples/bigger-files directory

## Standalone
```
docker run -it --name chevereto -d \
    --link mysql:mysql \
    -p 80:80 \
    -v "$PWD/images":/var/www/html/images \
    -e "CHEVERETO_DB_HOST=db" \
    -e "CHEVERETO_DB_USERNAME=chevereto" \
    -e "CHEVERETO_DB_PASSWORD=chevereto" \
    -e "CHEVERETO_DB_NAME=chevereto" \
    -e "CHEVERETO_DB_PREFIX=chv_" \
    nmtan/chevereto
```

## docker-compose
```
version: '3'

services:
  db:
    image: mariadb
    container_name: chevereto_mariadb
    volumes:
      - ./database:/var/lib/mysql:rw
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: chevereto_root
      MYSQL_DATABASE: chevereto
      MYSQL_USER: chevereto
      MYSQL_PASSWORD: chevereto
    networks:
      - docker_default
      - docker_public

  chevereto:
    depends_on:
      - db
    image: nmtan/chevereto
    restart: always
    container_name: chevereto
    environment:
      CHEVERETO_DB_HOST: db
      CHEVERETO_DB_USERNAME: chevereto
      CHEVERETO_DB_PASSWORD: chevereto
      CHEVERETO_DB_NAME: chevereto
      CHEVERETO_DB_PREFIX: chv_
    volumes:
      - ./images:/var/www/html/images:rw
      - ./php.ini:/usr/local/etc/php/php.ini:rw
    ports:
      - 8081:80
    networks:
      - docker_default
      - docker_public

networks:
  docker_default:
    external: true
  docker_public:
    external: true
```

## Nginx (使用了bitwarden的nginx) 
```
upstream chevereto {
    server chevereto:80;
}

server {
    listen 8080 default_server;
    listen [::]:8080 default_server;
    server_name chevereto.weasley.cn;
    proxy_set_header X-Forwarded-For $remote_addr;
    location / {
        proxy_set_header Host $host;
        proxy_pass http://chevereto;
        client_max_body_size 256m;
    }
}
```

## php.ini
```
[PHP]
max_execution_time = 60;
memory_limit = 256M;
upload_max_filesize = 256M;
post_max_size = 256M;
```