#!/bin/bash
# 通过官方镜像安装nginx + php

# docker容器根目录
BASE_PATH=~/docker
# 网站根目录
WEB_DIR=/shared/Web

# php 镜像名
PHP_IMAGE=php:7.1.33-fpm
# php 容器名
PHP_CONTAINER=phpfpm
# php配置文件的目录
PHP_CONF=${BASE_PATH}/nginx-php/php
# php-fpm配置文件的目录
PHP_FPM_CONF=${BASE_PATH}/nginx-php/php-fpm
# nginx 镜像名
NGINX_IMAGE=nginx
# nginx 容器名
NGINX_CONTAINER=nginx
# nginx配置文件的目录
NGINX_CONF=${BASE_PATH}/nginx-php/nginx


#创建宿主机用于保存配置文件的目录
if [ -d ${BASE_PATH}/nginx-php ]; then
	sudo rm -rf ${BASE_PATH}/nginx-php
fi
mkdir -p ${PHP_FPM_CONF}

# 安装php
#如果镜像不存在则拉取镜像
res=$(docker images) | grep ${PHP_IMAGE}
if [ ${res} =="" ]; then
	docker pull ${PHP_IMAGE}
fi

#拷贝PHP配置文件到宿主机
docker run --name ${PHP_CONTAINER} -d ${PHP_IMAGE}
docker cp ${PHP_CONTAINER}:/usr/local/etc/php ${PHP_CONF}
docker cp ${PHP_CONTAINER}:/usr/local/etc/php-fpm.conf ${PHP_FPM_CONF}/php-fpm.conf
docker cp ${PHP_CONTAINER}:/usr/local/etc/php-fpm.d ${PHP_FPM_CONF}/php-fpm.d
docker stop ${PHP_CONTAINER}
docker rm ${PHP_CONTAINER}

# 创建容器
docker run --name ${PHP_CONTAINER} \
	-v ${WEB_DIR}:/var/www \
	-v ${PHP_CONF}/php:/usr/local/etc/php \
	-v ${PHP_FPM_CONF}/php-fpm.conf:/usr/local/etc/php-fpm.conf \
	-v ${PHP_FPM_CONF}/php-fpm.d:/usr/local/etc/php-fpm.d \
	-d ${PHP_IMAGE}

# 安装nginx
mkdir -p  ${NGINX_CONF}/logs
#如果镜像不存在则拉取镜像
res=$(docker images) | grep ${NGINX_IMAGE}
if [ ${res} =="" ]; then
	docker pull ${NGINX_IMAGE}
fi

# 生成 nginx配置文件
mkdir ${NGINX_CONF}/conf.d
cat>${NGINX_CONF}/conf.d/default.conf<<'EOF'
server {
    listen       80;
    server_name  localhost;

    access_log  /var/log/nginx/localhost.access.log  main;

    location / {
        root   /var/www;
        index  index.html index.htm;
    }
	
    location ~ \.php($|/) {
        root           /var/www;
        fastcgi_pass   php-fpm:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
}
EOF


#拷贝PHP配置文件到宿主机
docker run --name ${NGINX_CONTAINER} -d ${NGINX_IMAGE}
docker cp ${NGINX_CONTAINER}:/etc/nginx/nginx.conf ${NGINX_CONF}/nginx.conf
docker stop ${NGINX_CONTAINER}
docker rm ${NGINX_CONTAINER}

#创建容器
docker run --name ${NGINX_CONTAINER} \
	-p 80:80 \
	-v ${WEB_DIR}:/var/www \
	-v ${NGINX_CONF}/conf.d:/etc/nginx/conf.d \
	-v ${NGINX_CONF}/nginx.conf:/etc/nginx/nginx.conf \
	-v ${NGINX_CONF}/logs:/var/log/nginx \
	--link ${PHP_CONTAINER}:php-fpm \
	-d ${NGINX_IMAGE}

exit 0
