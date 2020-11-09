# install python

1.安装依赖包

```
yum -y groupinstall "Development tools"
yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel
```

```
# wget https://www.python.org/ftp/python/3.6.2/Python-3.6.2.tgz
# yum install openssl-devel bzip2-devel expat-devel gdbm-devel readline-devel sqlite-devel //安装可能的依赖库
# tar -zxvf Python-3.6.2.tgz
# cd Python-3.6.2/
# ./configure --prefix=/usr/local/ //安装到/usr/local目录
# make
# make altinstall //此处不能用install安装，因为install不区分版本，会出现多版本混乱的问题

```
2.下载python

```
wget https://www.python.org/ftp/python/3.6.2/Python-3.6.2.tar.xz
wget https://www.python.org/ftp/python/3.6.2/Python-3.6.2.tgz
```

3.创建目录

```
mkdir /usr/local/python3 
```

4.解压压缩包，进入该目录，安装Python3

```
tar -xvJf  Python-3.6.2.tar.xz
cd Python-3.6.2
./configure --prefix=/usr/local/python3
make && make install
```

5.创建软链接

```
ln -s /usr/local/python3/bin/python3 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
```