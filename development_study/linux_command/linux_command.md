##Linux Command

### 查看系统用户及用户组
```
俺的centos vps上面不知道添加了多少个账户，今天想清理一下，但是以前还未查看过linux用户列表，google了一下，找到方便的放：
一般情况下是

cat /etc/passwd 可以查看所有用户的列表
w 可以查看当前活跃的用户列表
cat /etc/group 查看用户组

但是这样出来的结果一大堆，看起来嘿负责，于是继续google
找到个简明的layout命令

cat /etc/passwd|grep -v nologin|grep -v halt|grep -v shutdown|awk -F":" '{ print $1"|"$3"|"$4 }'|more
```

### Linux Shell 1>/dev/null 2>&1 含义
>`/dev/null`: 代表空设备文件

> `>`: 代表重定向到哪里，例如：echo "123" > /home/123.txt

> `1`: 表示stdout标准输出，系统默认值是1，所以">/dev/null"等同于"1>/dev/null"

> `2`: 表示stderr标准错误

> `&`: 表示等同于的意思，2>&1，表示2的输出重定向等同于1

`1 > /dev/null 2>&1` 语句含义：

	1 > /dev/null ： 首先表示标准输出重定向到空设备文件，也就是不输出任何信息到终端，说白了就是不显示任何信息。

	2>&1 ：接着，标准错误输出重定向（等同于）标准输出，因为之前标准输出已经重定向到了空设备文件，所以标准错误输出也重定向到空设备文件。

### shell压缩解压命令：gzip、zip、tar
  gzip 和 gunzip
   
	压缩:
	gzip  filename 文件即会被压缩，并被保存为 filename.gz
	
	解压缩:
	gunzip filename.gz filename.gz 会被删除，而继之以 filename
	可以通过命令man gzip 和man gunzip获得命令的详细说明.
	
	
zip 和 unzip

	要使用 zip 来压缩文件，在 shell 提示下键入下面的命令：
	zip -r filename.zip filesdir 
	在这个例子里，filename.zip 代表你创建的文件，filesdir 代表你想放置新 zip 文件的目录。-r 选项指定你想递归地（recursively）包括所有包括在 filesdir 目录中的文件。
	
	要解压缩 zip 文件的内容，键入以下命令：
	unzip filename.zip
	
	你可以使用 zip 命令同时处理多个文件和目录，方法是将它们逐一列出，并用空格间隔：

	zip -r filename.zip file1 file2 file3 /usr/work/school

	上面的命令把 file1、file2、 file3、以及 /usr/work/school 目录的内容（假设这个目录存在）压缩起来，然后放入 filename.zip 文件中。

tar

	tar 文件是几个文件和（或）目录在一个文件中的集合。这是创建备份和归档的佳径。

	tar 使用的选项有：

	-c — 创建一个新归档。

	-f — 当与 -c 选项一起使用时，创建的 tar 文件使用该选项指定的文件名；当与 -x 选项一起使用时，则解除该选项指定的归档。

	-t — 显示包括在 tar 文件中的文件列表。

	-v — 显示文件的归档进度。

	-x — 从归档中抽取文件。

	-z — 使用 gzip 来压缩 tar 文件。

	-j — 使用 bzip2 来压缩 tar 文件。

	要创建一个 tar 文件，键入：

	tar -cvf filename.tar directory/file

	在以上的例子中，filename.tar 代表你创建的文件，directory/file 代表你想放入归档文件内的文件和目录。

	你可以使用 tar 命令同时处理多个文件和目录，方法是将它们逐一列出，并用空格间隔：

	tar -cvf filename.tar /home/mine/work /home/mine/school

	上面的命令把 /home/mine 目录下的 work 和 school 子目录内的所有文件都放入当前目录中一个叫做 filename.tar 的新文件里

	以下是一个解压的例子

	tar -zvxf  filename.tar.gz  
	
	以下是一个压缩例子
	tar -czvf test.chunk.gz kgs-19-2014/
	
### 用shell切分文件--split
有个文件要处理，因为很大，所以想把它切成若干份，每份N行，以便并行处理。怎么搞呢？查了下强大的shell，果然有现成的工具--split。
下面记录下基本用法：

split [-bl] file [prefix]  
参数说明：
> -b, --bytes=SIZE：对file进行切分，每个小文件大小为SIZE。可以指定单位b,k,m。
> 
> -l, --lines=NUMBER：对file进行切分，每个文件有NUMBER行。

> prefix：分割后产生的文件名前缀

示例：

1.假设要切分的文件为test.2012-08-16_17，大小1.2M，12081行。
1)

	split -l 5000 test.2012-08-16_17  
	
	生成xaa，xab，xac三个文件。
	wc -l 看到三个文件行数如下：
	5000 xaa
	5000 xab
	2081 xac
	12081 总计
2) 
	split -b 600k test.2012-08-16_17  
	
	生成xaa，xab两个文件
	ls -lh 看到 两个文件大小如下：
	600K xaa
	554K xab
	
3)
	split -b 500k test.2012-08-16_17 example 
	
	得到三个文件，文件名的前缀都是example
	ls -lh 看到文件信息如下：
	500K exampleaa
	500K exampleab
	154K exampleac
	
### Linux中find常见用法示例
ind   path   -option   [   -print ]   [ -exec   -ok   command ]   {} \;
find命令的参数；

> pathname: find命令所查找的目录路径。例如用.来表示当前目录，用/来表示系统根目录。

> -print： find命令将匹配的文件输出到标准输出。

> -exec： find命令对匹配的文件执行该参数所给出的shell命令。相应命令的形式为'command' { } \;，注意{ }和\；之间的空格。

> -ok： 和-exec的作用相同，只不过以一种更为安全的模式来执行该参数所给出的shell命令，在执行每一个命令之前，都会给出提示，让用户来确定是否执行。

> -print 将查找到的文件输出到标准输出

> -exec   command   {} \;      —–将查到的文件执行command操作,{} 和 \;之间有空格

> -ok 和-exec相同，只不过在操作前要询用户
例：find . -name .svn | xargs rm -rf

### 查看Linux内核版本
```
cat /etc/issue  //CentOS release 6.4 (Final)
uname -r //2.6.32-358.6.1.el6.i686
``` 


## cat uniq

```
cat words.txt mf.keyword.txt | sort  | uniq -c
```

反顺序

```
cat words.txt mf.keyword.txt | sort  -r | uniq -c
```

## 批量删出以下字符串里的目录
```
a='texi2html, yasm, lame, x264, xvid, fdk-aac, libpng, freetype, frei0r, libffi, pcre, glib, fribidi, fontconfig, pixman, cairo, gobject-introspection, icu4c, harfbuzz, libass, libbluray, libcaca, libvidstab, libogg, libvorbis, libvpx, opencore-amr, jpeg, libtiff, little-cms2, openjpeg, makedepend, openssl, opus, rtmpdump, orc, schroedinger, sdl2, speex, theora, x265,'

for i in $a; do echo ${i//,/ }; done | xargs rm -rf
```

## linux中shell变量$#,$@,$0,$1,$2的含义解释

变量说明: 

```
$$ 
Shell本身的PID（ProcessID） 
$! 
Shell最后运行的后台Process的PID 
$? 
最后运行的命令的结束代码（返回值） 
$- 
使用Set命令设定的Flag一览 
$* 
所有参数列表。如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。 
$@ 
所有参数列表。如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。 
$# 
添加到Shell的参数个数 
$0 
Shell本身的文件名 
$1～$n 
添加到Shell的各参数值。$1是第1参数、$2是第2参数…。 
```

## tree 

```
-a：显示所有文件和目录； 
-A：使用ASNI绘图字符显示树状图而非以ASCII字符组合； 
-C：在文件和目录清单加上色彩，便于区分各种类型； 
-d：先是目录名称而非内容； 
-D：列出文件或目录的更改时间； 
-f：在每个文件或目录之前，显示完整的相对路径名称； 
-F：在执行文件，目录，Socket，符号连接，管道名称名称，各自加上*，/，@，|号'；
-g：列出文件或目录的所属群组名称，没有对应的名称时，则显示群组识别码； 
-i：不以阶梯状列出文件和目录名称； 
-l：<范本样式> 不显示符号范本样式的文件或目录名称； 
-l：如遇到性质为符号连接的目录，直接列出该连接所指向的原始目录； 
-n：不在文件和目录清单加上色彩； 
-N：直接列出文件和目录名称，包括控制字符； 
-p：列出权限标示； 
-P：<范本样式> 只显示符合范本样式的文件和目录名称； 
-q：用“？”号取代控制字符，列出文件和目录名称； 
-s：列出文件和目录大小； 
-t：用文件和目录的更改时间排序； 
-u：列出文件或目录的拥有者名称，没有对应的名称时，则显示用户识别码； 
-x：将范围局限在现行的文件系统中，若指定目录下的某些子目录，其存放于另一个文件系统上，则将该目录予以排除在寻找范围外。
```

## Mac 中 Terminal（终端）的快捷键
```
Ctrl + A 将光标跳到行头
Ctrl + E 将光标跳到行尾
Ctrl + L 清屏
Ctrl + R 搜索以前执行过的命令
Ctrl + C 终止正在运行的程序
Ctrl + D 退出 Terminal（这里建议使用 Command ＋ W 来完成）
Ctrl + Z 将当前程序放置于背景，可以用 fg 来恢复
```

### CentOS如何查看端口是被哪个应用/进程占用

```
netstat -lnpt |grep 88   #88请换为你的apache需要的端口，如：80
lsof -i:port
ps -ef | grep 5000

pip install uwsgi
```

## remove first and last char
```
string="|abcdefg|"
echo ${string:1:-1}
```

```
date +"[%Y_%m_%d %H:%M:%S,%3N]"
cat h5_demo.log | awk '{print $1}' | sed 's/\[//g; s/\]//g
```

## shell实现字符串连接的方法
```
str="abc"
str="$str  efg"                           #实现了追加赋值
echo $str
```


## Assigning a static IP to Ubuntu

```
vi /etc/network/interfaces
auto eth0
iface eth0 inet static
   address 10.253.0.50
   netmask 255.255.255.0
   network 10.253.0.0
   gateway 10.253.0.1
   dns-nameservers 8.8.8.8
   
sudo service networking restart
```


## shell字行串md5并取模并随机删除文件
```
echo 'adbc' | md5 | cksum | awk '{print $1}'

for i in `ls`
do
	echo $i
	no=$(echo $i | md5 | cksum | awk '{print $1}')
	echo $no
	mode=`expr $no % 40`
	echo "mode is $mode"
	if [ $mode -ne 0 ]
	then
	   echo "remove--------"
	   rm $i
	else
	   echo "staying****"
	fi
done
```

## Linux 查看目录大小 
```
sudo du -smh * | sort -n  //统计当前目录大小 并安大小 排序
```

```
ls | awk '{a=sprintf("waon -i \"%s\" -o \"/Users/rick/work_space/sy_data/music_data/origin_audio/mid/%s.mid\"", $0, $0);print a}' | sh
```
 
```
	立志爱上科研
	Smart is the new Sexy
	tar压缩解压缩命令详解
	
	tar命令详解
	
	-c: 建立压缩档案
	
	-x：解压
	
	-t：查看内容
	
	-r：向压缩归档文件末尾追加文件
	
	-u：更新原压缩包中的文件
	
	这五个是独立的命令，压缩解压都要用到其中一个，可以和别的命令连用但只能用其中一个。
	
	下面的参数是根据需要在压缩或解压档案时可选的。
	
	-z：有gzip属性的
	
	-j：有bz2属性的
	
	-Z：有compress属性的
	
	-v：显示所有过程
	
	-O：将文件解开到标准输出
	
	参数-f是必须的
	
	-f: 使用档案名字，切记，这个参数是最后一个参数，后面只能接档案名。
	
	.# tar -cf all.tar *.jpg 这条命令是将所有.jpg的文件打成一个名为all.tar的包。-c是表示产生新的包，-f指定包的文件名。
	.# tar -rf all.tar *.gif 这条命令是将所有.gif的文件增加到all.tar的包里面去。-r是表示增加文件的意思。 
	.# tar -uf all.tar logo.gif 这条命令是更新原来tar包all.tar中logo.gif文件，-u是表示更新文件的意思。 
	.# tar -tf all.tar 这条命令是列出all.tar包中所有文件，-t是列出文件的意思 
	.# tar -xf all.tar 这条命令是解出all.tar包中所有文件，-x是解开的意思
	
	查看
	tar -tf aaa.tar.gz   在不解压的情况下查看压缩包的内容
	
	压缩
	
	tar –cvf jpg.tar *.jpg //将目录里所有jpg文件打包成tar.jpg
	
	tar –czf jpg.tar.gz *.jpg //将目录里所有jpg文件打包成jpg.tar后，并且将其用gzip压缩，生成一个gzip压缩过的包，命名为jpg.tar.gz
	
	tar –cjf jpg.tar.bz2 *.jpg //将目录里所有jpg文件打包成jpg.tar后，并且将其用bzip2压缩，生成一个bzip2压缩过的包，命名为jpg.tar.bz2
	
	tar –cZf jpg.tar.Z *.jpg   //将目录里所有jpg文件打包成jpg.tar后，并且将其用compress压缩，生成一个umcompress压缩过的包，命名为jpg.tar.Z
	
	解压
	
	tar –xvf file.tar //解压 tar包
	
	tar -xzvf file.tar.gz //解压tar.gz
	
	tar -xjvf file.tar.bz2   //解压 tar.bz2tar –xZvf file.tar.Z //解压tar.Z
	bunzip2 	file.tar.bz2 //解压
	总结
	
	1、*.tar 用 tar –xvf 解压
	
	2、*.gz 用 gzip -d或者gunzip 解压
	
	3、*.tar.gz和*.tgz 用 tar –xzf 解压
	
	4、*.bz2 用 bzip2 -d或者用bunzip2 解压
	
	5、*.tar.bz2用tar –xjf 解压
	
	6、*.Z 用 uncompress 解压
	
	7、*.tar.Z 用tar –xZf 解压
	
```

### 终端登录免密码
	pbcopy > id_rsa.pub
	将本机的 .ssh下的id_rsa.pub 文件内容拷到服务器的.ssh下的authorized_keys文件 里，没有此文件则新建
 
### axel命令
	http://man.linuxde.net/axel
	axel -n 10 -o /tmp/ http://www.linuxde.net/lnmp.tar.gz

```
--max-speed=x , -s x 最高速度x 
--num-connections=x , -n x 连接数x 
--output=f , -o f 下载为本地文件f 
--search[=x] , -S [x] 搜索镜像 
--header=x , -H x 添加头文件字符串x（指定 HTTP header） 
--user-agent=x , -U x 设置用户代理（指定 HTTP user agent） --no-proxy ， -N 不使用代理服务器 --quiet ， -q 静默模式 
--verbose ，-v 更多状态信息 
--alternate ， -a Alternate progress indicator 
--help ，-h 帮助 
--version ，-V 版本信息
```

### 按节点名称删除文件
```
ls -i | grep '(1)' | awk '{print $1}' > del.txt 
del=$(cat del.txt)
for x in $del 
do 
	cc='find . -inum' $x '-print -exec rm -rf {} \;'
	$($cc)
done
```


### Linux查看磁盘空间（df, du）

```
df -h
du -sh foo
du -sh *
```


### axel 多线程下载与上传

```
axel 
[options] url1 [url2] [url...] 

选项 --max-speed=x ,
-s x 最高速度x --num-connections=x , 
-n x 连接数x --output=f , 
-o f 下载为本地文件f --search[=x] , 
-S [x] 搜索镜像 --header=x , 
-H x 添加头文件字符串x（指定 HTTP header） --user-agent=x , -U x 设置用户代理（指定 HTTP user agent） --no-proxy ， 
-N 不使用代理服务器 --quiet ， 
-q 静默模式 --verbose ，
-v 更多状态信息 --alternate ， 
-a Alternate progress indicator --help ，
-h 帮助 --version ，
-V 版本信息 

实例 
如下载lnmp安装包指定10个线程，存到/tmp/： 
axel -n 10 -o /tmp/ http://www.linuxde.net/lnmp.tar.gz

```


### ...
```
nethogs: 按进程查看流量占用
iptraf: 按连接/端口查看流量
ifstat: 按设备查看流量
ethtool: 诊断工具
tcpdump: 抓包工具
ss: 连接查看工具
其他: dstat, slurm, nload, bmon
```

### shell实现 python for i in range(1,100)
```
1.
	for i in `seq 100`
	do
		echo $i
	done
2.
	i=1;while(($i<100)); do echo $i; i=$(($i+1)); done
```

### 分析nginx log  ，查出来前10 个访问最多的ip
```
cat nginx.log | awk '{print $1}' | sort -r |uniq | sort -n
```

### 写一个计划任务，让这个计划任务在11月份，每天6-12点，每2个小时运行一次

```
0 6,8,10,12 * 11 *   命令
```

### 使用tcpdump 命令 收集主机地址为192.168.1.1 端口为80 ，并输出到tcpdump.log中


### 一条命令统计实时并发数
```
将其中的 $4 换成日志中的时间字段即可
$ tail -f dev.access.log | awk 'BEGIN{OFS = "\t"; count = 0; iter_key = "check_key"}{count++; current = $4; if (iter_key != current) {print iter_key, count; count = 0; iter_key = current; }}'
```

```
awk -F: 'BEGIN{A=0;B=0} {if($3>100) {A++; print "large"} else {B++; print "small"}} END{print A,"\t",B}' /etc/passwd 
```

## 查看gpu
lspci | grep -i vga
lspci -v -s 01:00.0

查看CPU信息（型号）
[root@AAA ~]# cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c
     24         Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz

## 查看物理CPU个数
[root@AAA ~]# cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l
2

## 查看每个物理CPU中core的个数(即核数)
[root@AAA ~]# cat /proc/cpuinfo| grep "cpu cores"| uniq
cpu cores    : 6

## 查看逻辑CPU的个数
[root@AAA ~]# cat /proc/cpuinfo| grep "processor"| wc -l
24