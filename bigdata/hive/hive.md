# Hive编程指南
## 每二章 基础操作
### Hive 是什么
> 所有的hive客户端都需要一个metastoreservice(无数据服务)


### 2.6Hive命令
### 2.7Hive命令行界面

#### hive中的变量和属性命名军空间

###
命名空间     | 使用权限 | 描述
-------- | --- |---
hivevar| r/w |用户自定
hiveconf    | r/w | hive相关的配置属性
system     | r/w |Java定义的配置属性
env | w | shell环境定义的环境变量

```
hive --hiveconf 可以指定当会命名空间

//set
hive> set hivevar:foo=bar2;
//get
hive> set hivevar:foo

//一次使用命令 加上 -S 可以去掉ok, time taken 等字符, 然后重定向输入文件
hive -e "selct * from table limit 3";

//查找历史命令
hive -S -e "set" | grep warehouse

//从文件中执行hive查询
hive -f /path/to/file/hive.sql

//源数据
create table src(s string);
echo "one row" > /tmp/myfile
hive -e "load data local inpath '/tmp/myfile' into table src";

//可以把频繁执行的命令放入hiverc文件
//在$HOME/.hiverc写入以下内容:
ADD JAR /path/to/custom_live.extensions.jar;
set useSSL=true;
set hive.cli.print.current.db=true;//修改cli提示符为当前所在数据库
set hive.exec.model.local.auto=true;//鼓励使用本地模式

//tab可以自动补全

//执行shell命令
hive> ! /bin/echo "what up dog";
//hive中使用hodoop的dfs命令,只需要去掉hadoop就可以
hive>dfs -ls /;

//hive注释以--开头.如:
--This is best hive script.
select * from ...

//显示字段名称
hive> set hive.cli.print.header=true;

```

## 第三章 数据类型和文件格式
### 基本数据类型
数据类型 | 长度 | 例子
-----| --- | ---
TINYINT ||
SAMLLINT||
INT||
BIGINT||
BOOLEAN||
FLOAT||
DOUBLE||
STRING||
TIMESTAMP(v0.8.0+)|整数,浮点数或字符串|
BINARY(v0.8.0+)|字节数组|

### 集合数据类型
数据类型 | 描述 | 字面语法示例
---- | --- | ---
STRUCT |结构体对象,可以通过点访问元素内容 |struct('John', 'Doe')
MAP |键-值对元组集合| map()
ARRAY |相同类型和名称的变量的集合|

```
create table employees(
	name string,
	salary float,
	suborinates array(string),
	deductions map(string, float),
	address struct<street:string, city:string, state:string, zip:int>
);
```
hive有默认的记录和字段分割符

分隔符 | 描述
----| ---
\n | 换持符
^A(Ctrl+A)|用于分割字段(列),在create table时可以用八进制编码\001表示
^B | 用于分隔array或struct中的元素,或于map中键-值对之间分隔,在create table中可以用八进制\002表示
^C | 用于map中键-值之间的分隔,在create table语句中可以以八进制\003表示.

```
create table employees(
	name string,
	salary float,
	suborinates array(string),
	deductions map(string, float),
	address struct<street:string, city:string, state:string, zip:int>
)
row format delimited
fieleds terminated by '\001',
collection items terminated by '\002',
map keys terminated by '\003',
lines terminated by '\n',
stored as textfile;
```

下表数据按逗号进行分割:
```
create tabel some_data(
	first float,
	second float,
	third float,
)
row format delimited
fields terminated by ',';
```

### 读时模式
hive不会在数据加载时进行验证,而是在查询时进行,所以是读时模式(schema on read)

如果不每行记录中的字段个数少于对应的模式中定义的字段的个数,那么查询的结果有很多的null值,如果某些字段是数值型的,但hive在读取时发现存储在非数据值型的字符串时,那些字段将返回null值.

## 第4章 HiveQL:数据定义
hive 不支持行级插入操作,更新操作和删除操作,也不支持事务.

### Hive中的数据库
hive中的数据库本质是仅是表的一个目录或是命名空间.

```
hive> create database if not exists financials;

//用正则表达式筛选数据
hive>show databases like 'h.*';

//手动指定位置
hive>create database financials location '/path/to/data'

//添加注释
hive>cteate database financials 
comment 'holds all financial tables';

//查看库信息
hive>describe database financials;

//use
hive>user financials;

//删除数据库
hive>drop database if exists financials;

//删除有表的数据库
hive>drop database if exists financial cascade;
/如果是restrict,cascade也不可使,必须删除所有表才能删了库

//修改数据库
hive>alter database financials set dbproperties('edited-by'='Joe Dba');

//创建表
create table if not exists mydb.employees(
	name string comment 'employee name',
	salary float commnet 'employee salary',
	subordinates array<string> commnet 'names of subordinates',
	deductions mpa<string, float> comment 'keys ar deductions names, values are precentages',
	address struct<street:string, city:string, state:string, zip:int> comment 'home address'
) comment 'description of the table'
tblproperties ('creator'='me', 'created_at'='2013-12-12')
location '/user/hive/warehouse/mydb.db/employees'

//hive会自动增加两个属性:last_modified_by, last_moditfied_time;

//拷贝一张表的表模式,不带数据
create table if not exist mydb.employee2 
like mydb.employees;

//查看表详细信息
hive>describe extended mydb.employees;
hive>describe mydb.employees.salary;

//external,这个表是外部的,删除该表并不会外部数据,不过表的元数据会被删除
create external table if not exists stocks(
	exchange string,
	...
)
row formated fields terminated by ',',
location '/data/stocks';

//查看表是否是外部表
hive>describe extended tablename;

//数据分区
create table employees(
name string,
salary float,
suborinates array<string>,
deductions map<string, float>,
address struct<street:string, city:string, state:string, zip:int>) partitioned by (country string, state string);


//查看表的分区
hive>show partitions employees;
hive>show partitions employees partition(country='US');
hive>describe extended employees;
hive>describe extended log_messages partition(year=2012, month=1, day=2);

//load 数据
load data local inpath '/path/to/file' into table employees partition(country='US', stata='CA');


//外部分区表
create external table if not exists log_messages(
hms int,
severity string,
server string,
process_id int,
message string
)
partitioned by (year int, month int, day int)
row format delimited fields terminated by '\t';

//修改表,修改分区
alter table log_messages add 
partition(year=2012, month=1, day=2) 
location 'hdfs://......';

//自定义表的存储格式
SEQUENCEFILE, RCFILE, 这两种格式都是有二进制编码和压缩(可选)

create external table if not exists stocks(
exchage string,
symbol string,
ymd string,
price_open float,
price_high float,
price_how float,
price_close float,
volume int,
price_adj_close float
)
clustered by (exchange, symbol)
sorted by (ymd asc)
insert 96 buckets
row format delimited fields terminated by ','
location '/data/stocks';


//表重命名
alter table log_messages rename to logmsgs;

//增加,修改,删除表分区
alter table log_messages add if not exists
partition (year=2011, month=1, day=1) location '/logs/2011/01/01',
.....;
alter table log_messages drop if not exists
partition (year=2011, month=1, day=1) location '/logs/2011/01/01'

//修改列信息
alter table log_messages
change column hms hours_minutes_seconds int
comment 'the hours, minutes, and seconds part of the timestamp'
after serverity;

//增加列
alter table log_messages add columns(
app_name string comment 'application name',
session_id long comment 'the current id'
);

//删除或替换列
alter table log_messages replace columns(
hours_mins_secs int comment 'hour, minutes, ...',
serverity string comment '...',
message string comment '...'
);

//修改存储属性
alter table log_messages
partition(year=2013, month=1, day=1)
set fileformat sequencefile;

alter table using_json_storge
set serde 'com.example.JSONSerDe'
with serdeproperties(
'prop1'='value1',
'prop2'='value2'
);

//防止被删除 enable disable
alter table log_messages partition(year=1012, month=1, day=1) enable NO_DROP;
//防止被查询
alter table log_messages partition(year=2012, month=1,day=1) enable OFF_LINE;
```

## 第5章 HiveQL:数据操作
```
//向管理表中装载数据 overwrite会删除目标文件夹中之前存在的数据
//inpath中不可能包含文件夹
load data local inpath '/home/work/src/programming_hive/data/employees'
overwrite into table employees
partition(country='US', state='CA');

//插入数据
from staged_employees se
insert overwrite table employees
	partition(contry='US', state='OR')
		select * where se.cnty = 'US' and se.st='OE'
....;

//动态分区
insert overwrite table employees
partition(country, state)
select ..., se.cnty, se.st from staged_employees se;

//单个查询语句中创建表并加载数据
create table ca_employees
as select name, salary address
from employees se where se.state='CA';

//导出数据
hadoop fd -cp source_path target_path
或者
insert overwrite local DIRECTORY '/tmp/employees'
select name, salary, address
from employees se
where se.state = 'CA';

//导出数据至多个文件目录
from staged_employees se
insert overwrite directory '/tmp/or_employees'
	select * where se.city = 'US' and se.state='OR'
insert overwrite directory '/tmp/ca_employees'
	select * from se.city = 'US' and se.state='CA'
....;
```

## 第6章 HiveQL:查询
```
select name, salary from employees;
select name, suborinates from employees;
select name, deductions from employees;
select name, address from employees;

//引用集合元素
select name, suborinates[0] from employees;

//引用map元素
select name, deductions['State Taxes'] from employees;

//引用struct元素
select name, address.city from employees;

//使用正则表达
select symbol, `price.*` from stocks;

//使用列值进行计算
select upper(name), salary, deductions['Federal Taxes'],
round(salary * (1-deductions['Federal Taxes'])) 
from employees;


```

算术运算符

当进行算术运算时,注意数据溢出或下溢,乘法和除法会引发这个问题

数学函数

返回值类型 | 样式 | 描述
---|---|---
BIGINT | round(DOUBLE D)| --
DOUBLE | round(DOUBLE d, INT n) |--
BIGINT | floor(DOUBLE d) |
BIGINT | ceil(DOUBLE d), ceiling(DOUBLE d)
DOUBLE | rand(), rand(INT, seed) |
DOUBLE | exp(DOUBLE d) |
DOUBLE | ln(DOUBLE d)|
DOUBLE | log10(DOUBLE d) |
DOUBLE | log2(DOUBLE d)|
DOUBLE | log(DOUBLE base, DOUBLE d)|
DOUBLE | pow(DOUBLE d, DOUBLE p) |
DOUBLE | sqrt(DOUBLE d)
STRING | bin(DOUBLE i) |
STRING | hex(DOUBLE i) |
STRING | hex(STRING i) |
STRING | unhex(STRING i)|
STRING | conv(BIGINT num, INT from_base, INT to_base)| 
STRING | conv(STRING num, INT from_bae, INT to_base) |
DOUBLE | ads(DOUBLE d) |
INT | pmod(INT i1, INT i2) |
DOUBLE | pmod(DOUBLE d1, DOUBLE d2) |
DOUBLE | sin(DOUBLE d)|
DOUBLE | asin(DOUBLE d) |
DOUBLE | cos(DOUBLE d) |
DOUBLE | acos(DOUBLE d) |
 |tan(DOUBLE d)|
 |atan(DOUBLE d)|
 |degree(DOUBLE d)|
 |radians(DOUBLE d)|
 |positive(INT i)|
 |positive(DOUBLE d)|
 |negative(INT i)|
 |negative(DOUBLE d)|
 |sign(DOUBLE d)|
 |e()|
 |pi()|

聚合函数

```
select count(*), avg(salary) from employees;
```

返回值类型|样式|描述
---| --- | ----
 |count(*) |
 |count(expr) |
 |count(distict expr[, expr_.]) |
 |sum(col) |
 |sum(distict col) |
 |avg(col) |
 |avg(distict col) |
 |min(col) |
 |max(col) |
 |varirance(col),var_pop(col) |
 |var_samp(col) |
 |stddev_pop(col) |
 |stddev_samp(col) |
 |covar_pop(col1, col2) |
 |covar_samp(col1, col2) |
 |corr(col1, col2) |
 |percentile(bigint int_expr, p) |
 |percentile(bigint int_expr, array(p1[, p2])) |
 |percentile_approx(double col, p[, nb]) |
 |percentile_approx(double col, array(p1[,p2])[,nb]) |
 |histogram_numeric(col, nb) |
 |collect_set(col) |
 
 ```
 set hive.map.aggr=true;
 select count(*), avg(salary) from table;
 
 select count(distict symbol) from table;
 
 //将一个字段转换成多个字段
 select explode(suborinates) as sub from employees;
 
 //解析url
 select parse_url_tuple(url, 'HOST', 'PATH', 'QUERY') 
 as ('host', 'path', 'query') from url_table;
 
 ```
 
 表生成函数
 
 返回值类型 | 样式 | 描述
 ---|---|---
 N行结果|explode(array d)|返回0到多行结果,每行对应输入的array数组中的一个元素
 N行结果|explode(map d)|返回0到多行结果,每行对应每个map键值对,一个字段是map键,一个是map的值
 数组的类型 | explode(array<type> a) |对于a中的每个元素,explode()会生成一行记录包含这个元素
结果插入表中| inline(array<struct[, strcut]>) | 将结构体数组插入到表中
 tuple | json_tuple(struct jsonStr, p1, p2,...) | 本函数接收多个标签名称,对输入的json字符串进行处理,这个get_json_object这个udf类似
tuple |  parse_url_tuple(url, partname1, partname2....partnamen) n>=1 |从url中解析出n个部分信息
n个结果 | stack(int ,col1, ..., colm) | 把m个列转换成n行,每行有m/n个字段,n必须是常数

其他内置函数

返回值类型|样式|描述
---|---|---
--|--|--

```
//limit 语句
select upper(name), salary, deductions['Federal Taxes'],
round(salary * (1-deductions['Federal Taxes'])) from employees limit 2;

set hive.cli.print.header=true;  // 打印列名 
set hive.cli.print.row.to.vertical=true;   // 开启行转列功能, 前提必须开启打印列名功能 
set hive.cli.print.row.to.vertical.num=1; // 设置每行显示的列数 
set hive.exec.mode.local.auto=true;//本地模式


//列别名
select upper(name) as name, salary, deductions['Federal Taxes'] as fed_taxes,
round(salary * (1-deductions['Federal Taxes'])) as salary_minus_fed_taxes from employees;

//嵌套select语句
from(
select upper(name) as name, salary, deductions['Federal Taxes'] as fed_taxes, 
round(salary * (1-deductions['Federal 
Taxes'])) as salary_minus_fed_taxes from 
employees
) as e
select e.name, e. salary_minus_fed_taxes where e. salary_minus_fed_taxes > 70000;

//case...where...then
select name, salary,
case
when salary < 50000.0 then 'low'
when salary >= 50000.0 and salary < 70000.0 then 'middle'
when salary >= 70000.0 and salary < 100000.0 then 'high'
else 'very hight'
end as bracket from employees;
```

where 语句
```
select upper(name) as name, salary, deductions['Federal Taxes'] as fed_taxes from employees where round(salary * (1-deductions['Federal Taxes'])) >= 70000.0;

//不能在where语句中使用别名
//不过可以使用嵌套
select e.* from
(select name, salary, deductions['Federal 
Taxes'] as ded, salary*(1-deductions['Federal Taxes']) as salary_minus_fed_taxes from employees) as e
where round(e.salary_minus_fed_taxes) > 70000;
```

谓词操作符

操作符|支持数据类型|描述
---|---|---
a = b||
a<=>b||
a==b||错
a<>b, a!=b||
a<b||
a<=b||
a>b||
a>=b||
a [not] between a and c||
a is NULL||
a is not NULL||
a [not] like b||
a rlike a||
a rlike b, regexp b||

```
浮点数比较,出现0.2>0.2
解决的办法有:
	1.修改数据类型
	2.cast转换数据类型
	
select name, salary, deductions['Federal Taxes'] 
from employees where deductions['Federal Taxes'] > 
cast(0.2 as float);


//like和rlike
select name, address.street from employees where 
address.street like '%Ave.';

select name, address.city from employees where 
address.city like 'O%';

//rlike
select name, address.street from employees where 
address.street rlike '.*(Chicago|Ontario).*';


//group by
select year(ymd), avg(price_close) from stocks
where exchange = 'NASDAQ' and symbol='APPL'
group by year(ymd);

//having
select year(ymd), avg(price_close) from stocks
where exchange = 'NASDAQ' and symbol='AAPL'
group by year(umd) having avg(proce_close) > 50.0;
要不然就要嵌套
select s2.year, s2.avg from 
(select year(ymd) as year, avg(price_close) 
as avg from stocks where exchange='NASDAQ' 
and symbol='AAPL' group by year(ymd)) s2 
where s2.avg > 50.0;

//join join只支持等值操作
select a.ymd, a.price_close, b.price_close from 
stocks a join stocks b on a.ymd = b.ymd where 
a.symbol = 'AAPL' and b.symbol = 'IBM';

select s.ymd, s.symbol, s.price_close, d.dividend
from dividend d join stocks s on s.ymd = d.ymd 
and s.symbol = d.symbol where s.symbol = 'AAPL';

//标记查询优化器
select /*+streamtable*/ s.ymd, s.symbol, 
s.price_close, d.dividend
from dividend d join stocks s on s.ymd = d.ymd 
and s.symbol = d.symbol where s.symbol = 'AAPL';

//left outer join
select s.ymd, s.symbol, s.price_close, d.dividend
from stocks s left outer join dividend d 
on s.ymd = d.ymd and s.symbol = d.symbol 
where s.symbol = 'AAPL';

//outer join
select s.ymd, s.symbol, s.price_close, d.dividend
from stocks s left outer join dividend d 
on s.ymd = d.ymd and s.symbol = d.symbol 
where s.symbol = 'AAPL' and s.exchange = 'NASDAQ' 
and d.exchange = 'NASDAQ';

//outer join 这样做会忽略分区, inner join不会
select s.ymd, s.symbol, s.price_close, d.dividend
from stocks s left outer join dividends d 
on s.ymd = d.ymd and s.symbol = d.symbol 
and s.symbol = 'AAPL' and s.exchange = 'NASDAQ' 
and d.exchange = 'NASDAQ';

//嵌套是所有种类连接的解决方案
select s.ymd, s.price_close, d.divdend from 
(select * from stocks where symbol = 'AAPL' 
and exchange = 'NASDAQ') s
left join 
(select * from dividends where symbol = 'AAPL' 
and exchange = 'NASDAQ') d
on s.ymd = d.ymd;

//right outer join
select s.ymd, s.symbol, s.price_close, d.dividend
from dividends d right outer join stocks s 
on d.ymd = s.ymd and d.symbol = s.symbol 
where s.symbol = 'AAPL';

//full outer join
select s.ymd, s.symbol, s.price_close, d.divedend
from dividends d full outer join stocks s 
on d.ymd = s.ymd and d.symbol = s.symbol 
where s.symbol = 'AAPL';

//left semi join 左半开连接
select s.ymd, s.symbol, s.price_close from 
stocks s left semi join dividends d 
on s.ymd = d.ymd and s.symbol = d.symbol;
select和where不能引用到右边表的字段.
hive不支持右半开连接right semi join
semi-join比通常的inner join要高效,
对于左表中的一条指定的记录,在右边表中一旦找到匹配的记录,hive就立刻停止扫描.

//笛卡尔join 左边表的行数乘以右边表的行数就是笛卡尔结果集的大小
set hive.mapred.mode = strict;可以阻止执行笛卡尔积查询

//map-side join
小表优化,可以放到内存里
select /*+mapjoin(d)*/ s.ymd, s.price_close, 
d.divedend from stocks s join dividends d 
on s.ymd = d.ymd and s.symbol = d.symbol 
where s.symbol = 'AAPL';
此标记在v0.7版本废弃, 不过可以set hive.auto.convertJoin = true, 必要的时候进行优化

set hive.auto.convert.join = true;
另外,hive对于 right outer join , full outer join不支持这种优化

set hive.optimize.bucketmapJoin = true;开启桶优化.

//分类-合并连接(sort-mergeJOIN): 数据是按照连接键或桶的键进行排序的
set hive.input.format=org.apache.hadoop.hive.ql.io.BucketizedHiveInputFormat;
set hive.optimize.buckermapjoin = true;
set hive.optimize.buckertmapjoin.sortedmerge = true;

//order by 和 sort by
order by全局排序,通过reduce; sort by 局部排序,可以提高排序效率
select s.ymd, s.symbol, s.price_close from 
stocks s order by s.ymd asc, s.symbol desc;

select s.ymd, s.symbol, s.price_close
from stocks s
sort by s.ymd asc, s.symbol desc;
若hive.mapred.mode = strict;需要加limit

//含有sort by的distribute by
distribute by可保证具有相同哈希值的记录分发到同一个reducer处理
select s.ymd, s.symbol, s.price_close
from stocks s
distribute by s.symbol
sort by s.symbol asc, s.ymd asc;

//cluster by
select s.ymd, s.symbol, s.price_close
from stocks s
cluster by s.symbol;
distrbute by ... sort by 或简版本的cluster by语句会剥夺sort by的并行性,但可以实现数据全局排序.

//cast
select name, salary from employees where
cast(salary as float) < 10000.0;

//binary值转换
select (2.0 * cast(cast(b as string) as double)) from src;

//抽样查询
select * from numbers tablesample(bucket 3
out of 10 on rand()) s;
分子表示选择桶的个数, 分母表示数据将会被散列的根的个数

//数据块抽样
select * from numbersflat tablesample(0.1, percent) s;

//分桶的输入裁剪
select * from numbersflat where
number % 2 = 0;

如查tablesample语句指定的列和cluster by语句中指定的列相同,
tabelsample查询只会热描涉及表的哈希分区下的数据
select  table numbers_bucketed (number int)
cluster by (number) into 3 buckets;
set hive.enforce.bucketing=true;
insert overwrite table numbers_bucketed 
select number from numbers;

//union all,union子查询都必须有相同的列,数据类型一致
select log.ymd, log.level, log.message
from (
select l1.ymd, l1.level, l1.message,
'Log1' as source
from  log1 l1
union all
select l2.ymd, l2.level, l2.message, 'Log2'
as source from log1 l2
) log
sort by log.ymd asc;

//除非源表建立了索引,否则,该查询将会对同一份数据进行多次拷贝分发
form (
from src select src.key, src.value where
src.key < 100
) unioninput
insert overwrite directory '/tmp/union.out'
select unioninput.*
```

## 第7章 HiveQL: 视图
通过使用视图将查询分成多个小的,更可控的片段,来降低复杂度.

```
from (
select * from people join cart
on cart.peopole_id = people.id where 
firstname = 'john'
) a select a.lastname where a.id = 3;
=>
create view shorter_join as 
select * from people join cart
on cart.people_id = people.id where firstname = 'john';
select lastname from shorter_join where id = 3;

//使用视图来限制基于条件过滤的数据
create table userinfo(
firstname string, lastname string,
ssn string, password string
);
create view safer_user_info as select 
firstname, lastname from userinfo;
//限制数据访问
create table employee (
firstname string, lastname string,
ssn string, password string, department
string);
create view techops_employee as select
firstname, lastname, ssn from userinfo
where department='techops';

//动态分区中的视图和map类型
create external table dynamictable(cols 
map<string, string>)
row format delimited
fields terminated by '\004'
collection items terminated by '\001'
map keys terminated by '\002'
stored as textfile;

create view shipment(time, part) as 
select cols['time'], cols['parts']
from dynamictable
where cols['type'] = 'request';

视图所涉及的表或者列不存在时,会导致视图查询失败

//删除视图
drop view if exists shipments;
```

## 第8章 HiveQL:索引

```
//创建表
create table employees(
name string,
salary float,
suborinates array<string>,
deductions map<string, float>,
address struct<street:string, city:string, state:string, zip:int>) partitioned by (country string, state string);


//为上表创建索引
create index demployees_index
on table employees (country)
as 'org.apache.hadoop.hive.sql.index.compact.CompactIndexHandler'
with deferred rebuild
idxpropertites ('creator'='me', 'create_at'='some_time')
in table employees_index_table
partitioned by(country, name)
comment 'Employees indexed by country and name.'

//Bitmap索引,普遍用于排重后值较少的列
create index employees_index
on table employees (country)
as 'BITMAP'
with deferred rebuild
idxproperties ('creator'='me', 'create_at'='some_time')
in table employees_index_table
partitioned by(country, name)
comment 'employees indexed by country and name.';

//重建索引
任何时候,都可以进行每一次索引创建或使用alter index对索引进行重建
alter index employees_index
on table empoyees
partition (country='US')
rebuild;

//显示索引
show formatted index on employees;

//删除索引
drop index if exists employees_index 
on table employees;
```

## 第9章 模式设计
```
//按天划分的表
create table supply_2011_01_02(
id int, part string, quantity int
);
create table supply_2011_02_03(
id int, part string, quantity int
);

select part, quantity from supply_2011_01_02
union all
select part, quantity from supply_2011_02_03
where quantity > 4;

//也可以分区
create table supply (
id int , part string, quantity int
) partitioned by(day int);

alter table supply add partition (day=20110102);
alter table supply add partition (day=20110103)

select part, quantity from supply where
day >= 20110102 and day < 20110103 and quantity < 4;

//分区太多,会导致创建大量非必须的Hadoop文件和文件夹,大量小文件的存储会降低系统速度.
要以考虑多个分区级别或使用'分桶表数据存储'

//同一份数据多种处理
from history
insert overwrite sales select * where 
action = 'purchased'
insert overwrite credits select * where
action = 'returned;'

//多分区
hive -hiveconf dt=2011-01-01
insert overwrite table distict_ip_in_logs
partition (hit_date=${dt})
select distict(ip) as ip from weblogs
where hit_data = '${hiveconf:dt}';

create table state_city_for_day (
state string, city string
) partitioned by (hit_data, string)

insert overwrite table state_city_for_day
partition(${hiveconf:dt})
select distict(state, city)
from distict_ip_in_logs
join geodata on(distict_ip_in_logs.ip = geodata.ip)
where hit_data='${hiveconf:dt}';

//分桶表数据存储
create table webog (
user_id int, url string, source_ip string
) partitioned by(dt string)
clustered by (user_id into 96 buckets;)

//插入数据
set hive.enforce.bucketing = true;
from raw_logs
insert overwrite table weblog
partition (dt='2009-02-25')
select user_id, url, source_ip where dt='2009-02-25'
如果没有hive.enforce.bucketing属性,那么需要手动设置分桶个数相匹配的reducer数
优点:
	桶的数量固定,没有数据波动
	桶对抽样合适
	分桶有利于高效的map-side join

//增加列
create table weblogs (version long, usr string)
partitioned by(hit_data int)
for format delimited fields terminated '\t';

alter table weblogs add columns (user_id string);
load data local inpath 'logs.txt' into 
weblogs partition(20110102)
注意,这种方式无法在已有字段开始或中间增加字段
```

## 第10章 调优
```
//使用explain
expalin select sum(number) from onecol;

join 时将大表放在最靠右的地方

//严格模式
1.对于分区表,除非where有过滤条件来预制范围,否则不允许执行
2.对于order by的语句,必须要有limit
3.笛卡尔积查询 一定要join...on

保持合适的mapper reducer个数,太多的任务会在启动,调动,运行时产生过大的开销.太少则无法充分利用集群央的并行性.

reducer计算公式:
(集群总reducer槽位个数*1.5)/(执行中的查询的平均个数)

动态分区前,必须有一个分区是静态的

如果用户输入数据量很大而需要长时间执行map, reducer, 启动推测执行造成的浪费是巨大的.
```

## 第11章 其他文件格式各压缩方法
gzip压缩的文件对于后面的MapReduce job而言是不可分割的
```
//表归档
alter table hive_text archive partition(folder='docs');

//解档
alter table hive_text unarchive partition(folder='docs');
```

## 第12章 开发
```
//修改Log4j属性
set hive.root.logger=debug,console;
```

## 第13章 函数
```
//显示函数
show functions;
describe function concat;
select concat(column1, column2) as s from table;

select name, sub from employees
lateral view explode(subordinates) subview as sub;

select ip, geoip(source_ip, 'COUNTRY_NAME', './GeoIP.data')
from weblogs;
```
## 第14章 Streaming
```
//恒等变换
select transform (a, b)
using '/bin/cat' as newa, newb from a;

//改变类型
select transform(col1, col2) using '/bin/cat' as (newa int, newb double) from a;

//投影变换
select transform(a, b) using '/bin/cut -fl'
as newa, newb from a;

//操作转换
select transform(a, b) using '/bin/sed s/4/10'
as newa, newb from a;

//添加
add file /path/ctof.sh

//streaming
create table docs (line string);
create talbe word_count (word string, count int)
row format delimited fields terminated by '\t';
from(
from docs select transform(line)
using '/path/mapper.py'
as word, count cluster by word
) wc
insert overwrite table word_count
select transform(wc.word, wc,count)
using '/path/reduce.py'
as word, count;
```

## 第十五章 自定义Hive文件和记录格式
### 文件格式
textfile:
> 文本文件便于其它工具共享数据,但存储空间较大,可以压缩,使用二进制文件存储格式,既节约空间,也提高I/O性能.
sequencefile
> 此文件是含有键值对的二进制文件.可以在块级别和记录级别进行压缩,支持按照块级别文件分割.更高级的二进制文件是RCFile.
rcfile
>列式存储,适合字段多,值少

### 记录格式: SerDe
csv, tsv

## 第16章 Hive的Thrift服务
## 第17章 存储处理程序和NoSQL
## 第18章 安全
```
show grand user edward on database default;
grant select on talbe xxx to group edward;
grant create on database default to user edward;
grant role xxxx to user edward;
grant select on table tt to role user_role;
grant all on table tt to user adward;

//分区权限
```

## 第19章 锁
```
show locks;

//显示锁
lock table people exclusive;

//解锁
unlock table people;

```

## 第20章 Hive和Qozie整合

## 练习案例

```
Hive修改表
Alter Table 语句
它是在Hive中用来修改的表。

语法
声明接受任意属性，我们希望在一个表中修改以下语法。

ALTER TABLE name RENAME TO new_name
ALTER TABLE name ADD COLUMNS (col_spec[, col_spec ...])
ALTER TABLE name DROP [COLUMN] column_name
ALTER TABLE name CHANGE column_name new_name new_type
ALTER TABLE name REPLACE COLUMNS (col_spec[, col_spec ...])
Rename To… 语句
下面是查询重命名表，把 employee 修改为 emp。

hive> ALTER TABLE employee RENAME TO emp;


Change 语句
下表包含employee表的字段，它显示的字段要被更改（粗体）。

字段名	从数据类型转换	更改字段名称	转换为数据类型
eid	int	eid	int
name	String	ename	String
salary	Float	salary	Double
designation	String	designation	String
下面查询重命名使用上述数据的列名和列数据类型：

hive> ALTER TABLE employee CHANGE name ename String;
hive> ALTER TABLE employee CHANGE salary salary Double;


添加列语句
下面的查询增加了一个列名dept在employee表。

hive> ALTER TABLE employee ADD COLUMNS (dept STRING COMMENT 'Department name');

REPLACE语句
以下从employee表中查询删除的所有列，并使用emp替换列：

hive> ALTER TABLE employee REPLACE COLUMNS ( 
   > eid INT empid Int, 
   > ename STRING name String);

```
//导数据案例
```
alter table employees rename to employees_demo;
//mysql
//导出
mysqldump -u 用户名 -p 数据库名 > 导出的文件名
mysqldump -u dbuser -p dbname > dbname.sql

mysqldump -u 用户名 -p 数据库名 表名> 导出的文件名
mysqldump -u dbuser -p dbname users> dbname_users.sql

mysqldump -u dbuser -p -d --add-drop-table dbname >d:/dbname_db.sql
-d 没有数据 --add-drop-table 在每个create语句之前增加一个drop table

//导入
常用source 命令
进入mysql数据库控制台，如
mysql -u root -p
mysql>use 数据库
然后使用source命令，后面参数为脚本文件(如这里用到的.sql)
mysql>source d:/dbname.sql


获取数据 git clone https://github.com/datacharmer/test_db.git
1. mysql> create database employees;
2. mysql -t -uroot -proot < employees.sql
3. sqoop import --connect jdbc:mysql://localhost:3306/employees --username root --password root --table employees --target-dir /user/hive/warehouse/employees

create table employees_mysql (
emp_no int,
birth_date string,
first_name string,
last_name string,
gender string,
)

load data local inpath '/path/to/file' into table employees partition(country='US', stata='CA');

```
```
create data hive;

CREATE TABLE IF NOT EXISTS `web_log`(
   `id` INT UNSIGNED AUTO_INCREMENT,
   `uuid` VARCHAR(512) NOT NULL,
   `timestamp` int NOT NULL,
   `url` VARCHAR(512) not null,
   PRIMARY KEY ( `id` )
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO web_log 
(uuid,timestamp, url)
VALUES
("abc123", "1516595705", '/api/from?name=abc');

INSERT INTO web_log 
(uuid,timestamp, url)
VALUES
("abc123", "1516595705", '/api/article/1234'),
("abc123", "1516595705", '/api/data/player/1234');

alter table web_log add day int unsigned not null;


from (select uuid, split(url, 'name=')[1] as channel from web_log) as log select channel, count(channel) as num where channel != '' group by channel;
```