# DockerContainerCreateShell
创建docker容器的shell脚步

## official-php-apache-install.sh
* 使用官方镜像创建 php + apache 容器
* apache版本：2.4.38
* php版本：7.2.24
* 添加php模块（以添加支持pdo_mysql为例）
  * 进入容器
  
        docker exec -it php-apache /bin/bash
      
  * 进入php模块安装目录
  
        cd /usr/local/bin
      
  * 执行添加模块操作
  
        docker-php-ext-install pdo_mysql

## official-mysql-install.sh
* mysql版本：5.7.27
