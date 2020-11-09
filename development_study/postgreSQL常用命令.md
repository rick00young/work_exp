（1）用户实用程序：

createdb 创建一个新的PostgreSQL的数据库（和SQL语句：CREATE DATABASE 相同） 

createuser 创建一个新的PostgreSQL的用户（和SQL语句：CREATE USER 相同） 

dropdb 删除数据库 

dropuser 删除用户 

pg_dump 将PostgreSQL数据库导出到一个脚本文件 

pg_dumpall 将所有的PostgreSQL数据库导出到一个脚本文件 

pg_restore 从一个由pg_dump或pg_dumpall程序导出的脚本文件中恢复PostgreSQL数据库 

psql 一个基于命令行的PostgreSQL交互式客户端程序 

vacuumdb 清理和分析一个PostgreSQL数据库，它是客户端程序psql环境下SQL语句VACUUM的shell脚本封装，二者功能完全相同

（2）系统实用程序

1. pg_ctl 启动、停止、重启PostgreSQL服务（比如：pg_ctl start 启动PostgreSQL服务，它和service postgresql start相同） 

2. pg_controldata 显示PostgreSQL服务的内部控制信息 

3. psql 切换到PostgreSQL预定义的数据库超级用户postgres，启用客户端程序psql，并连接到自己想要的数据库，比如说： 

psql template1 

出现以下界面，说明已经进入到想要的数据库，可以进行想要的操作了。 

template1=#

(3).在数据库中的一些命令：

template1=# \l 查看系统中现存的数据库 

template1=# \q 退出客户端程序psql 

template1=# \c 从一个数据库中转到另一个数据库中，如template1=# \c sales 从template1转到sales 

template1=# \dt 查看表 

template1=# \d 查看表结构 

template1=# \di 查看索引

[基本数据库操作]========================

1. *创建数据库： create database [数据库名]; 

2. *查看数据库列表： \d 

3. *删除数据库： . drop database [数据库名]; 

创建表： create table ([字段名1] [类型1] <references 关联表名(关联的字段名)>;,[字段名2] [类型2],......<,primary key (字段名m,字段名n,...)>;); 

*查看表名列表： \d 

*查看某个表的状况： \d [表名] 

*重命名一个表： alter table [表名A] rename to [表名B]; 

*删除一个表： drop table [表名]; ========================================

[表内基本操作]==========================

*在已有的表里添加字段： alter table [表名] add column [字段名] [类型]; 

*删除表中的字段： alter table [表名] drop column [字段名]; 

*重命名一个字段： alter table [表名] rename column [字段名A] to [字段名B]; 

*给一个字段设置缺省值： alter table [表名] alter column [字段名] set default [新的默认值]; 

*去除缺省值： alter table [表名] alter column [字段名] drop default; 

在表中插入数据： insert into 表名 ([字段名m],[字段名n],......) values ([列m的值],[列n的值],......); 

修改表中的某行某列的数据： update [表名] set [目标字段名]=[目标值] where [该行特征]; 

删除表中某行数据： delete from [表名] where [该行特征]; 

delete from [表名];--删空整个表 ========================== ==========================

(4).PostgreSQL用户认证

PostgreSQL数据目录中的pg_hba.conf的作用就是用户认证，可以在/usr/local/pgsql/data中找到。 

有以下几个例子可以看看： 

(1)允许在本机上的任何身份连接任何数据库 

TYPE DATABASE USER IP-ADDRESS IP-MASK METHOD 

local all all trust(无条件进行连接) 

(2)允许IP地址为192.168.1.x的任何主机与数据库sales连接 

TYPE DATABASE USER IP-ADDRESS IP-MASK METHOD 

host sales all 192.168.1.0 255.255.255.0 ident sameuser(表明任何操作系统用户都能够以同名数据库用户进行连接)

(5).看了那么多，来一个完整的创建PostgreSQL数据库用户的示例吧

(1)进入PostgreSQL高级用户 

(2)启用客户端程序，并进入template1数据库 

psql template1 

(3)创建用户 

template1=# CREATE USER hellen WITH ENCRYPED PASSWORD'zhenzhen' 

(4)因为设置了密码，所以要编辑pg_hba.conf，使用户和配置文件同步。 

在原有记录上面添加md5 

local all hellen md5 

(4)使用新用户登录数据库 

template1=# \q 

psql -U hellen -d template1 

PS：在一个数据库中如果要切换用户，要使用如下命令： 

template1=# \!psql -U tk -d template1

(6).设定用户特定的权限

还是要用例子来说明： 

创建一个用户组： 

sales=# CREATE GROUP sale; 

添加几个用户进入该组 

sales=# ALTER GROUP sale ADD USER sale1,sale2,sale3; 

授予用户级sale针对表employee和products的SELECT权限 

sales=# GRANT SELECT ON employee,products TO GROUP sale; 

在sale中将用户user2删除 

sales=# ALTER GROUP sale DROP USER sale2;

(7).备份数据库

可以使用pg_dump和pg_dumpall来完成。比如备份sales数据库：

pg_dump sales>/home/tk/pgsql/backup/1.bak


```
SELECT * FROM json_test WHERE data ->> 'a' > '1';


select extend from "order" where extend ->>'is_reward' = '1';

select id, device_info, request_time_stamp from user_behavior where device_info -> 'platform' is null  order by id desc limit 10


//日期过滤
select count(*) from user_behavior where event_time > '2016-12-22 00:00:00';

select id from user_behavior where event_time > '2016-12-22 00:00:00' order by id asc limit 100;

update user_behavior set event_time = to_timestamp(request_time_stamp) where id in (select id from user_behavior where event_time > '2016-12-22 00:00:00' limit 10);

update user_behavior set event_time = to_timestamp(request_time_stamp) where id in (select id from user_behavior where event_time > '2016-12-22 00:00:00' order by id asc  limit 100);
 
//替换日期
update user_behavior set event_time = to_timestamp(request_time_stamp) where event_time > '2016-12-22 00:00:00';

//timestamp to date
SELECT to_timestamp(1195374767);

// 用时间戳替换错误日期
update user_behavior set event_time = to_timestamp(request_time_stamp) where id = 5346030;
```


```
Instead of comparing dates using `DATE_TRUNC` you should probably just use between instead.

 

For example, instead of this:

SELECT some_timestamp
FROM some_table
WHERE DATE_TRUNC('day', some_timestamp) = '2015-06-23'::timestamp
Use this:

SELECT some_timestamp
FROM some_table
WHERE some_timestamp BETWEEN '2015-06-23'::timestamp AND '2015-06-23'::timestamp + '1 days'::interval
```


SELECT * FROM pg_locks pl LEFT JOIN pg_stat_activity psa ON pl.pid = psa.pid;