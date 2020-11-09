# zabbix修炼日志
****



## bsd zabbix

[download](http://www.zabbix.com/download.php)

```
wget http://pilotfiber.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.0.3/zabbix-3.0.3.tar.gzzabbix-3.0.3.tar.gz
```

## 建立 zabbix 用户
```
# groupadd zabbix
# useradd -g zabbix zabbix
```

## php.ini

```
max_execution_time = 300
memory_limit = 128M
post_max_size = 16M
upload_max_filesize = 2M
max_input_time = 300
date.timezone = PRC
always_populate_raw_post_data = -1
```

## 编译参数

```
# 服务器
./configure --prefix=/home/zabbix --enable-server \
    --enable-agent --with-mysql --with-libcurl --with-libxml2

# 客户端
./configure --prefix=/home/zabbix --enable-agent
```

## 创建数据库

```
mysql> CREATE DATABASE zabbix DEFAULT CHARSET UTF8;
```

## 导入数据

```
mysql> USE zabbix;
mysql> source database/mysql/schema.sql;
mysql> source database/mysql/images.sql;
mysql> source database/mysql/data.sql;
```

## 配置

`zabbix_server.conf`,`zabbix_agentd.conf`

## nginx 虚拟主机

## web安装