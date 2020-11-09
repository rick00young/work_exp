## hive动态分区
### 一）hive中支持两种类型的分区：
* 静态分区SP（static partition）
* 动态分区DP（dynamic partition）

静态分区与动态分区的主要区别在于静态分区是手动指定，而动态分区是通过数据来进行判断。详细来说，静态分区的列实在编译时期，通过用户传递来决定的；动态分区只有在SQL执行时才能决定。

### 二）实战演示如何在hive中使用动态分区

1、创建一张分区表，包含两个分区dt和ht表示日期和小时

```
CREATE TABLE partition_table001   
(  
    name STRING,  
    ip STRING  
)  
PARTITIONED BY (dt STRING, ht STRING)  
ROW FORMAT DELIMITED FIELDS TERMINATED BY "\t";  
```

2、启用hive动态分区，只需要在hive会话中设置两个参数：

```
set hive.exec.dynamic.partition=true;  
set hive.exec.dynamic.partition.mode=nonstrict;
```
3、把partition_table001表某个日期分区下的数据load到目标表partition_table002
使用静态分区时，必须指定分区的值，如：

```
create table if not exists
partition_table002 like partition_table001;

insert overwrite table partition_table002
partition (dt='20150617', ht='00') select name, ip from partition_table001 where dt='20150617' and ht='00';
```

4、使用动态分区

```
insert overwrite table partition_table002 
partition (dt, ht) select * from 
partition_table001 where dt='20150617';
```
hive先获取select的最后两个位置的dt和ht参数值，然后将这两个值填写到insert语句partition中的两个dt和ht变量中，即动态分区是通过位置来对应分区值的。原始表select出来的值和输出partition的值的关系仅仅是通过位置来确定的，和名字并没有关系，比如这里dt和st的名称完全没有关系。
只需要一句SQL即可把20150617下的24个ht分区插到了新表中。

### 三）静态分区和动态分区可以混合使用
1、全部DP

```
INSERT OVERWRITE TABLE T PARTITION (ds, hr) 
SELECT key, value, ds, hr FROM srcpart 
WHERE ds is not null and hr>10;  
```
2、DP/SP结合

```
INSERT OVERWRITE TABLE T PARTITION (ds='2010-03-03', hr)  
SELECT key, value, /*ds,*/ hr FROM srcpart
WHERE ds is not null and hr>10; 
``` 

3、当SP是DP的子分区时，以下DML会报错，因为分区顺序决定了HDFS中目录的继承关系，这点是无法改变的

```
-- throw an exception  
INSERT OVERWRITE TABLE T PARTITION (ds, hr = 11)  
SELECT key, value, ds/*, hr*/ FROM srcpart
WHERE ds is not null and hr=11;  
```

4、多张表插入

```
FROM S  
INSERT OVERWRITE TABLE T PARTITION (ds='2010-03-03', hr)  
SELECT key, value, ds, hr FROM srcpart 
WHERE ds is not null and hr>10  
INSERT OVERWRITE TABLE R PARTITION 
(ds='2010-03-03, hr=12)  
SELECT key, value, ds, hr from srcpart 
where ds is not null and hr = 12;  
```

5、CTAS，（CREATE-AS语句），DP与SP下的CTAS语法稍有不同，因为目标表的schema无法完全的从select语句传递过去。这时需要在create语句中指定partition列

```
CREATE TABLE T (key int, value string) PARTITIONED BY (ds string, hr int) AS  
SELECT key, value, ds, hr+1 hr1 FROM srcpart WHERE ds is not null and hr>10; 
```
 
6、上面展示了DP下的CTAS用法，如果希望在partition列上加一些自己的常量，可以这样做

```
CREATE TABLE T (key int, value string) PARTITIONED BY (ds string, hr int) AS  
SELECT key, value, "2010-03-03", hr+1 hr1 FROM srcpart WHERE ds is not null and hr>10;  
```

四）小结：
通过上面的案例，我们能够发现使用hive中的动态分区特性的最佳实践：对于那些存在很大数量的二级分区的表，使用动态分区可以非常智能的加载表，而在动静结合使用时需要注意静态分区值必须在动态分区值的前面

## hive建分区表
```
create external table if not exists cheap_hotel_user(device string, booking_freq int, book_price string)
partitioned by (day string)
row format delimited fields terminated by '\t'
location '/data/output/search/stage/daily/cheap_hotel_user'

注意的是partition需要在row formate之前指定



添加分区

ALTER TABLE table_name ADD PARTITION (partCol = 'value1') location 'loc1';

ALTER TABLE table_name ADD IF NOT EXISTS PARTITION (dt='20130101') LOCATION '/user/hadoop/warehouse/table_name/dt=20130101'; //一次添加一个分区

ALTER TABLE page_view ADD PARTITION (dt='2008-09-01', country='jp') location '/path/to/us/part080901 PARTITION (dt='2008-09-01', country='jp') location '/path/to/us/part080901';  //一次添加多个分区



删除分区

ALTER TABLE login DROP IF EXISTS PARTITION (dt='2008-09-01');
ALTER TABLE page_view DROP IF EXISTS PARTITION (dt='2008-09-01', country='jp');

修改分区
ALTER TABLE table_name PARTITION (dt='2008-08-08') SET LOCATION "new location";
ALTER TABLE table_name PARTITION (dt='2008-08-08') RENAME TO PARTITION (dt='20080808’);
```

## hive返回星期几的方法
hive返回星期几的方法:pmod(datediff('#date#', '2012年任意一个星期日的日期'), 7) 。2012-01-01刚好是星期日

```
pmod(datediff('#date#', '2012-01-01'), 7)  
```

```
set mapred.job.name=aaaa;

set hive.exec.parallel=true;
set hive.exec.parallel.thread.number=8;
set hive.groupby.skewindata=true;
set hive.optimize.groupby=true;
set hive.map.aggr=true;
set mapred.max.split.size=256000000; 
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.exec.reducers.bytes.per.reducer=256000000;
```

```
beeline -u "jdbc:hive2://localhost:10001/ods" --hiveconf mapreduce.job.name=test01  -e "select * from ods_jz_apply limit 1"  -e "select * from ods_jz_post_hourly limit 1;"
```


## show
```
show databases;
show tables;
show create table xxx;
desc table xxx;
describe table xxx;
show tables '*auction';

```
## hive CONCAT_WS合并的用法
```
mysql> SELECT CONCAT_WS(",","First name","Second name","Last Name");
       -> 'First name,Second name,Last Name'
mysql> SELECT CONCAT_WS(",","First name",NULL,"Last Name");
       -> 'First name,Last Name'
```

## Hive 的collect_set使用详解
```
hive 工作中用到的一些函数
1. concat(string s1, string s2, string s3)
这个函数能够把字符串类型的数据连接起来，连接的某个元素可以是列值。
如 concat( name, ‘:’, score) 就相当于把 name 列和 score 列用逗号连接起来了
2. cast
用法：cast(value AS TYPE)
功能：将某个列的值显示的转化为某个类型
例子：cast(score as string ) 将 double 类型的数据转化为了 String 类型
3. contact_ws(seperator, string s1, string s2…)
功能：制定分隔符将多个字符串连接起来
例子：常常结合 group by 与 collect_set 使用
有表结构 a string , b string , c int
数据为
c d 1
c d 2
c d 3
e f 4
e f 5
e f 6
想要得到
c d 1,2,3
e f 4,5,6
语句如下
select a, b, concat_ws(‘,’ , collect_set(cast(c as string)))
from table group by a,b;

4. 上述用的到的 collect_set 函数，有两个作用，第一个是去重，去除 group by 后的重复元素，
第二个是形成一个集合，将 group by 后属于同一组的第三列集合起来成为一个集合。与 contact_ws
结合使用就是将这些元素以逗号分隔形成字符串
```

### union语法
用来合并多个select的查询结果，需要保证select中字段须一致，每个select语句返回的列的数量和名字必须一样，否则，一个语法错误会被抛出。

从语法中可以看出UNION有两个可选的关键字：

* 使用DISTINCT关键字与使用UNION 默认值效果一样，都会删除重复行 
* 使用ALL关键字，不会删除重复行，结果集包括所有SELECT语句的匹配行（包括重复行）

DISTINCT union可以显式使用UNION DISTINCT，也可以通过使用UNION而不使用以下DISTINCT或ALL关键字来隐式生成。

UNION在FROM子句内

```
SELECT *
FROM (
  select_statement
  UNION ALL
  select_statement
) unionResultAlias

```

例如，假设我们有两个不同的表分别表示哪个用户发布了一个视频，以及哪个用户发布了一个评论，那么下面的查询将UNION ALL的结果与用户表join在一起，为所有视频发布和评论发布创建一个注释流：

```
SELECT u.id, actions.date
FROM (
    SELECT av.uid AS uid
    FROM action_video av
    WHERE av.date = '2008-06-03'
    UNION ALL
    SELECT ac.uid AS uid
    FROM action_comment ac
    WHERE ac.date = '2008-06-03'
 ) actions JOIN users u ON (u.id = actions.uid)
```

```
如果要对单个SELECT语句应用ORDER BY，SORT BY，CLUSTER BY，DISTRIBUTE BY或LIMIT，请将该子句放在括在SELECT中的括号内：
SELECT key FROM (SELECT key FROM src ORDER BY key LIMIT 10)subq1
UNION
SELECT key FROM (SELECT key FROM src1 ORDER BY key LIMIT 10)subq2

如果要对整个UNION结果应用ORDER BY，SORT BY，CLUSTER BY，DISTRIBUTE BY或LIMIT子句，请在最后一个之后放置ORDER BY，SORT BY，CLUSTER BY，DISTRIBUTE BY或LIMIT。 以下示例使用ORDER BY和LIMIT子句：

SELECT key FROM src
UNION
SELECT key FROM src1 
ORDER BY key LIMIT 10

```

### Hive导出指定分隔符
业务场景：
  做数据分析的时候，经常会用到hive -e "sql" > result.csv，然后将结果导入到excel中，可是使用hive -e导出后默认的分隔符是\t，excel无法识别，所以需要将\t转成,
  
方案一：使用linux管道符替换

```
hive -e "select * from table_name limit 100" | sed 's/\t/,/g' > result.csv

或者
hive -e "select * from table_name limit 100" | tr "\t" "," > result.csv
```

方案二：使用hive的insert语法导出文件

```
insert overwrite local directory '/home/hadoop/20180303'
row format delimited
fields terminated by ','
select * from table_name limit 100

```

```
with c1 
as (select count（*） as aa from test1 ),
c2
as (select count（*）　as bb from test2)
select a.aa/b.bb from c1 a, c2 b ; 
```

### Hive分析窗口函数(一) SUM,AVG,MIN,MAX
[http://www.aboutyun.com/thread-12831-1-1.html](http://www.aboutyun.com/thread-12831-1-1.html)

(一) SUM,AVG,MIN,MAX

```
	CREATE EXTERNAL TABLE lxw1234 (
    cookieid string,
    createtime string, --day
    pv INT
    ) ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ','
    stored as textfile location '/tmp/lxw11/';
     
    DESC lxw1234;
    cookieid STRING
    createtime STRING
    pv INT
     
    hive> select * from lxw1234;
    OK
    cookie1 2015-04-10 1
    cookie1 2015-04-11 5
    cookie1 2015-04-12 7
    cookie1 2015-04-13 3
    cookie1 2015-04-14 2
    cookie1 2015-04-15 4
    cookie1 2015-04-16 4
    
    
    SELECT cookieid,
    createtime,
    pv,
    SUM(pv) OVER(PARTITION BY cookieid ORDER BY createtime) AS pv1, -- 默认为从起点到当前行
    SUM(pv) OVER(PARTITION BY cookieid ORDER BY createtime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS pv2, --从起点到当前行，结果同pv1
    SUM(pv) OVER(PARTITION BY cookieid) AS pv3,        --分组内所有行
    SUM(pv) OVER(PARTITION BY cookieid ORDER BY createtime ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS pv4, --当前行+往前3行
    SUM(pv) OVER(PARTITION BY cookieid ORDER BY createtime ROWS BETWEEN 3 PRECEDING AND 1 FOLLOWING) AS pv5, --当前行+往前3行+往后1行
    SUM(pv) OVER(PARTITION BY cookieid ORDER BY createtime ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS pv6 ---当前行+往后所有行
    FROM lxw1234;
     
    cookieid createtime pv pv1 pv2 pv3 pv4 pv5 pv6
    -----------------------------------------------------------------------------
    cookie1 2015-04-10 1 1 1 26 1 6 26
    cookie1 2015-04-11 5 6 6 26 6 13 25
    cookie1 2015-04-12 7 13 13 26 13 16 20
    cookie1 2015-04-13 3 16 16 26 16 18 13
    cookie1 2015-04-14 2 18 18 26 17 21 10
    cookie1 2015-04-15 4 22 22 26 16 20 8
    cookie1 2015-04-16 4 26 26 26 13 13 4
    
pv1: 分组内从起点到当前行的pv累积，如，11号的pv1=10号的pv+11号的pv, 12号=10号+11号+12号
pv2: 同pv1
pv3: 分组内(cookie1)所有的pv累加
pv4: 分组内当前行+往前3行，如，11号=10号+11号， 12号=10号+11号+12号， 13号=10号+11号+12号+13号， 14号=11号+12号+13号+14号
pv5: 分组内当前行+往前3行+往后1行，如，14号=11号+12号+13号+14号+15号=5+7+3+2+4=21
pv6: 分组内当前行+往后所有行，如，13号=13号+14号+15号+16号=3+2+4+4=13，14号=14号+15号+16号=2+4+4=10

如果不指定ROWS BETWEEN,默认为从起点到当前行;
如果不指定ORDER BY，则将分组内所有值累加;
关键是理解ROWS BETWEEN含义,也叫做WINDOW子句：
PRECEDING：往前
FOLLOWING：往后
CURRENT ROW：当前行
UNBOUNDED：起点，UNBOUNDED PRECEDING 表示从前面的起点， UNBOUNDED FOLLOWING：表示到后面的终点
–其他AVG，MIN，MAX，和SUM用法一样。
```
(二) NTILE,ROW_NUMBER,RANK,DENSE_RANK

```
    SELECT
    cookieid,
    createtime,
    pv,
    NTILE(2) OVER(PARTITION BY cookieid ORDER BY createtime) AS rn1,        --分组内将数据分成2片
    NTILE(3) OVER(PARTITION BY cookieid ORDER BY createtime) AS rn2, --分组内将数据分成3片
    NTILE(4) OVER(ORDER BY createtime) AS rn3 --将所有数据分成4片
    FROM lxw1234
    ORDER BY cookieid,createtime;
     
    cookieid day pv rn1 rn2 rn3
    -------------------------------------------------
    cookie1 2015-04-10 1 1 1 1
    cookie1 2015-04-11 5 1 1 1
    cookie1 2015-04-12 7 1 1 2
    cookie1 2015-04-13 3 1 2 2
    cookie1 2015-04-14 2 2 2 3
    cookie1 2015-04-15 4 2 3 3
    cookie1 2015-04-16 4 2 3 4
    cookie2 2015-04-10 2 1 1 1
    cookie2 2015-04-11 3 1 1 1
    cookie2 2015-04-12 5 1 1 2
    cookie2 2015-04-13 6 1 2 2
    cookie2 2015-04-14 3 2 2 3
    cookie2 2015-04-15 9 2 3 4
    cookie2 2015-04-16 7 2 3 4

```
NTILE
NTILE(n)，用于将分组数据按照顺序切分成n片，返回当前切片值
NTILE不支持ROWS BETWEEN，比如 NTILE(2) OVER(PARTITION BY cookieid ORDER BY createtime ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
如果切片不均匀，默认增加第一个切片的分布

```
    SELECT
    cookieid,
    createtime,
    pv,
    NTILE(2) OVER(PARTITION BY cookieid ORDER BY createtime) AS rn1,        --分组内将数据分成2片
    NTILE(3) OVER(PARTITION BY cookieid ORDER BY createtime) AS rn2, --分组内将数据分成3片
    NTILE(4) OVER(ORDER BY createtime) AS rn3 --将所有数据分成4片
    FROM lxw1234
    ORDER BY cookieid,createtime;
     
    cookieid day pv rn1 rn2 rn3
    -------------------------------------------------
    cookie1 2015-04-10 1 1 1 1
    cookie1 2015-04-11 5 1 1 1
    cookie1 2015-04-12 7 1 1 2
    cookie1 2015-04-13 3 1 2 2
    cookie1 2015-04-14 2 2 2 3
    cookie1 2015-04-15 4 2 3 3
    cookie1 2015-04-16 4 2 3 4
    cookie2 2015-04-10 2 1 1 1
    cookie2 2015-04-11 3 1 1 1
    cookie2 2015-04-12 5 1 1 2
    cookie2 2015-04-13 6 1 2 2
    cookie2 2015-04-14 3 2 2 3
    cookie2 2015-04-15 9 2 3 4
    cookie2 2015-04-16 7 2 3 4
    
–比如，统计一个cookie，pv数最多的前1/3的天
```

ROW_NUMBER

ROW_NUMBER() –从1开始，按照顺序，生成分组内记录的序列
–比如，按照pv降序排列，生成分组内每天的pv名次
ROW_NUMBER() 的应用场景非常多，再比如，获取分组内排序第一的记录;获取一个session中的第一条refer等。


RANK 和 DENSE_RANK
—RANK() 生成数据项在分组中的排名，排名相等会在名次中留下空位
—DENSE_RANK() 生成数据项在分组中的排名，排名相等会在名次中不会留下空位

```
    SELECT
    cookieid,
    createtime,
    pv,
    RANK() OVER(PARTITION BY cookieid ORDER BY pv desc) AS rn1,
    DENSE_RANK() OVER(PARTITION BY cookieid ORDER BY pv desc) AS rn2,
    ROW_NUMBER() OVER(PARTITION BY cookieid ORDER BY pv DESC) AS rn3
    FROM lxw1234
    WHERE cookieid = 'cookie1';
     
    cookieid day pv rn1 rn2 rn3
    --------------------------------------------------
    cookie1 2015-04-12 7 1 1 1
    cookie1 2015-04-11 5 2 2 2
    cookie1 2015-04-15 4 3 3 3
    cookie1 2015-04-16 4 3 3 4
    cookie1 2015-04-13 3 5 4 5
    cookie1 2015-04-14 2 6 5 6
    cookie1 2015-04-10 1 7 6 7
     
    rn1: 15号和16号并列第3, 13号排第5
    rn2: 15号和16号并列第3, 13号排第4
    rn3: 如果相等，则按记录值排序，生成唯一的次序，如果所有记录值都相等，或许会随机排吧。
```
(四) LAG,LEAD,FIRST_VALUE,LAST_VALUE
[http://www.aboutyun.com/thread-12848-1-1.html](http://www.aboutyun.com/thread-12848-1-1.html)

LAG(col,n,DEFAULT) 用于统计窗口内往上第n行值
第一个参数为列名，第二个参数为往上第n行（可选，默认为1），第三个参数为默认值（当往上第n行为NULL时候，取默认值，如不指定，则为NULL）

```
SELECT cookieid,
createtime,
url,
ROW_NUMBER() OVER(PARTITION BY cookieid ORDER BY createtime) AS rn,
LAG(createtime,1,'1970-01-01 00:00:00') OVER(PARTITION BY cookieid ORDER BY createtime) AS last_1_time,
LAG(createtime,2) OVER(PARTITION BY cookieid ORDER BY createtime) AS last_2_time 
FROM lxw1234;


last_1_time: 指定了往上第1行的值，default为'1970-01-01 00:00:00'  
             cookie1第一行，往上1行为NULL,因此取默认值 1970-01-01 00:00:00
             cookie1第三行，往上1行值为第二行值，2015-04-10 10:00:02
             cookie1第六行，往上1行值为第五行值，2015-04-10 10:50:01
last_2_time: 指定了往上第2行的值，为指定默认值
				cookie1第一行，往上2行为NULL
            	cookie1第二行，往上2行为NULL
             	cookie1第四行，往上2行为第二行值，2015-04-10 10:00:02
             	cookie1第七行，往上2行为第五行值，2015-04-10 10:50:01
```

LEAD

与LAG相反
LEAD(col,n,DEFAULT) 用于统计窗口内往下第n行值
第一个参数为列名，第二个参数为往下第n行（可选，默认为1），第三个参数为默认值（当往下第n行为NULL时候，取默认值，如不指定，则为NULL）


FIRST_VALUE

取分组内排序后，截止到当前行，第一个值

```
SELECT cookieid,
createtime,
url,
ROW_NUMBER() OVER(PARTITION BY cookieid ORDER BY createtime) AS rn,
FIRST_VALUE(url) OVER(PARTITION BY cookieid ORDER BY createtime) AS first1 
FROM lxw1234;
```

LAST_VALUE

取分组内排序后，截止到当前行，最后一个值
如果想要取分组内排序后最后一个值，则需要变通一下：
```
SELECT cookieid,
createtime,
url,
ROW_NUMBER() OVER(PARTITION BY cookieid ORDER BY createtime) AS rn,
LAST_VALUE(url) OVER(PARTITION BY cookieid ORDER BY createtime) AS last1,
FIRST_VALUE(url) OVER(PARTITION BY cookieid ORDER BY createtime DESC) AS last2 
FROM lxw1234 
ORDER BY cookieid,createtime;
```

(五) GROUPING SETS,GROUPING__ID,CUBE,ROLLUP

GROUPING SETS

在一个GROUP BY查询中，根据不同的维度组合进行聚合，等价于将不同维度的GROUP BY结果集进行UNION ALL

```
SELECT 
month,
day,
COUNT(DISTINCT cookieid) AS uv,
GROUPING__ID 
FROM lxw1234 
GROUP BY month,day 
GROUPING SETS (month,day) 
ORDER BY GROUPING__ID;

month      day            uv      GROUPING__ID
------------------------------------------------
2015-03    NULL            5       1
2015-04    NULL            6       1
NULL       2015-03-10      4       2
NULL       2015-03-12      1       2
NULL       2015-04-12      2       2
NULL       2015-04-13      3       2
NULL       2015-04-15      2       2
NULL       2015-04-16      2       2


等价于 
SELECT month,NULL,COUNT(DISTINCT cookieid) AS uv,1 AS GROUPING__ID FROM lxw1234 GROUP BY month 
UNION ALL 
SELECT NULL,day,COUNT(DISTINCT cookieid) AS uv,2 AS GROUPING__ID FROM lxw1234 GROUP BY day
```
再如

```
SELECT 
month,
day,
COUNT(DISTINCT cookieid) AS uv,
GROUPING__ID 
FROM lxw1234 
GROUP BY month,day 
GROUPING SETS (month,day,(month,day)) 
ORDER BY GROUPING__ID;

month         day             uv      GROUPING__ID
------------------------------------------------
2015-03       NULL            5       1
2015-04       NULL            6       1
NULL          2015-03-10      4       2
NULL          2015-03-12      1       2
NULL          2015-04-12      2       2
NULL          2015-04-13      3       2
NULL          2015-04-15      2       2
NULL          2015-04-16      2       2
2015-03       2015-03-10      4       3
2015-03       2015-03-12      1       3
2015-04       2015-04-12      2       3
2015-04       2015-04-13      3       3
2015-04       2015-04-15      2       3
2015-04       2015-04-16      2       3


等价于
SELECT month,NULL,COUNT(DISTINCT cookieid) AS uv,1 AS GROUPING__ID FROM lxw1234 GROUP BY month 
UNION ALL 
SELECT NULL,day,COUNT(DISTINCT cookieid) AS uv,2 AS GROUPING__ID FROM lxw1234 GROUP BY day
UNION ALL 
SELECT month,day,COUNT(DISTINCT cookieid) AS uv,3 AS GROUPING__ID FROM lxw1234 GROUP BY month,day
```
其中的 GROUPING__ID，表示结果属于哪一个分组集合。

CUBE

根据GROUP BY的维度的所有组合进行聚合。

```
SELECT 
month,
day,
COUNT(DISTINCT cookieid) AS uv,
GROUPING__ID 
FROM lxw1234 
GROUP BY month,day 
WITH CUBE 
ORDER BY GROUPING__ID;


month                              day             uv     GROUPING__ID
--------------------------------------------
NULL            NULL            7       0
2015-03         NULL            5       1
2015-04         NULL            6       1
NULL            2015-04-12      2       2
NULL            2015-04-13      3       2
NULL            2015-04-15      2       2
NULL            2015-04-16      2       2
NULL            2015-03-10      4       2
NULL            2015-03-12      1       2
2015-03         2015-03-10      4       3
2015-03         2015-03-12      1       3
2015-04         2015-04-16      2       3
2015-04         2015-04-12      2       3
2015-04         2015-04-13      3       3
2015-04         2015-04-15      2       3



等价于
SELECT NULL,NULL,COUNT(DISTINCT cookieid) AS uv,0 AS GROUPING__ID FROM lxw1234
UNION ALL 
SELECT month,NULL,COUNT(DISTINCT cookieid) AS uv,1 AS GROUPING__ID FROM lxw1234 GROUP BY month 
UNION ALL 
SELECT NULL,day,COUNT(DISTINCT cookieid) AS uv,2 AS GROUPING__ID FROM lxw1234 GROUP BY day
UNION ALL 
SELECT month,day,COUNT(DISTINCT cookieid) AS uv,3 AS GROUPING__ID FROM lxw1234 GROUP BY month,day
```

ROLLUP

是CUBE的子集，以最左侧的维度为主，从该维度进行层级聚合。

```
比如，以month维度进行层级聚合：
SELECT 
month,
day,
COUNT(DISTINCT cookieid) AS uv,
GROUPING__ID  
FROM lxw1234 
GROUP BY month,day
WITH ROLLUP 
ORDER BY GROUPING__ID;

month                              day             uv     GROUPING__ID
---------------------------------------------------
NULL             NULL            7       0
2015-03          NULL            5       1
2015-04          NULL            6       1
2015-03          2015-03-10      4       3
2015-03          2015-03-12      1       3
2015-04          2015-04-12      2       3
2015-04          2015-04-13      3       3
2015-04          2015-04-15      2       3
2015-04          2015-04-16      2       3

可以实现这样的上钻过程：
月天的UV->月的UV->总UV

--把month和day调换顺序，则以day维度进行层级聚合：

SELECT 
day,
month,
COUNT(DISTINCT cookieid) AS uv,
GROUPING__ID  
FROM lxw1234 
GROUP BY day,month 
WITH ROLLUP 
ORDER BY GROUPING__ID;


day                                month              uv     GROUPING__ID
-------------------------------------------------------
NULL            NULL               7       0
2015-04-13      NULL               3       1
2015-03-12      NULL               1       1
2015-04-15      NULL               2       1
2015-03-10      NULL               4       1
2015-04-16      NULL               2       1
2015-04-12      NULL               2       1
2015-04-12      2015-04            2       3
2015-03-10      2015-03            4       3
2015-03-12      2015-03            1       3
2015-04-13      2015-04            3       3
2015-04-15      2015-04            2       3
2015-04-16      2015-04            2       3

可以实现这样的上钻过程：
天月的UV->天的UV->总UV
（这里，根据天和月进行聚合，和根据天聚合结果一样，因为有父子关系，如果是其他维度组合的话，就会不一样）
```


```
1）创建测试表：
use mart_flow_test;
create table if not exists mart_flow_test.detail_flow_test
(
    union_id          string    comment '设备唯一标识'
) comment '测试表'
partitioned by (
    partition_date    string    comment '日志生成日期'
) stored as orc;
（2）新增字段：use mart_flow_test;
    alter table detail_flow_test add columns(original_union_id string);
（3）修改注释：use mart_flow_test;
    alter table detail_flow_conversion_base_raw change column original_union_id original_union_id string COMMENT'原始设备唯一性标识’;
    
------------------------------
--1.语法
alter table 表名 add columns (列名 类型 [comment '注释']);
其中comment部分是可选的。
 
--2.举例
--添加单个字段
alter table bron_lpss_lpss_order_info_cur add columns(account_type string);
 
--添加多个字段
alter table bron_lpss_lpss_order_info_cur add columns
(
order_source string comment '订单来源',
mid string comment '新会员id',
bank_name string comment '银行行名'
);
 
 
--补充: 修改comment
alter table bron_lpss_lpss_order_info_cur change column bank_name bank_name string comment '分行/支行名称' 

```
### Hive设置参数的三种方法
方法一：
　　在Hive中，所有的默认配置都在${HIVE_HOME}/conf/hive-default.xml文件中，如果需要对默认的配置进行修改，可以创建一个hive-site.xml文件，放在${HIVE_HOME}/conf目录下。里面可以对一些配置进行个性化设定。在hive-site.xml的格式如下：

```
<configuration>

    <property>

        <name>hive.metastore.warehouse.dir</name>

        <value>/user/hive/warehouse</value>

        <description>location of

              default database for the warehouse</description>

    </property>

</configuration>
```
　　所有的配置都是放在<configuration></configuration>标签之间，一个configuration标签里面可以存在多个<property></property>标签。<name>标签里面就是我们想要设定属性的名称；<value>标签里面是我们想要设定的值；<description;<标签是描述在这个属性的，可以不写。绝大多少配置都是在xml文件里面配置的，因为在这里做的配置都全局用户都生效，而且是永久的。用户自定义配置会覆盖默认配置。另外，Hive也会读入Hadoop的配置，因为Hive是作为Hadoop的客户端启动的，Hive的配置会覆盖Hadoop的配置
　　

方法二：
在启动Hive cli的时候进行配置，可以在命令行添加-hiveconf param=value来设定参数，例如：

```
hive --hiveconf mapreduce.job.queuename=queue1
```

方法三：
在已经进入cli时进行参数声明，可以在HQL中使用SET关键字设定参数，例如：

```
set mapreduce.job.queuename=queue1;
```

我们可以得到mapreduce.job.queuename=queue1。如果set后面什么都不添加，这样可以查到Hive的所有属性配置，如下：

```
hive> set;
datanucleus.autoCreateSchema=true
datanucleus.autoStartMechanismMode=checked
datanucleus.cache.level2=false
datanucleus.cache.level2.type=none
```

### Hive实现自增列
1、用row_number()函数生成代理键

```
insert into table id_test 

select row_number() over() + t2.max_id as id, t1.name 
from (select name from nametb) t1 

cross join (select coalesce(max(id),0) max_id from id_test) t2;
```
2、用UDFRowSequence生成代理键 

```
add jar /usr/local/hive.bak/lib/hive-contrib-2.1.1.jar;

create temporary function row_sequence as 'org.apache.hadoop.hive.contrib.udf.udfrowsequence';   
  
insert into tbl_dim    
select row_sequence() + t2.sk_max,
nametb.* from nametb
cross join (select coalesce(max(sk),0) sk_max from tbl_dim) t2;
```

### hive url decode
```
select reflect("java.net.URLDecoder", "decode", trim(字段名), "UTF-8")  from 库名.表名  limit 10;

select reflect("java.net.URLDecoder", "decode", "%2fjianzhi%2fcandidate%2frecommend", "UTF-8")
```