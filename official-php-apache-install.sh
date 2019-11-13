#!/bin/bash
# 使用官方镜像创建 php + apache 容器

#创建宿主机用于保存配置文件的目录
BASE_PATH=~/docker
if [ -d ${BASE_PATH}/php-apache ]; then
	rm -rf ${BASE_PATH}/php-apache
fi
mkdir -p ${BASE_PATH}/php-apache/apache2/conf ${BASE_PATH}/php-apache/apache2/logs

#设置配置文件保存到宿主机的目录
APACHE_DIR=${BASE_PATH}/php-apache/apache2
APACHE_CONF_DIR=${APACHE_DIR}/conf
PHP_DIR=${BASE_PATH}/php-apache/php
#镜像名
IMAGE=php:7.2-apache
#容器名
CONTAINER=php-apache

#如果镜像不存在则拉取镜像
res=$(docker images) | grep ${IMAGE}
if [ ${res} =="" ]; then
	docker pull ${IMAGE}
fi

#拷贝配置文件到宿主机
docker run --name ${CONTAINER} -d ${IMAGE}
docker cp ${CONTAINER}:/usr/local/etc/php ${PHP_DIR}
docker cp ${CONTAINER}:/etc/apache2/apache2.conf ${APACHE_CONF_DIR}/apache2.conf
docker cp ${CONTAINER}:/etc/apache2/ports.conf ${APACHE_CONF_DIR}/ports.conf
docker cp ${CONTAINER}:/etc/apache2/mods-enabled ${APACHE_CONF_DIR}/mods-enabled
docker cp ${CONTAINER}:/etc/apache2/conf-enabled ${APACHE_CONF_DIR}/conf-enabled
docker stop ${CONTAINER}
docker rm ${CONTAINER}

#创建php.ini
cp ${PHP_DIR}/php.ini-development ${PHP_DIR}/my.ini

#创建apache虚拟主机配置文件
mkdir ${APACHE_CONF_DIR}/sites-enabled
cat>${APACHE_CONF_DIR}/sites-enabled/vhost.conf<<EOF
<VirtualHost *:80>
        ServerName localhost
        DocumentRoot /var/www/html
		DirectoryIndex index.html index.htm index.php
		<Directory /var/www/html>
			Options FollowSymLinks
			AllowOverride None
			Require all granted
		</Directory>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

#创建容器
#--link 是为了连接mysql数据，所有需要先创建mysql数据库容器
docker run --name ${CONTAINER} -p 80:80 -v /shared/WEB:/var/www/html \
	-v ${PHP_DIR}:/usr/local/etc/php \
	-v ${APACHE_CONF_DIR}/ports.conf:/etc/apache2/ports.conf \
	-v ${APACHE_CONF_DIR}/mods-enabled:/etc/apache2/mods-enabled \
	-v ${APACHE_CONF_DIR}/conf-enabled:/etc/apache2/conf-enabled \
	-v ${APACHE_CONF_DIR}/sites-enabled:/etc/apache2/sites-enabled \
	-v ${APACHE_DIR}/logs:/var/log/apache2 \
	--link mysql:mysql \
	-d ${IMAGE}
	
exit 0
