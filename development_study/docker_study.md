## Docker Study
```
docker run -d -p 80:80 --name webserver nginx

docker ps

docker start webserver

docker stop webserver

docker rm -rf webserver

docker rmi <imageId> | <imageName>

docker rmi nginx

docker run -it ubuntu:latest /bin/bash

sudo docker commit 614122c0aabb aoct/apache2
```



```
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak #备份
sudo vim /etc/apt/sources.list #修改
sudo apt-get update #更新列表
阿里云源

deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
```