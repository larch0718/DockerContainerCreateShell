#!/bin/bash
# 安装samba

#创建宿主机用于共享的目录
BASE_PATH=/shared
if [ ! -d ${BASE_PATH} ]; then
	sudo mkdir ${BASE_PATH}
fi

sudo chmod 777 ${BASE_PATH}
sudo chown -R nobody:nobody ${BASE_PATH}

#镜像名
IMAGE=dperson/samba
#容器名
CONTAINER=samba

#如果镜像不存在则拉取镜像
res=$(docker images) | grep ${IMAGE}
if [ ${res} =="" ]; then
	docker pull ${IMAGE}
fi

#创建容器
docker run -it --name ${CONTAINER} \
	-p 139:139 \
	-p 445:445 \
	-v /shared:/mount \
	-d ${IMAGE} \
	-u "samba;123456" \
	-s "shared;/mount/;yes;no;no;all;none"
	
exit 0
