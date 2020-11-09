### 查看系统流量
nethogs命令详解

>有很多适用于Linux系统的开源网络监视工具.比如说,你可以用命令iftop来检查带宽使用情况. netstat用来查看接口统计报告,还有top监控系统当前运行进程.但是如果你想要找一个能够按进程实时统计网络带宽利用率的工具,那么NetHogs值得一看。

>NetHogs是一个小型的net top工具,不像大多数工具那样拖慢每个协议或者是每个子网的速度而是按照进程进行带宽分组.NetHogs不需要依赖载入某个特殊的内核模块. 如果发生了网络阻塞你可以启动NetHogs立即看到哪个PID造成的这种状况.这样就很容易找出哪个程序跑飞了然后突然占用你的带宽.

```
1.安装依赖包
yum install libpcap  libpcap-devel

#On Debian, Ubuntu or Linux Mint:
sudo apt-get install libncursesw5-dev

#On CentOS, Fedora or RHEL:
yum install ncurses-devel

2.编译安装
wget 'https://github.com/raboof/nethogs/archive/v0.8.5.zip'
unzip v0.8.5.zip
cd nethogs
make && make install

3.参数详解
nethogs --help
nethogs: invalid option -- '-'
usage: nethogs [-V] [-b] [-d seconds] [-t] [-p] [device [device [device ...]]]
		-V : prints version.
		-d : delay for update refresh rate in seconds. default is 1.
		-t : tracemode.
		-b : bughunt mode - implies tracemode.
		-p : sniff in promiscious mode (not recommended).
		device : device(s) to monitor. default is eth0

When nethogs is running, press:
 q: quit
 m: switch between total and kb/s mode

交互命令：
以下是NetHogs的一些交互命令(键盘快捷键)
m : 修改单位
r : 按流量排序
s : 按发送流量排序
q : 退出命令提示符
关于NetHogs命令行工具的完整参数列表，可以参考NetHogs的手册，使用方法是在终端里输入man nethogs。

```




### Linux netstat命令详解

>在Linux中，有那么几个命令是非常重要的，而这篇文章总结的netstat就是其中之一。

>netstat命令是什么？netstat命令主要用于显示与IP、TCP、UDP和ICMP协议相关的统计数据及网络相关信息，例如可以用于检验本机各端口的网络连接情况。

>当你想看看哪个端口被哪个程序占用了；当你想查看TCP连接状态；当你想统计网络连接信息时，这些都可以用netstat命令来搞定，这就是netstat。

>掌握一个Linux命令的方法就是去使用它，下面来说说如何使用，以及读懂netstat命令输出的内容。

当我们在Linux系统（以Centos 6.5为例）中输入netstat命令，会输出以下内容：

```
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 iZ253yxvp6fZ:http       123.116.36.165:dbdb     ESTABLISHED
tcp        0      0 iZ253yxvp6fZ:58911      iZ253yxvp6fZ:http       TIME_WAIT
tcp        0    372 iZ253yxvp6fZ:ssh        58.248.178.212:62087    ESTABLISHED
tcp        0      0 iZ253yxvp6fZ:38625      10.173.43.34:mysql      TIME_WAIT
tcp        0      0 iZ253yxvp6fZ:http       123.116.36.165:6127     ESTABLISHED
tcp        0      0 localhost:cslistener    localhost:42183         TIME_WAIT
Active UNIX domain sockets (w/o servers)
Proto RefCnt Flags       Type       State         I-Node   Path
unix  5      [ ]         DGRAM                    6235     /run/systemd/journal/socket
unix  2      [ ]         DGRAM                    10662    /var/run/nscd/socket
unix  2      [ ]         DGRAM                    11600
unix  3      [ ]         STREAM     CONNECTED     11058
unix  3      [ ]         STREAM     CONNECTED     1156961
unix  3      [ ]         DGRAM                    9857
先来说说上面输出内容的含义。从整体上看，netstat命令的输出分为以下两部分：
```
>Active Internet connections (w/o servers)部分
Active UNIX domain sockets (w/o servers)部分
Active Internet connections (w/o servers)部分称为有源TCP连接，其中Recv-Q和Send-Q指的是接收队列和发送队列，这些数字一般都是为0，如果不为0则表示数据包正在队列中堆积。

>Active UNIX domain sockets (w/o servers)部分称为有源Unix域套接口（和网络套接字一样，但是只能用于本机通信，性能可以提高一倍）。Proto显示连接使用的协议，RefCnt表示连接到本套接口上的进程号，Types显示套接口的类型，State显示套接口当前的状态，Path表示连接到套接口的其它进程使用的路径名。

>明白netstat这些含义以后，接下来再配合一些常用的选项，让netstat命令输出更丰富、更有用的信息。

常用选项

```
选项	说明
-a或–all	显示所有选项，默认不显示LISTEN相关
-t或–tcp	仅显示TCP传输协议的连接状况
-u或–udp	仅显示UDP传输协议的连接状况
-n或–numeric	拒绝显示别名，能显示数字的全部转化成数字
-l或–listening	仅列出在Listen(监听)状态的socket
-p或–programs	显示正在使用Socket的程序识别码和程序名称
-r或–route	显示路由信息
-s或–statistice	显示网络工作信息统计表
-c或–continuous	每隔指定时间执行netstat命令
提示：LISTEN和LISTENING的状态只有用-a或者-l才能看到
```
以上就是我们工作中经常使用的一些选项。或单独使用一个选项，或多个选项结合使用。

下面就列举一些工作中经常使用的一些命令实例，以下命令可以作为案头手册，以备查询。

命令实例

```
列出所有端口（包括监听和未监听的）
netstat -a      # 列出所有端口
netstat -at     # 列出所有TCP端口
netstat -au     # 列出所有UDP端口
列出所有处于监听状态的Sockets
netstat -l      # 只显示监听端口
netstat -lt     # 只列出所有监听TCP端口
netstat -lu     # 只列出所有监听UDP端口
netstat -lx     # 只列出所有监听UNIX端口
显示所有端口的统计信息
netstat -s      # 显示所有端口的统计信息
netstat -st     # 显示TCP端口的统计信息
netstat -su     # 显示UDP端口的统计信息

显示路由信息
netstat -r
```

```
netstat是一个非常强大的命令，特别是和其它命令进行结合时，更能体现出它的强大性，比如统计TCP每个连接状态的数据：
netstat -n | awk '/^tcp/ {++state[$NF]}; END {for(key in state) print key,"\t",state[key]}'

又比如查找请求数量排名前20的IP：
netstat -anlp|grep 80|grep tcp|awk '{print $5}'|awk -F: '{print $1}'|sort|uniq -c|sort -nr|head -n20
```

看到这些比较逆天的命令行，是不是有点晕，但是现实工作中，它就是这么好用，实在是居家旅行必备的精品。



###telnet命令
>telnet命令用于登录远程主机，对远程主机进行管理。telnet因为采用明文传送报文，安全性不好，很多Linux服务器都不开放telnet服务，而改用更安全的ssh方式了。但仍然有很多别的系统可能采用了telnet方式来提供远程登录，因此弄清楚telnet客户端的使用方式仍是很有必要的。

```
语法 telnet(选项)(参数)
选项
-8：允许使用8位字符资料，包括输入与输出；
-a：尝试自动登入远端系统；
-b<主机别名>：使用别名指定远端主机名称；
-c：不读取用户专属目录里的.telnetrc文件；
-d：启动排错模式；
-e<脱离字符>：设置脱离字符；
-E：滤除脱离字符；
-f：此参数的效果和指定"-F"参数相同；
-F：使用Kerberos V5认证时，加上此参数可把本地主机的认证数据上传到远端主机；
-k<域名>：使用Kerberos认证时，加上此参数让远端主机采用指定的领域名，而非该主机的域名；
-K：不自动登入远端主机；
-l<用户名称>：指定要登入远端主机的用户名称；
-L：允许输出8位字符资料；
-n<记录文件>：指定文件记录相关信息；
-r：使用类似rlogin指令的用户界面；
-S<服务类型>：设置telnet连线所需的ip TOS信息；
-x：假设主机有支持数据加密的功能，就使用它；
-X<认证形态>：关闭指定的认证形态。

参数
	远程主机：指定要登录进行管理的远程主机；
	端口：指定TELNET协议使用的端口号。

实例
telnet 192.168.2.10
Trying 192.168.2.10...
Connected to 192.168.2.10 (192.168.2.10).
Escape character is '^]'.
	localhost (Linux release 2.6.18-274.18.1.el5 #1 SMP Thu Feb 9 12:45:44 EST 2012) (1)
login: root
Password:
Login incorrect

```


网络调试利器呀:
### 抓包
```
sudo tcpdump -Xnlps0 -i any tcp port 9501
-i 参数制定了网卡
any表示所有网卡
tcp 指定仅监听TCP协议
port 制定监听的端口
[S] 表示这是一个SYN请求
[.] 表示这是一个ACK确认包，(client)SYN->(server)SYN->(client)ACK 就是3次握手过程
[P] 表示这个是一个数据推送，可以是从服务器端向客户端推送，也可以从客户端向服务器端推
[F] 表示这是一个FIN包，是关闭连接操作，client/server都有可能发起
[R] 表示这是一个RST包，与F包作用相同，但RST表示连接关闭时，仍然有数据未被处理。可以理解为是强制切断连接
win xxx 是指滑动窗口大小
length nn 指数据包的大小
```

CentOS7使用firewalld打开关闭防火墙与端口
```
那怎么开启一个端口呢
添加
firewall-cmd --zone=public --add-port=80/tcp --permanent    （--permanent永久生效，没有此参数重启后失效）

firewall-cmd --zone=public --add-port=1910/tcp --permanent

重新载入
firewall-cmd --reload
查看
firewall-cmd --zone=public --query-port=80/tcp
删除
firewall-cmd --zone=public --remove-port=80/tcp --permanent

```
