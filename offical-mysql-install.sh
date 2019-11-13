#!/bin/bash
# 使用官方镜像安装 mysql

#创建宿主机用于保存配置文件的目录
BASE_PATH=~/docker
if [ -d ${BASE_PATH}/mysql ]; then
	sudo rm -rf ${BASE_PATH}/mysql
fi
mkdir -p ${BASE_PATH}/mysql/data ${BASE_PATH}/mysql/log

#设置配置文件保存到宿主机的目录
MYSQL_DIR=${BASE_PATH}/mysql
#镜像名
IMAGE=mysql:5.7.27
#容器名
CONTAINER=mysql
#mysql的root密码
PASSWORD=Password123!

#如果镜像不存在则拉取镜像
res=$(docker images) | grep ${IMAGE}
if [ ${res} =="" ]; then
	docker pull ${IMAGE}
fi

#拷贝配置文件到宿主机
docker run --name ${CONTAINER} -d ${IMAGE}
docker cp ${CONTAINER}:/etc/mysql ${MYSQL_DIR}/conf
docker stop ${CONTAINER}
docker rm ${CONTAINER}

#创建容器
docker run --name ${CONTAINER} -p 3306:3306 -v ${MYSQL_DIR}/conf:/etc/mysql -v ${MYSQL_DIR}/data:/var/lib/mysql -v ${MYSQL_DIR}/logs:/logs -e MYSQL_ROOT_PASSWORD=${PASSWORD} -d ${IMAGE}
