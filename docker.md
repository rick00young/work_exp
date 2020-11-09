## docker创建自定义网络
```
docker network create -o "com.docker.network.bridge.name"="docker1" --subnet 172.20.0.0/16 docker1


指令解析：

创建名为docker1的bridge
--subnet 设置子网段
-o "com.docker.network.bridge.name"="docker1" 给这个bridge起个名字，否则宿主机中看到的网桥名是一坨乱码。
然后就是见证奇迹的时刻：

docker run --rm --ip 172.20.100.100 --net docker1 ubuntu ifconfig

```

## 为Docker容器指定自定义网段的固定IP/静态IP地址


```
Docker守护进程启动以后会创建默认网桥docker0，其IP网段通常为172.17.0.1。在启动Container的时候，Docker将从这个网段自动分配一个IP地址作为容器的IP地址。最新版(1.10.3)的Docker内嵌支持在启动容器的时候为其指定静态的IP地址。这里分为三步：

第一步：安装最新版的Docker
备注：操作系统自带的docker的版本太低，不支持静态IP，因此需要自定义安装。
root@localhost:~# apt-get update
root@localhost:~# apt-get install curl
root@localhost:~# curl -fsSL https://get.docker.com/ | sh
root@localhost:~# docker -v
Docker version 1.10.3, build 20f81dd

第二步：创建自定义网络
备注：这里选取了172.18.0.0网段，也可以指定其他任意空闲的网段
docker network create --subnet=172.18.0.0/16 shadownet
注：shadown为自定义网桥的名字，可自己任意取名。

第三步：在你自定义的网段选取任意IP地址作为你要启动的container的静态IP地址
备注：这里在第二步中创建的网段中选取了172.18.0.10作为静态IP地址。这里以启动shadowsocks为例。
docker run -d -p 2001:2001 --net shadownet --ip 172.18.0.10 oddrationale/docker-shadowsocks -s 0.0.0.0 -p 2001 -k 123456 -m aes-256-cfb

其他
备注1：这里是固定IP地址的一个应用场景的延续，仅作记录用，可忽略不看。
备注2：如果需要将指定IP地址的容器出去的请求的源地址改为宿主机上的其他可路由IP地址，可用iptables来实现。比如将静态IP地址172.18.0.10出去的请求的源地址改成公网IP104.232.36.109(前提是本机存在这个IP地址)，可执行如下命令：
iptables -t nat -I POSTROUTING -o eth0 -d  0.0.0.0/0 -s 172.18.0.10  -j SNAT --to-source 104.232.36.109

```

## 10 Examples of how to get Docker Container IP Address
```
### Example #1 ###
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND               CREATED             STATUS                   PORTS                               NAMES
2e23d01384ac        iperf-v1:latest     "/usr/bin/iperf -s"   10 minutes ago      Up 10 minutes            5001/tcp, 0.0.0.0:32768->5201/tcp   compassionate_goodall
# Append the container ID (CID) to the end of an inspect
$ docker inspect --format '{{ .NetworkSettings.IPAddress }}' 2e23d01384ac
172.17.0.1
  
### Example #2 ###
# Add -q to automatically parse and return the last CID created.
$ docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker ps -q)
172.17.0.1
 
 
### Example #3 ###
# As of Docker v1.3 you can attach to a bash shell
docker exec -it  2e23d01384ac  bash
# That drops you into a bash shell then use the 'ip' command to grab the addr
root@2e23d01384ac:/# ip add | grep global
    inet 172.17.0.1/16 scope global eth0
 
 
### Example #4 ###
# Same as above but in a single line
$ docker exec -it  $(docker ps -q) bash
 
 
### Example #5 ###
# Pop this into your ~/.bashrc (Linux) or ~/.bash_profile (Mac)
dockip() {
  docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$@"
}
# Source it to re-read your bashrc/profile
source ~/.bash_profile
# Now run the function with the container ID you want to get the addr of:
$ dockip 2e23d01384ac
172.17.0.1
  
### Example #6 ###
# Same as above but no argument needed and always return the latest container IP created.
dockip() {
  docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker ps -q)
}
 
 
### Example #7 ###
# Add to bashrc/bash_profile to docker exec in passing the CID to dock-exec. E.g dock-exec $(docker ps -q) OR dock-exec 2e23d01384ac
dock-exec() { docker exec -i -t $@ bash ;}
 
 
### Example #8 ###
# Another little bash function you can pop into your bash profile
# Always docker exec into the latest container
dock-exec() { docker exec -i -t $(docker ps -l -q)  bash ;}
# The run ip addr
ip a
 
 
### Example #9 ###
# Finally you can export the environmental variables from the running container
docker exec -i -t $(docker ps -l -q) env | grep ADDR
# Output --> CLOUDNETPERF_CARBON_1_PORT_2003_TCP_ADDR=172.17.0.229
 
 
### Example #10 ###
# Or even run the ip address command as a parameter which fires off the ip address command and exits the exec
docker exec -i -t $(docker ps -l -q) ip a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default
#    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
#    inet 127.0.0.1/8 scope host lo
#       valid_lft forever preferred_lft forever
#    inet6 ::1/128 scope host
#       valid_lft forever preferred_lft forever
# 470: eth0: <BROADCAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
#    link/ether 02:42:ac:11:00:e9 brd ff:ff:ff:ff:ff:ff
#    inet 172.17.0.233/16 scope global eth0
#       valid_lft forever preferred_lft forever
#    inet6 fe80::42:acff:fe11:e9/64 scope link
#       valid_lft forever preferred_lft forever
 
Bonus Example! 🙂
If you have a user defined network as opposed to the default network, simply grepping on docker inspect is a quick way to parse any field.

Lets say you created a Macvlan network to use the same network as the Docker host  eth0 interface. In this case eth0 on the Linux host is the following:

 
$ ip a show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:13:e4:52 brd ff:ff:ff:ff:ff:ff
    inet 172.16.86.254/24 brd 172.16.86.255 scope global eth0
       valid_lft forever preferred_lft forever
 
Create a network that will share the eth0 interface:

 
$ docker network create -d macvlan \
     --subnet=192.168.1.0/24 \
     --gateway=192.168.1.1  \
     -o parent=eth1 mcv && \
     docker run --net=mcv -it --rm alpine /bin/sh
 
Now grep details about the container:

 
# Get the IP of the most recently started container:
docker inspect  $(docker ps -q) | grep IPAddress
# Or get the gateway for the last container started:
docker inspect  $(docker ps -q) | grep Gateway
 
You can just as easily look at the details of the network:

 
# Get the IP of the most recently started container:
docker inspect  $(docker ps -q) | grep IPAddress
# Or get the gateway for the last container started:
docker inspect  $(docker ps -q) | grep Gateway
 
Lastly, take a look at the docker network inspect details to view the metadata of the network mcv1 you created:
 
$ docker network inspect  mcv1  | grep -i ipv4
       "IPv4Address": "192.168.1.106/24",
 
# or look at the gateway of the network
$ docker network inspect  mcv1  | grep Gateway
       "Gateway": "192.168.1.1/24"
```