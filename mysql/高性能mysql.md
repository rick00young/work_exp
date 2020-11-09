#MySql

## 服务器性能剖析

### 诊断间歇性问题

#### 使用SHOW GLOBAL STATUS

```
mysqladmin ext -i1 | awk '
/Queries/{q=$4-qp;qp=$4}
/Threads_connected/{tc=$4}
/Threads_running/{printf "%5d %5d %5d\n", p, tc, $4}'
```

此命令计算并输出每秒的查询数，Threads_connected和Threads_running(表示当前正在执行查询的线程数), 这三个数据的趋势对于服务器级别偶尔停顿的敏感性很高。一般发生此类问题时，根据原因的不同和应用连接数据库的方式的不同，每秒的查询数一般会下跌，而其他两个则至少有一个会出现尖刺。如果应用使用了连接池，Threads_connected没有变化，但正在执行查询的线程数明显上升，同时每秒的查询数相比正常数据有严重的下跌。
如何解析这个现象：

* 其中之一是服务器内部碰到了某种瓶颈，导致新查询在开始执行前因为需要获取老查询正在等待的锁而造成堆积。这一类的锁一般也会对应用服务器造成后端压力，使得应用服务器也出现排队问题

* 另外一个原因是服务区突然遇到了大量查询请求的冲击，比如前端的memcached突然失效导致的查询风暴。 

#### 使用 SHOW PROCESSLIST

```
mysql -e 'SHOW PROCESSLIST\G' | grep State: | sort | uniq -c | sort -rn
```

可以看到线程的状态有:freeing items, end, cleaning up, logging slow query，大量的线程处于'freeing items'状态是出现了大量有问题查询的很明显的特征和指示

如果MySql服务器的版本较新，也可以直接查询INFOMATION_SCHEMA中的PROCESSLIST表；或者使用innotop工具以较高频率刷新。

* InnoDB内部的争用和脏块刷新，会导致线程堆积。
* 一个经典的例子是很多查询处于"Locked"状态，这是MyISAM的一个经典问题，它的表级锁，在写请求较多时，可能迅速导致服务器级别的线程堆积。


间歇性的实际案例有：

* 应用通过curl从一个运行得很慢的外部服务来获取汇率报价的数据
* memecached缓存中一些重要条目过期，导致大量的请求落到MySQL以重新生成缓存条目
* DNS查询偶尔会有超时现象
* 可以能是由于互斥锁争用，或者内部删除查询缓存的算法效率太低的缘故，MySQL的查询缓存有时候会导致服务有短暂的停顿。
* 当并发度超过某个阈值时，InnoDB的扩展性限制查询计划的优化需要很长的时间。

#### 使用查询日志
开启慢日志查询，并在全局级别设置long_query_time为0，并且确认所有的连接都采用了新的设置。或者使用Percona Server的一个特性，可以在不断开现有的连接的情况下动态地使设置强制生效。

如果由于某些原因，不能设置慢查询日志记录所有的查询，也可以通过tcpdump和pt-query-digest工具来模拟替代。

利用脚本根据MySQL每秒将当前时间写入日志中的柜式统计每秒的查询数量。

```
awk '/^# Time:/{print $3, $4, c;c=0}/^# User/{c++}' slow-query.log
```

问题诊断时，建议使用前两方法： SHOW STATUS 和 SHOW PROCESSLIST。这两种方法开销很低，而且可能通过简单的shell脚本或者反复执行的查询来交互式地收集数据。

#### 捕获诊断数据
在开始之前，需要搞清楚两件事：

* 一个可靠且实时的‘触发器’， 也就是能区分什么时候出问题的方法
* 一个收集诊断数据的工具。 

触发器要注意的问题：误报(false positive)或者 漏检(false negative)

```
mysql -e 'SHOW PROCESSLIST\G' | grep -c "State freeing items"
```

触发器的阈值很重要，既要足够高，以确保在正常时不会被触发；又不能太高，要确保问题发生时不会错过。

* Threads_connected正常时不会超过150，将阀值设置为200或300会更好
* Threads_running正常情况下并发度不超过10，当并发线程到15时可能会有少量堆积的线程，建议的阀值是20

ps-stalk可以配置监控的变量，阀值，检查的频率等。

我们需要一种工具来监控服务器。Percona Toolkit中的pt-stalk很特性，可以作为监控工具。

我们需要收集系统的状态，CPU利用率， 磁盘使用率和可用空间，ps的输出采样率，内存利用率，以及可以从MySQL获得的信息，如SHOW STATUS, SHOW PROCESSLIST 和 SHOW INNODA STATUS.

在GNU/Linux平台，可用于服务器内部诊断的一个重要工具是oprofile，也可以用strace剖析服务器的系统调用。

如果剖析查询，可以使用tcpdump。
对于堆栈跟踪，可以使用GDB注入： 先启动gdb，然后附加(attach)到mysqld进程上，将所有的线程的堆栈都转储出来。

查询或事务的行为可以显示是否是由于使用服务器的方式导致的问题：性能低下的SQL查询，使用不当的索引，设计糟糕的数据逻辑架构。

* 通过抓取TCP流量工或是SHOW PROCESSLIST输出，可以获取查询和事务的地方，从而知道用户对数据库进行了什么样的操作
* 通过服务器内部行为则可以清楚服务器是否有bug,或内部的性能和扩展性是否有问题。

iosstat查看io
vmstat查询memory

> 我们知道这个版本的InnoDB存在‘痴狂刷新’的问题（也叫检查点停顿），发生这样的情况是因为InnoDB没有按时间均匀分布刷新请求，而是隔一段时间突然请求一次强制检查点导致大量刷新操作。这种机制可能会导致InnoDB内部生严重的阻塞，导致所有的操作需要排队等待进入内核， 从而引发InnoDB上一层服务器产生堆积。可以查看SHOW STATUS的计数器，追踪一下Innodb_buffer_pool_pages_flushed的变化。

究竟是什么导致了性能低下：

* 资源被过度使用，余量已经不足以正常工作
* 资源没有被正确配置
* 资源已经损坏或者失灵

df -h查看磁盘使用情况
lsof 查看服务器打开的文件句柄

```
awk '
/mysqld.*tmp/ {
	total += $7;
}
/^Sun Mar 28/ && total {
	printf "%s %7.2f MB\n", $4, total/1024/1024;
	total = 0;
}' lsof.txt
'
```

##### 使用用USER_STATISTICS

```
show tables from information_schema like '%_statistics'
```

通过上面的查询可以了解到：

* 可以查找使用得最多的或者是使用用得最少的表和索引，通过读取次数或者更新次数，或者两者一起排序
* 可以查找出从未使用过的索引，可以考虑删除之
* 可以看看复制用户的CONNECTD_TIMET和BUSY_TIME,以确认复制是否会很难跟上主库的进度。 

##### 使用strace

```
strace -cfg $(pidof mysqldd)
```

* strace度量时使用的是实际时间
* oprofile度量时使用的是CPU周期
> 当I/O等待出现问题的时候，strace能将它们显示出来，因为它从诸如read或是pread64这样的系统调用开始计时，直到调用结束。但oprofile不会这样，因为I/O系统调用并不会真正消耗CPU周期，而只是等待I/O完成而已

## Schema与数据类型优化
### 选择优化的数据类型

* 更小的通常更好
	> 更小的数据类型通常更快，因为它们占用更少的磁盘，内存和CPU缓存，并且处理时需要的CPU周期也更少。
	
* 简单就好
	> 简单数据类型操作通常需要更少的CPU周期，整型比字符操作代价更低，因为字符集和校对规则（排序规则）使字符比较整型比较更复杂。尽量使用MySQL内建的类型而不是字符串来存储日期和时间，另外应该用整型存储IP地址。
	
* 尽量避免NULL
	> 查询中包含NULL列，对MySQL来说更难优化，因为可为NULL的列使得索引，索引统计和值比较都更复杂。可为NULL的列会使用更多的存储空间，在MySQL里也要特殊处理。当可为NULL的列被索引时，每个索引记录一个额外的字节，在MyISAM里甚至可能导致固定大小的索引变成可变大小的索引。
	> 当然也有例外，InnoDB使用单独的位（bit）来存储NULL值，所以对于稀疏数据有很好的效率，但这一点不适于MyISAM.


##### 整数类型

有整数(whole number)和实数(real number)

TINYINIT 8, SMALLINT 16, MEDIUMINT 24, INT 32, BIGNIT 64, 它们可以存储从-2^(N-1)到2^(N-1), N是存储空间的位数

##### 实数类型
浮点类型在存储同样范围的值时，通常比DECIMAL使用更少的空间。FLOAT使用4个字节存储。DOUBLE占用8个字节，相比FLOAT有更高的精度各更大的范围。和和数一样，能选择的只是存储类型；MySQL作为内部浮点计算的类型。

可以考虑用BIGINT代替DECEMAL，将需要存储的数据根据小数的位数乘以相应的倍数。

##### 字符串类型
VARCHAR
> VARCHAR使用1或2个额外字节记录字符串的长度。如果列的最大长度小于或等于200个字节，则只使用1个字节表示；否则使用2个字节。例如采用latin1字符集，VARCAHR(10)需要使用11个字节的存储空,VARCHAR(1000)列则需要1002个字节，因为需要2个字节存储长度信息。

> VARCHAR	节省了空，对性能有帮助。但由于变长，在UPDATE时可能使行变得比原来长，这导致需要做额外的工作。不同的引擎处理方式不一样。MyISAM会将行折成不同的片段存储，InnoDB则需要分裂页来使行可以放进页内。

下面这些情况使用VARCHAR是合适的：

* 字符串列的最大长度比平均长度大很多
* 列的更新很少，所以碎片不是问题
* 使用了像UTF-8这样复杂的字符集，每个字符都使用不同的字节数进行存储

CHAR

* 适合存储很短的字符串
与 CHAR VARCHAR类似还有BINARY, VARBINARY,它们存储的是二进制字符串。
二进制比较的优势并不仅仅体现在大小写敏感上，MySQL比较BINARY字符串时，每次按一个字节，并且根据该字节的数据进行比较。因此，二进制比较比字符串简单很多，所以也就更快。

---
BLOB 和 TEXT类型

BLOB TEXT都是为存储很大的数据而设计的字符串数据类型，分别采用二进制和字符方式存储

字符类型：TINYTEXT, SMALLTEXT, TEXT, MEDIUMTEXT, LONGTEXT

二进制类型: TINYBLOB, SMALLBLOB, BLOB, MEDIUMBLOB, LOGNBLOB.

BLOB是SMALLBLOB的同义词，TEXT是SMALLTEXT的同义词

当BLOB, TEXT值太大时，InnoDB会使用专门的‘外部’存储区域来进行存储，此时每个值在行内需要1~4个字节存储一个指针，然反在外部存储区域存储实际的值。

MySQL对BLOB TEXT的列进行排序与其他类型不同：它只对每个列的最前max_sort_length字节而不是整个字符串做排序。或果只需要排序最前面一小部分字符，则可以减小max_sort_length配置，或者使用ORDER BY SUSTRING(column, length)

MySQL不能将BLOB, TEXT列全部长度的字符串进行索引，也不能使用这些索引消除排序。

ENUM

好处：

* MySQL在存储枚举时非常紧凑，会根据列表值的数量压缩到一个或者两个字节中。MySQL在内部会将每个值在列表中的位置保存为整数，并且在表的.frm文件中保存‘数字-字符串’映射关系的‘查找表’。
* 枚举字段是按照内部存储的整数而不是定义的字符串进行排序的。可以在查询在使用FIELD()函数显示地指定排序顺序，来绕过个限制，但这会导致MySQL无法利用索引消除排序。

坏处

* 枚举不好的地方，字符串列表是固定的，添加或删除字符串必须使用ALTER TABLE。
* 由于MySQL把每个枚举保存为整数，并且必须进行查找才能转换为字符串，所以枚举列有一些开销。

##### 日期和时间类型
DATATIME
> 存储从1001到9999年，精度为秒，把日期和时间封装成YYYYMMDDKKHHMMSS的整数中，与时区无关，例用8个字节存储空间

TIMESTAMP
> 保存从1970年1月1日午夜以来的秒数，它和UNIX时间戳相同。TIMESTAMP只使用4个字节的存储空间，因此其范围比DATATIME小，只能到1970到2038.MySQL提供到FROM_UNIXTIME()函数把Uinx时间戳转换成日期，UNIX_TIMESTAMP()函数把日期转换为Unix时间戳。

> TIMESTAMP显示依赖于时区。其列默认为NOT NULL,这和其他数据类型不一样。 

除了特殊行为之外，通常应该尽量使用TIMESTAMP,因为它DATATIME空间效率更高。


BIT

可以使用BIT列在一列中存储一个或多个true/false值。BIT(1)定义一个包含单个位的字段，BIT(2)存储2个位。最大长度是64个位。

如果需要在一个bit的存储空间中存储一个true/false值，另一个方法是创建一个可以为空的char(0)列，该列可以保存空值（NULL）或者长度为0的字符串（空字符串）

SET

如果需要保存很多true/false值，可以考虑合并这些列到一个SET数据类型，它在MySQL内部是以一系列打包的位的集合来表示的。

优点：

* 有效利用存储空间
* 利用FIND_IN_SET(), FIELD()这样的函数，方便查询


缺点：

* 改变列的定义代价较高，需要ALTER TABLE

在整数列上进行按位操作

一种替代SET的方式是使用一个整数包装一系列的位。例如，可以把8个位包装到一个TINYINT中，并且按位操作使用。
好处是可以不使用ALTER TABLE改变字段代表的‘枚举’，缺点是查询语句难写，难理解

MySQL在内部使用整数存储ENUM, SET类型，然后在做比较操作时转换为字符串

例如

```
CREATE TABLE ac;(perms SET('CAN_READ', 'CAT_DELETE') NOT NULL);

INSERT INTO acl(perms) VALUES ('CAN_READ, CAN_DELETE');

SELECT perms FROM acl WHERE FIND_IN_SET('CAN_READ', perms);

```

若用整数来存储：

```
SET 
	@CAN_READ := 1 << 0,
	@CAN_WRITE := 1 << 1,
	@CAN_DELETE := 1 << 2;
	 	
CREATE TABLE acl(perms TINYINT UNSIGNED NOT NULL DEFAULT 0);

INSERT INTO acl(perms) VALUES(@CAN_READ + @CAN_DELETE);

SELECT perms FROM acl WHERE perms & @CAN_READ;
```

#### MySQL schema设计中的陷阱

* 太多的列
* 太多关联
* 全能的枚举
* 变相的枚举
* 非此发明（Not Invent Here）的NULL: 不一定不有用NULL，特殊情况还是可以用的

#### 范式与反范式

* 在范式化数据库中，每个事实数据会出现并且只出现一次
* 在反范式化数据库中，信息是冗余的，可能会存储在多个地方

范式的优点与缺点：

* 范式化的更新操作通常比反范式化要快
* 当数据较好地范式化时，就只有很少或者没有重复的数据，所以只需要修改更少的数据
* 范式化表通常更小，可以更好地放在内存里，所以执行操作更快
* 很少有冗余的数据意味着检索列表数据时更少需要DISTINCT GROUP BY才能获取数据
* 范式化设计缺点是查询通常需要关联

反范式化的优点与缺点

* 数据在同一张表中，避免关联
* 数据更新需修改很多数据

混用范式化与反范式化

#### 缓存表与汇总表

```
CREATE TABEL msg_per_hr (
	hr DATATIME NOT NULL,
	cnt INT UNSIGNED NOT NULL,
	PRIMARY KEY (hr)
);

SELECT SUM(cnt) FROM msg_per_hr
WHERE hr BETWEEN
	CONCAT(LEFT(NOW(), 14), '00:00') - INTERVAL 23 HOUR
	AND CONCAT(LEFT(NOW(), 14), '00:00') 0 INTERVAL 1 HOUR;

SELECT COUNT(*) FROM message
WHERE posted >=  NOW() - INTERVAL 24 HOUR
	AND posted < CONCAT(LEFT(NOW(), 14), '00:00') - INTERVAL 23 HOUR;
	
SELECT COUNT(*) FROM message
WHERE posted >= CONCAT(LEFT(NOW(), 14), '00:00');

-----

DROP TABLE IF EXISTS my_summay_new, my_summary_old;
CREATE TABLE my_summary_new LIKE my_summary;
RENAME TABLE my_summay TO my_summay_old, my_summary_new TO my_summay;
```

#### 计数器表
如果在应用中保存计数器，则在更新计数器时可能碰到并发问题，对于任何想要更新这一行的事务来说，这条记录上都有一个全局的互斥锁（mutex），这会使得这些事务只能串行执行。可以将计数器保存在多行中，每次随机选择一条进行更新。

同样也可以每隔一段时间开始一个新的计数器。

如果希望减少表的行数，以避免表变得太大，可以写一个周期执行的任务，合并所有结果到0号槽，并且删除所有其他的槽


#### 加快ALTER TABLE操作的速度

MySQL的ALTER TABLE操作的性能对大表来说是个大问题。

一般而言，大部分的ALTER TABLE操作将导致MySQL的服务中断，对于常见的场景，能使用的技巧有两种：

* 一种是先在一台不提供服务的机器上执行ALTER TABLE操作，然后和提供服务的主库进行交换
* 另外一种是‘影子拷贝’，其技巧是：用要求的表结构创建一张和源表无关的新表，然后通过重命名和删表操作交换两张表。

不是所有ALTER TABLE操作都会做表重建，如有两种方法可以改变或删除一个列的默认值（一种方法很快，一种方法很慢）：

```
ALTER TABLE sakila.film MODIFY COLUMN rental_duration TINYINT(3) NOT NULL DEFAULT 5;
```

此操作会拷贝整张表到一张新表，甚至列的类型，大小各可否为NULL的属性都没有改变

```
ALTER TABLE sakila.film ALTER COLUMN rental_duration SET DEFAULT 5;
```

理论上，MySQL可以跳过创建新表的步骤，表的默认值实际在表的.frm文件中，可以直接修改这个文件而不需要改动表本身。此操作就可以直接修改.frm文件，所以非常的快。

另外，也可以通过交换.frm文件实现ALTER TABLE:

1. 创建一张有相同结构的空表，并进行所需要的修改（例如增加ENUM常量）
2. 执行FLUSH TABLES WITH READ LOCK.这将关闭所有正在使用的表，并且禁止任何表被打开
3. 交换.frm文件
4. 执行UNLOCK TABLES来释放每2步的读锁。

#### 快速创建MyISAM索引
为了高效地载入数据到MyISAM表中，常用的技巧是：先禁用索引，载入数据，然后重新启用索引。

```
ALTER TABLE test.load_data DISABLE KEYS;
---load data
ALTER TABLE test.load_data ENABLE KEYS;
``` 

不幸地是，这个办法对唯一索引无效，因为DISABLE KEYS只对非唯一索引有效。

SCHEMA设计总结：

* 尽量避免过度设计，例如会导致极其复杂查询的schema设计，或者有很多列的表设计（很多的意思是介于有点多和非常多之间）
* 使用小而简单的合适数据类型，除非真实数据模型有确切的需求，否则应该尽可能地避免使用NULL值
* 尽量使用相同的数据类型存储相似或相关的值，尤其是要在关联条件中使用的列
* 注意可变长字符串，其在临时表和排序可能导致悲观的按最大长度分配内存
* 尽量使用整型定义标识列
* 避免使用MySQL已经遗弃的特性，例如指定浮点数的精度，或者整数的显示宽度
* 小心使用ENUM SET。虽然他们使用起来很方便，但是不要滥用，否则有时候会变成陷阱，最好避免使用BIT

## 第五章 创建高性能的索引
### 5.1索引基础
索引可以包含一个或多个列的值，如果索引包含多个列，那么列的顺序也十分重要，因为MySQL只能高效地使用索引的最左前缀列。

### 5.1.1索引的类型
MyISAM使用前缀压缩技术使得索引更小，但InnoDB则按照原数据进行存储；MyISAM索引通过数据物理位置引用被索引的行，而InnoDB则根据主键引用被索引的行。

B-Tree通常意味着所有有值都是按顺序存储的，并且每一个叶子页到根的距离相同

B-Tree索引适用于全健值，键值范围或键前缀查找：

* 全值匹配

	> 全值匹配指的是和索引中的所有列进行匹配
* 匹配最左前缀
	
* 匹配列前缀

	> 也可以只匹配某一列的值的开头部分	
* 匹配范围值

	> 精确匹配某一列并范围匹配另一列
* 只访问索引的查询

B-Tree索引的一些限制

* 如果不是按照索引的最左列开始查找，则无法使用索引
* 不能跳过索引中的列
* 如果查询中有某个列的范围查询，则其右边所有列都无法使用索引优化查询。如Like


#### 哈希索引
哈希索引(has index)基于于哈希表实现，只有精确匹配索引所有列的查询才有效；如果多个列的哈希值相同，索引会以链表的方式存放多个记录指针到同一个哈希条目中。

因为哈希索引自身只需存储对应的哈希值，所以索引的结构十分紧凑，这也让哈希索引查找的速度非常快。

但哈希索引也有限制：

* 哈希索引只包括哈希值和行指针，而不存储字段值，所以不能使用索引中的值来避免读到行。不过，访问内存中的行的速度很快，所以大部分情况下这一点对性能的影响并不明显。
* 哈希索引数据并不是按照索引值顺序存储的，所以也就无法用于排序
* 哈希索引也不支持部分索引列匹配查找，因为哈希索引始终是使用索引列的全部内容来计算哈希值的
* 哈希索引只支持等值查询，包括=, IN(), <=>，也不支持任何范围查询
* 访问哈希索引的数据非常快，除非有很多哈希冲突（不同的哈希列值却有相同的哈希值）。当出现哈希冲突的时候，存储引擎必须遍历链表中所有的指针，逐行进行比较，直到找到所有符合条件的行
* 如果哈希冲突很多的话，一些索引维护操作的代价也会很高

因这些限制，哈希索引只适用一某些特殊的场合。而一旦适合哈希索引，则它带来的性能提升将非常显著

#### 空间数据索引(R-Tree)
MyISAM表支持空间索引，可以用作地理数据存储。和B-Tree索引不同，这类索引无须前缀查询。空间索引会从所有维度来索引数据，查询时，可以有效地使用任意维度来组合查询。必须使用MySQL的想着函数如MBRCONTAINS()等来维护数据

#### 全文索引
全文索引是一种特殊索引，它查找是文本中的关键词，而不是直接比较索引中的值。需可注意的细节，如停用词，词干，复数，布乐搜索等

### 5.2索引的优点

* 索引大大减小了服务器需要扫描的数据量
* 索引可以帮助服务器避免排序各临时表
* 索引可以将随机I/O变成顺序I/O

三星索引：

* 索引将相关的记录放到一起则获一颗性
* 索引中的数据顺序各查找中的排序顺序一致则获两颗星
* 索引中的列包含了查询中需要的全部列则获得三星

### 5.3高性能的索引策略
#### 5.3.1独立的列
#### 5.3.2前缀索引各索引选择性
索引很长的字符列，会让索引变大且慢，可以索引开始的部分字符，这样可以大大节约索引空间，从而提高索引效率，但同时会降低索引的选择性

索引的选择性是指，不重复的索引值（也称为基数，cardinality）和数据表的记录总数（#T）的比值，范围从1/#T到1之间，索引的选择性越高则查询效率越高，因为选择性高的索引可以让MySQl查找时过滤掉更多的行。唯一索引的选择性就是1，这是最好的索引选择性，性能也是最好的。

对于BLOB TEXT或是很长的VARCHA类型的列，必须使用前缀索引，因为MySQL不允许索引这些列的完整长度。

反缀索引（suffix index）要以通过反转字符，触发器等技术手段实现。

#### 5.3.3多列索引
索引合并策略会有一定的优化，但也说明索引建得不好：

* 当出现服务器对多个索引做相交操作时（通常有多个AND条件），通常意味着需要一个包含所有相关列的多列索引，而不是多个独立的单列索引
* 当服务器需要对多个索引做联合操作时（通常有多个OR条件），通常需要耗费大量的CPU和内存资源在算法的缓存，排序和合并操作上。特别是当其中有些索引的选择性不高，需要合并扫描返回的大量数据的时候
* 更重要的是，优化器不会把这些计算到‘查询成本（cost）’中，优化器只关心随机页面读取。会消耗更多的CPU和内存资源，这样会影响查询的并发性。

可以通过optimizer_switch来关闭索引合并。也可以用IGNORE INDEX来提示让优化器忽略掉某些索引

#### 5.3.4选择合适的索引顺序
索引的顺序适用于B-Tree，哈希索引或是其他类型的索引并不会像B-Tree一样按顺序存储数据

在一个多列B-Tree索引中，索引列的顺序意味着索引首先按照最左列进行排序，其次是第二列，等等。所以索引可以按照升序或降序进行扫描，以满足精确符合顺序的ORDER BY, GROUP BY, DISTINCT等子句的查询要求。

```
SELECT COUNT(DISTINCT staff_id)/COUNT(*) AS staff_id_selectivity, COUNT(DISTICT customer_id)/COUNT(*) AS customer_id_selectivity, COUNT(*) FROM payment\G;
```

经验证customer_id选择性更高

```
ALTER TABLE payment ADD KEY(customer_id, staff_id);
```

#### 5.3.5聚簇索引
聚簇索引并不是一种单独的索引类型，而是一种数据存储方式。InnoDB的聚簇索引实际上是在同一个结构中保存了B-Tree索引和数据行。

当表有聚簇索引时，它的数据行实际上存放在索引的叶子页（leaf page）.一个表只能有一个聚簇索引。

InnoDB将通过主键聚集数据，如果没有定义主键，InnoDB会选择一个唯一的非空索引代替，如果没有这样的索引，InnoDB会隐式定义一个主键来作为聚簇索引。InnoDB只聚集在同一个页面中的记录。

聚簇索引的优点：

* 可以把相关数据保存在一起。如果没有聚簇索引，则每次查询都可能导致一次磁盘I/O
* 数据访问更快。聚簇索引引索引与数据保存在同一个B-Tree中，因此从聚簇索引中获取数据通常比在非聚簇索引中查找要快
* 使用覆盖索引扫描的查询可以直接使用页节点中的主键值

聚簇索引的缺点：

* 聚簇数据最大限度地提高了I/O密集型应用的性能。但如果数据全部放在内存中，则访问的顺序就没那么重要，聚簇索引也就没什么优势了
* 插入速度严重依赖于插入顺序。按照主键的顺序插入是加载数据到InnoDB表中速度最快的方式。但如果不是按照主键顺序加载数据，那么在加载完成后最好使用OPTIMIZE TABLE命令重新组织一下表。
* 更新聚簇索引列的代价很高，因为会强制InnoDB将每个被更新的行移动到新的位置
* 基于聚簇索引的表在插入新行，或者主键被更新导致需要移动行的时候，可能面临‘页分裂(page split)’,这将导致表占用更多的磁盘空间
* 聚簇索引可能导致全表扫描变慢，尤其是行比较稀疏，或者是由于页分裂数据存储不连续的时候
* 二级索引（非聚簇索引）可能比想象的要更大，因为在二级索引的叶子节点上包含了引用行的的主键列
* 二级索引访问的需要两次索引查找，而不是一次（因为二次索引的叶子节点存储了对应的主键值，然后根据这个值去聚簇索引中找到对应的行）

##### InnoDB和MyISAM数据分布对比
MyISAM数据分布非常简单，按照数据插入的顺序存储在磁盘上。

聚簇索引的每个叶子节点都包含了主键值，事务ID,用于事务和MVCC的回滚指针以及所有剩余列。如果主键是一个列前缀索引，InnoDB也会包含完整的主键列和剩下的其他列。

InnoDB的二级索引和聚簇索引很不同，InnoDB二级索引的叶子节点中存储的不是行指针，而是主键值，并以此作为指向行的指针。这样策略减少了当出现行移动或数据页分裂时二级索引的维护工作，InnoDB在移动行时无须更新二级索引中的’指针‘

使用UUID来作为聚簇索引则会很糟糕：它使得聚簇索引的插入变得完全随机，这是最坏的情况，使得数据没有任何聚集特性。其缺点有：

* 写入的目标页可能已经刷到磁盘上并从缓存中移除，或者是还没有被加载到缓存中，InnoDB在插入之前不得不先找到并从磁盘读取目标页到内存中。这将导致大量的随机I/O
* 因为写入是乱序的，InnoDB不得不频繁地做页分裂操作，以便为新的行分配空间。页分裂会导致移动大量数据，一次插入最少需要修改三个页而不是一个页。
* 由于频繁的页分裂，页会变得稀疏并被不规则地填充，所以最终数据有碎片。
* 在把这些随机值载入到聚簇索引以后，也许需要做一次OPTIMIZE TABLE来重建表并优化页的填充。

顺序的主键什么时候会造成更坏的结果？

对于高并发工作负载，在InooDB中按主键顺序插入可能会造成明显的争用，主键的上界会成为‘热点’，因为所有插入都发生在这里，所以并发插入可能导致间隙锁竞争。

### 5.3.6 覆盖索引
如果一个索引包含（或者说覆盖）所有需要查询的字段的值，我们就称之为‘覆盖索引’

覆盖索引的优点：

* 索引条目通常远小于数据行大小，所以如果只需要读取索引，那MySQL就会极大地减少数据访问量。这对缓存的负载非常重要，因为这种情况下响应时间大部分花费在数据拷贝上。覆盖索引对I/O密集型的应用也有帮助，因为索引比数据更小，更容易全部放入内存中。
* 因为索引是按照列值顺序存储的（至少在单页内是如此），所以对于I/O密集型的范围查询会比随机从磁盘读取每一行数据的I/O要少得多。
* 一些存储引擎如MyISAM在内存中只缓存索引，数据则依赖于操作系统来缓存，因此要访问数据需要一次系统调用。这可能会导致严重的性能问题，尤其是那些系统调用占了数据访问中的最大开销的场景。
* 由于InnoDB的聚簇索引，覆盖索引对InnoDB表特别有用。InnoDB的二级索引在叶子节点保存了行的主键值，所以如果二级主键能够覆盖查询，则可以避免主键索引的二次查询。

#### 5.3.7 使用索引扫描来做排序
只有当索引的列顺序和ORDER BY子句的顺序完全一致，并且所有列的排序方向（倒序或是正序）都一样时，MySQL才能够使用索引来对结果做排序。

如果查询需要关联多张表，则只有当ORDER BY子句引用的字段全部为每个表时，才能使用索引做排序

ORDER BY子句和查找型查询的限制是一样的：需要满足索引的最左前缀的要求，否则MySQL都需要执行排序操作，无法利用索引排序。

有一种情况下ORDER BY 子句可以不满足索引的最左前缀，就是前导列为常量时候，如

```

UNIQUE KEY rental_date(rental_date, inventory_id, customer_id)

select rental_id, staff_id form sakila.rental where rental_data = '2005-05-25' order by inventory_id, customer_id\G


//可以进行索引排序
... where rental_date = '2005-05-25' order by inventory_id desc


//可以进行索引排序,符合最左前缀
...where rental_date > '2005-05-25' order by retal_date, inventory_id

//下面一些不能保用索引排序
//使用了两种不同的排序方向，但是索引列都是正排序的
...where retanl_date = '2005-05-25' order by inventory_id desc, customer_id asc;

//order by 中使用了一个不在索引中的列
...where rental_date = '2005-05-25' order by inverntory_id, staff_id;

//order by 的列无法组合成索引的最左前缀
...where rental_date = '2005-05-25' order by customer_id

//查询在inventory_id列上有多个等于条件，对于排序来说是种范围查询
...where rental_date = '2005-05-25' and inventory_id in (1,2) order by customer_id;
```

#### 5.3.8（前缀压缩）索引
MyISAM使用前缀压缩来减少索引的大小，从而让更多的索引可以放入到内存中，这在某此情况下可以极大地提升性能。默认只压缩字符串，通过调整参数也可以对整数压缩。

MyISAM压缩每个索引块的方法是，先完全保存索引块中的每一个值，然后将其他值和每个值进行比较得到相同前缀的字节数和剩余不同后缀部分，把这部分存储起来即可。

压缩块使用更少的空，代价是某些操作列慢。

测试表明，对于CPU密集型应用，因为扫描需要随机查找，压缩索引使得MyISAM在索引查找上要慢好几倍。压缩索引的倒序扫描就更慢了。

可以CREATE TABLE语句中指PACK_KEYS参数来控制索引压缩的方式。

#### 5.3.9冗余和重复索引
重复索引是指在相同的列上按照相同的顺序创建的相同类型的索引。应该避免这样创建重复索引，发现以后也应该立即删除。

表中的索引越多插入速度就会越慢。

解决冗余索引各重复索引的方法很简单，删除这些索引就可以，但首先要找到这样的索引。

InnoDB，二级索引的叶子节点包含了主键值，所以在列（A）上的索引就相当于在(A, ID)上的索引。如果像where a = 5 order by id，这样的索引很有用。但如果将索引扩展为(A,B),实际上变成了(A,B,ID)，那么order by 子句无法使用该索引，只能用文件排序了。

如果MySQL使用某个索引进行范围查找，也就无法再使用另一个索引（或是该索引的后续字段）进行排序了。

#### 5.5 维护索引和表
维护表有三个主要目的：

* 找到并修复损坏的表
* 维护准备的索引统计信息
* 减少碎片

CHECK TABEL能够找出大多数的表和索引的错误

REPAIR TABLE命令可以用来修复损坏的表

如果存储引擎不支repair table，可以通过alter table来修复。

```
alter table innodb_tbl engine=InnoDB;
```

表损坏(corruption)：

MyISAM存储引擎，表损坏通常是系统崩溃导致，也可能是硬件问题。

InnoDB一般不会损坏，一旦出现损坏，要么是硬件问题，要么是管理误操作。

可以通过设置innodb_force_recovery参数进入InnoDB的强制恢复模式个修复数据

通过ANALYZE TABLE得新生成索引统计信息

使用SHOW INDEX FROM TABLE命令来查看索引的基数（Cardinality）

#### 5.5.3 减少索引各数据的碎片
数据碎片的三种类型：

* 行碎片(Row fragmentation)
	
	> 这种碎片指的是数据行被存储为多个地方的多个片段中。即使查询只从索引中访问一行记录，行碎片也会导致性能下降
* 行间碎片(Intra-row fragmentation)

	> 行间碎片是指逻辑上的顺序的页，或者行在磁盘上不是顺序存储的。行间碎片对诸如全表扫描的聚簇索引扫描之类的操作有很大的影响，因为这些操作原本能够从磁盘上顺序存储的数据中获益。	
* 剩余空间碎片(Free space fragmentation)

	> 剩余空间碎片是指数据页中有大量的空作空间，这会导致服务器读取大量不需要的数据，从而造成浪费。
	
对于MyISAM，这三类碎片都可能发生。但InnoDB不会出现短小的行碎片，InnoDB会移动短小的行并重写到一个片段中。

选择索引应遵守以下三个原则：

* 单行访问是很慢的
	
	> 读取的块中能包含尽可能多所需的行，使用索引可以创建位置引用提升效率
* 按顺序访问范围数据是很快的

	> 第一，顺序I/O不需要多次磁盘寻道，比随机I/O快很多；
	
	> 第二，服务器能够按照需要顺序读取数据，不再需要额外的顺序操作，并group by查询无须再做排序和将行按进行聚合计算了
* 索引覆盖查询是很快；不需要二次回表查询

如何判断一个系统创建的索引是否合理：

* 找出消耗最长时间的查询或是那些给服务器带来最大压力的查询
* 检定这些查询的schema，SQL和索引结构，判断是有查询扫描太多的行，是否做了很多额外的排序或是用了临时表，是否使用随机I/O访问数据，或者是有太多的回表查询那些不在索引中的列操作

## 第6章 查询性能优化
查询优化，索引优化，库表优化要齐头并进
### 6.2慢查询基础：优化数据访问
对于低效的查询：

* 确认应用程序是否在检索大量超过需要的数据。这通常意味着访问了太多的行，但有时候也可能是访问了太多的列。
* 确认MySQL服务器层是否在分析大量超过需要的数据行。

#### 6.2.1是否向服务库请求了不需要的数据

* 查询不需要的记录

	> 一个常见的错误是常常会误以为MySQL只会返回需要的数据，实际上MySQL却是先返回全部结果集再进行计算。
* 多表关联时返回全部列
* 总是取出全部列

	> 取出全部列，会让优化器无法完成索引覆盖扫描这类优化，还会为服务器带来额外的I/O,内存各CPU的消耗
* 重复查询相同的数据
	
	> 做好数据的缓存
#### 6.2.2 MySQL是否在扫描额外的记录
衡量查询开销的三个指标：

* 响应时间

	> 响应时间包括： 服务时间和排序时间
* 扫描的行数
* 返回的行数
这三个指标都会记录到慢日志查询中。


一般MySQL能够使用如下三种方式应用where条件，从好到坏为：

* 在索引中使用where条件来过虑不匹配的记录。这是存储引擎层完成的
* 使用索引覆盖扫描（在Extra列中出现了Using index）来返回记录，直接从索引中过虑不需要的记录并返回命中的结果。这是在MySQL服务层完成的，但无须再回表查询记录
* 从数据表中返回数据，然后过虑不满足条件的记录（在Extra列中出现Using where）。这是MySQL服务层完成，MySQL需要先从数据表中读出记录然后过虑。

发现查询需要扫描大量数据但只返回少数的行，优化技巧为：

* 使用用覆盖索引扫描，把所有需要用的列都放到索引中，这样存储引擎无须回表获取对应行就可以返回结果了
* 改变库表结构
* 重写这个复杂的查询，让MySQL优化器以更优化的方式执行这个查询。

将一个复杂的查询分成多个简单的查询

```
select tbl1.col1, tbl2.col2
	from tbl1 inner join tbl2 using(col3)
	where tbl1.col1 in (5,6)
	
//关联查询伙伪代码
outer_iter = interator over tbl1 where col1 in(5,6)
outer_row = outer_iter.next
while outer_row
	inner_iter = iterator over tbl2 where col3 = out_row.col3
	inner_row = inner_iter.next
	while inner_row
		output [outer_row.col1, inner_row.col2]
		inner_row = inner_iter.next
	end
	outer_row = outer_iter.next
end
```

#### 6.3.3 分解关联查询
分解关联查询的优势：

* 让缓存的效率更高。许多应用程序可以方便地缓存单表查询对应的结果对象。可以应用程序缓存数据，也可以MySQL查询缓存
* 将查询分解后，执行单个查询可以减少锁的竞争
* 在应用层做关联，可以更容易对数据库进行拆分，更容易做到高性能的和可扩展
* 查询本身效率也可能会有所提升。
* 可以减少冗余记录的查询。减少网络和内存的消耗
* 拆分关联查询，相当于在应用中实现了哈希关联，而不是MySQL的嵌套循环关联。


### 6.4 查询执行的基础
查询过程

1. 客户端发送一条查询给服务器
2. 服务器先检查查询缓存，如果命中的缓存，则立刻返回存储在缓存中的结果。否则进入下一阶段
3. 服务器进行SQL解析，预处理，再由优化器生成对应的执行计划
4. MySQL根据优化器生成的执行计划，调存储引擎的API来执行查询
5. 将结果返回给客户端

#### 6.4.1 客户间/服务器通信协议
MySQL客户端和服务之间的通信协议是‘半双工的’，在任何时刻，要么是由服务器向客户端发送数据，要么是客户端向服务器发送数据，这两个动作不可能同时发生。

查询状态

可以通过SHOW FULL PROCESSLIST

Sleep
> 线程正在等待客户端发送新的请求

Query
> 线程正在执行查询或者正在将结果发送给客户端

Locked
> 在MySQL服务层，访线程正在等待表锁。表因为存储引擎的不同而有差异。

Analyzing and statistics
> 线程正在收集存储引擎的统计信息，并生成查询的执行计划

Copying to tmp table [on disk]
> 线程正在执行查询，并且将其结果集都复制到一个临时表中，这种状态要么是group by 操作，要么是文件排序操作，或者是union操作。有时也会将一个内存临时表放到磁盘上

Sorting result
> 线程正在对结果集进行排序

Sending data
> 纯种可能在多个状态这间传送数据，或者在生成结果集，或在向客户端返回数据

多种原因会导致优化器选择错误的执行计划：

* 统计信息不准确
* 执行计划中的成本估算不赞同于实际执行的成本
* MySQL的最优可能和你想的最优不一样
* MySQL从不考虑其他并发执行的查询，这可能会影响到当前查询的速度
* MySQL也并不是任何时候都是基于成本的优化
* MySQL不会考虑不受控制的操作的成本，如执行存储过程或者用户自定义函数的成本

MySQL能够处理优化类型：

* 重新定义关联表的顺序
* 将外连接转化为内连接
* 使用等价变换规则
* 优化COUNT(), MIN(),MAX()
* 预估转化为常数表达式
* 覆盖索引扫描
* 子查询优化
* 提前终止查询
* 等值传播
* 列表IN()的比较

可以使用STRAIGHT_JOIN关键字重写查询，让优化器按照你认为的最优的关联顺序执行。

当关联的表个数太多，超过optimizer_search_depth的限制时，搜索空间非常大时，将使用‘贪婪’搜索查找‘最优’关联顺序


MySQL的两种排序算法

两次传输排序（旧版本使用）

> 读取行指针和需要排序的字段，对其进行排序 ，然后再根据排序结果读取所需要的数据行

单次传输排序（新版本使用）

> 先读取查询所需要的所有列，然后再根据给定的列进行排序，最后直接返回排序结果

当查询需要所有列的总长度不超过参数max_length_for_sort_data，MySQL使用‘单次传输排序’

关联查询排序的处理方式：

* ORDER BY 子句中的所有列都来自关联表的每一个表，关联处理第一个表时进行文件排序，Extra: Using filesort
* 除此之外，都是先关联后的结果写入临时表，在所有关联都结束后再进行文件排序。Extra: Using temporary;Using filesort.

```
select film_id from sakila.film where exist(select * from sakila.film_actor where film.film_id = film_actor.film_id);
```


#### 6.5.5 并行执行
MySQL无法利用多核特性来并行执行查询。很多其他的关系型数据库能够提供这个特性，但是MySQL做不到。

MySQL所有关联都是嵌套循环关联。

### 6.6 查询优化器的提示（hint）

* HIGH_PRIORITY 和 LOW_PRIORITY

	> 当多个语句同时访问一个表时，哪些语句优先级相同对高些，哪些低些
* DELAYED
* STRAIGHT_JOIN

	> 可放在select后，也可放置在任何两个关联表的名字之间。第一个用法是让查询中所有的表按照在语句中出现的顺序进行关联。第二个用法则是固定其前后两个表的关联顺序。
* SQL_SMALL_RESULT 和 SQL_BIG_RESULT
* SQL_BUFFER_RESULT
* SQL_CACHE 和 SQL_NO_CACHE

	> 结果是否应该缓存在查询缓存中
* SQL_CALC_FOUND_ROWS
* FOR UPDATE 和 LOCK IN SHARE MODE

	> 这不是真正的优化提示。主要控制select语句的锁机制，但只对行经锁的存储引擎有效
* USE INDEX, INGORE INDEX, FORCE INDEX

	> 这几个提示告诉优化器使用或者不使用哪些索引来查询记录


MySQL5.0和更新版本，新增了一些参数控制优化器：

* optimizer_search_depth

	> 此参数控制优化器在穷举执行计划时的限度。
* optimizer_prune_level

	> 此参数默认打开，这优化器根据需要扫描的行数业来决定是否跳过某些执行计划
* optimizer_switch
	
	> 开启/关闭优化器特性的标志


COUNT()的作用

count()一个特殊的函数，有两种非常不同的作用：它可以统计某个列值的数据，也可以统计行数。

当MySQL确认括号内表达式的值不可能为空时，实际上就是在统计行数。最简单的就是使用count(*)的时候，这种情况下通配符 \* 并不会像我们猜想的那样扩展成所有的列，它会忽略所有的列而直接统计所有的行数。

当没有任何where条件时，MyISAM的count(*)速度非常的快。

查询技巧

```
select (select count(*) from world.city) - count(*) from world.city where id <= 5;

select sum(if(color = 'blue', 1, 0)) as blue, sum(if(color='red', 1,0)) as red from items;

也可以
select count(color = 'blue' or Null) as blue, count(color = 'red' or null) as red from items;
```
#### 6.7.2 优化关联查询

* 确保ON或USING子句中的列在有索引。一般来说，除非有其他理由，否则只需要在关联顺序中的第二个表的相应列上创建索引。
* 确保任何的GROUP BY 和 ORDER BY中的表达式只涉及到一个表中的列，这样MySQL才有可能使用索引来优化这个过程。
* 当MySQL升级要注意：关联语法，运算优先级等可能发生变化的地方。因为以前是普通关联的地方可能会变笛卡尔积，不同类型的关联可能会生成不同的结果。

#### 6.7.3 优化子查询
关于子查询优化就是建议尽可能使用关联查询代替。

#### 6.7.4 优化GROUP BY 和 DISTICT
在MySQL中，当无法使用索引的时候，GROUP BY使用两种策略在完成：使用临时表或文件排序来做分组。可以通过使用提示 SQL_BIG_RESULT, SQL_SAMLL_RESULT来让优化器按照用户希望的方式运行。

如果没有通过ORDER BY子句显式地指定排序列，当查询使用GROUP BY子句的时候，结果集会自动按照分组的字段进行排序，如果不关心数据顺序，则可以使用ORDER BY NULL，让MySQL不再进行文件排序。也可以直接在GROUP BY子句中直接使用DESC, ASC关键字，使分组的结果集按需求的方向排序。

分组查询的一个变种是要求MySQL对返回的分组结果再做一次超级聚合。可以使用GROUP BY WITH ROLLUP子句来实现这种逻辑，便可能不够优化。

6.7.5 优化LIMIT分布

优化分页查询的一个简单的方法是尽可能地使用索引覆盖扫描，而不是查询所有的列。然后再根据需要做一次关联操作再返回所需要的列。

```
select film_id, description from sakila.film order by title limit 50, 5;

可以改成：

select film.film_id, film.description from sakila.film inner join (select film_id from sakila.film order by title limit 50, 5) as lim using(film_id);
这种‘延迟关联’将大大提升效率，它让MySQL扫描更少的页面。

主键查询
selec * from sakila.rental where rental_id < 16030 order by rental_id desc limit 20;
```
其他优化方法包括使用预先计算的汇总表，或关联到一个冗余表，冗余表只包含主键列和需要做排序的数据列。

#### 6.7.6 优化SWL_CALC_FOUND_ROWS
分页的时候，另一个常用的技巧是在limit语句中加上SQL_CALC_FOUND_ROWS提示。这样可以获取去掉limit以后满足条件的行数。但每次都会扫描所有满足条件的行，再抛弃不需要的行，而不是在满足limit的行数后就终止扫描，如此提示的代价非常高。

另一种方式是，需要20条记录，可以先获取21条，第页20个，若21存在，则还有下一页。

还有一种做法是先获取并缓存较多的数据，如10000条，然后每次分页都从缓存里央获取。

如果只需要总数的近似值，可以考虑使用EXPLAIN的结果中的rows列的值。

#### 6.7.7优化UNION查询
MySQL总是通过创建并填充临时表的方式来执行UNION查询。优化时需手工地将WHERE, LIMIT, ORDER BY等子句‘下推’到UNION的各个子查询中。除非确实需要服务器消除重复行，否则一定要使用UNION ALL，因为没有ALL，MySQL会给临时表加上DISTINCT选项，这会导致对整个临时表数据做唯一性检查。

#### 6.7.8 作用用户自定义变量

```
set @one : = 1;
set @min_actor := (select min(actor_id) from sakila.actor);
set @last_week := current_date - interval 2 week;

select ... where col <= @last_week;
```

不适合用定义变量的地方：

* 使用自定义变量的查询，无法使用查询缓存
* 不能在使用常量或标识符的地方使用自定义变量，如表名，列名，limit子句中
* 用户自定义变量的生命周期是在一个连接中有效，不能用它们来做连接间的通信
* 如果使用连接池或是持久化连接，自定义变量可能让看起来毫无关系的代码发生交互。通常是bug.
* 在5.0之前的版本，在大小写敏感的。
* 不能显示地声明自定义变量的类型。
* MySQL优化器在某些场景下可能会将这些变量优化掉，导致代码不按预想方式运行
* 赋值的顺序与赋值的时间点并不总是固定的，这依赖于优化器的决定。
* 赋值符号 := 优先级非常低，注意表达式的优先级操作
* 使用未定义的变量不会产生任何语法错误。

优化排序语句

```
set @curr_cnt := 0; @prev_cnt := 0; @rank := 0;
select actor_id,
	@curr_cnt := cnt as cnt,
	@rank := if($prev_cnt <> @curr_cnt, @rand + 1, @rank) as rank,
	@prev_cnt := @curr_cnt as dummy
from (
	select actor_id, count(*) as cnt from sakila.film_actor group by actor_id order by cnt desc limit 10) as der;
)

update t1 seet lastupdated = NOW() where id = 1 and @now := NOW();
select @now;
```

统计更新和插入的数量 

```
insert into t1(c1, c2), (2,1), (3,1) on duplicate key update c1 = VALUES(c1) + (0 * (@x := @x + 1))
```
另外MySQL的协议会返回被更改的总行数，所以不需要单独存储上面这个值。

变量用法示例

```
set @rownum := 0;
select actor_id, @rownum as rownum
	from sakila.actor
	where (@rownum := @rownum + 1) <= 1;
	
set @rownum := 0;
select actor_id, first_name, @rownum as rownum
	from sakila.actor
	where @rownum <= 1
	order by first_name, LEAST(0, @rownum := @rownum + 1);
	
类似的函数还有：
GREATEST()
LENGTH()
ISNULL()
NULLIFL()
IF()
COALESCE()
```
偷懒的UNION

```
select GREATEST(@found := -1, id) as id, 'users' as which_tbl
from users where id = 1
union all
	select id, 'users_archived'
	from users_archived where id = 1 and @found is null
union all
	select 1, 'reset' from DUAL where (@found := NULL) is not null;
```

自定义变量可以做什么

* 查询运行时计算总数和平均值
* 模拟GROUP语句中的函数FIRST() LAST()
* 对大量数据做一些数据计算
* 计算一个大表的MD5散列值
* 编写一个样本处理函数，当样本中的数值超过某个边界时候将其变成0
* 模拟读/写游标
* 在SHOW语句的WHERE子句中加入变量值

案例学习

```
SET AUTOCOMMIT = 1;
COMMIT;
UPDATE unsent_emails
	SET status = 'claimed', owner = CONNECTION_ID()
	WHERE owner = 0 and status = 'unsent'
	LIMIT 10;
SET AUTOCOMMIT = 0;
SELECT id FROM unsend_emails
	WHERE owner = CONNECTION_ID() AND status = 'claimed';
	
UPDATE unsent_emails 
	SET owner = 0, status = 'unsent'
	where owner not in (0, 10, 20, 30) and status = 'claimed' 
	and ts < CURRENT_TIMESTAMP - INTERVAL 10 MINUTE;
```

MySQL构造队列原则

* 尽量少做事，可以话就不要做任何事情。除非情非得已，否则不要用轮询
* 尽可能快地过完成需要做的事。尽量用UPDATE代替SELECT FRO UPDATE，因为事务提交的速度越快，持有的锁时间就越短
* 某些查询是无法优化的，考虑用不同的查询或是策略去实现相同的目的。

空点计算

```
ACOS(
	COS(latA) * COS(latB) * COS(lonA - lonB)
	+ SIN(latA) * SIN(latB)
);

select * from locations where 3979 * ACOS(COS(RADIANS(lat)) * COS(RADIANS(38.03)) * COS(RADIANS(lon) - RADIANS(-78.48))) <= 100;

//下面的语句无法使用索引，因为第一列是范围查询，如果加了索引(lat, lon) or (lon,lat)，因为两个列都是范围，所以这里只使用索引的一个列。
select * from locations where lat between 38.03 - degree(0.0253) and 38.03 + degree(0.0253) 
	and lon between -78.48 - degree(0.0253) and -78.48 + degree(0.0253);
```

根据坐标一定的范围近似值来搜索

```
alter table locations
	add lat_floor int not null default 0,
	add lon_floor int not null default 0,
	add key(lat_floor, lon_floor);
	
update locations set lat_floor = floor(lat), lon_floor = floor(lon);

select * from locations
where lat between 38.03 - degree(0.0253) and 38.03 + degree(0.0253)
	and lon between -78.48 -  degree(0.0253) and -78.48 + degree(0.0253)
	and lat_floor in (36, 37, 38, 39, 40) and lon_floor in(-80, -79, -78, -77)
```

优化三管齐下：

不做，少做，快速地做。

## 第七章 MySQL高级特性
### 7.1 分区表
分区的作用：

* 表非常大以至于无法全部都放在内存中，或者只在表的最后部分有热点数据，其他均是历史数据。
* 分区表的数据更容易维护。想批量删除大量数据可以使用清除整个分区的方式。另外可以对一个独立分区进行优化，检查，修复等操作
* 分区表的数据可以分布在不同的物理设备上，从而高效地利用多个硬件设备。
* 可以使用分区表来避免某些特殊的瓶颈，例如InnoDB的单个索引的互斥访问，ext3文件系统的inode锁竞争。
* 备份和恢复独立的分区。

分区限制：

* 一个表最多只能有1024个分区
* 在MySQL5.1，分区表达式必须是整数，或是返回整数的表达式。5.5中，某些场景中可以直接使用列来进行分区。
* 如果分区字段中有主键或是唯一索引的列，那么所有主键列和唯一索引列都必须包含进来
* 分区表中无法使用外键约束

MySQL的操作 SELECT, INSERT, DELETE, UPDATE这些操作都会‘先打开并锁住所有的底层表’，但并不是说分区表在处理过程中是锁住全表的。如查存储引擎能够自己实现行级锁，例如InnoDB，则会在分区层释放对表锁。

下表将每一年的销售额放在不同的分区里

```
create table sales (
	order_date columns omitted
) engine=InnoDB partition by RANGE(YEAR(order_date)) (
	partition p_2010 values less than(2010),
	partition p_2011 values less than(2011),
	partition p_2012 values less than(2012),
	partition p_catchall values less MAXVALUE
);
```

常用的分区技术有：

* 根据键值进行分区，来减少InnoDB的互斥竞争
* 使用数学模函数进行分区,然后将数据轮询放入不同的分区。例如对日期做模7的运算，或者更简单的使用返回周几的函数。
* hash(id div 100000)

查询大数据，为保证大数据的扩展性，有两个策略：

* 全量扫描数据，不要任何索引

	> 使用简单的分区方式存放表，不要任何索引，根据分区的规则大致定位需要的数据位置。只要能够使用where条件，将需要的数据限制在少数分区中，则效率是很高的。

* 索引数据，并分离热点

	> 数据有明显的热点，而且除了这部分数据，其他的数据很少被访问到，可以将这部分数据单独放在一个分区中，让这个分区的数据能够有机会缓存在内存中。

上面两个策略在一些场景会出问题：

* NULL值会使分区过滤无效

	> 可以创建一个‘无用’的第一个分区。5.5以后可以直接PARTITION BY RANGE COLUMNS(order_date)

* 分区列和索引列不匹配

	> 如果定义的索引列和分区列不匹配，会导致查询无法进行分区过虑。
*  选择分区的成本可能很高

	> 需要限制分区的数量，对大多数系统来说，100个左右的分区是没有问题的
* 打开并锁住所有底层表的成本可有很高

	> 可以用批量操作的方式来降低单个操作的开销。
* 维护分区的成本可能很高

	> 某些分区维护操作的速度非常快，例如新增或删除分区。但重组分区或类似ALTER操作，则非常慢，因为需要复制数据。
	
目前分区实现中的一些其他限制

* 所有分区都必须使用相同的存储引擎
* 分区函数中可以使用的函数和表达式也有一定的限制
* 某些存储引擎不支持分区
* 对于MyISAM的分区表，不能再使用LOAD INDEX INFO CACHE操作
* 对于MyISAM表，使用分区表时需要打开更多的文件描述符。

#### 7.1.5 查询优化
对于访问分区表来说，要在where条件中带入分区列，让优化器过虑掉无须访问的分区。

```
explain partitions select * from sales_by_day where day > '2011-01-01'\G;

//以下语句并不能有效过虑分区
explain partitions select * from sale_by_day where year(day) = 2010\G;

explain partitions select * from sales_by_day where day between '2010-01-01' and '2010-12-31'\G;

```

即使是创建分区时可以使用表达式，但在查询时却只能根据列来过虑分区。

#### 7.1.6 合并表
合并表时应注意：

* 在使用CREATE语句创建一个合并表时，并不会检查各个子表的兼容性。
* 根据合并表的特性，在合并表上无法使用REPLACE语法，无法全用自增字段
* 如果一个查询访问合并表，那么它需要访问所有了表。这会让根据键查找单行的查询速度变慢

### 7.2 视图
```
create view Oceania as select * from Country where Continent = 'Ocenaina' with CHECK OPTION;

//CHECK OPTION表示任何通过视图更新的行，都必须符合视图本身的where条件定义。所以不能更新视图定义列之外的列，也不能插入不同Continent值的新数据。

create TEMPORARY table tmp_oceania_123 as select * from Contry where Continent = 'Oceania';

```

创建视图的方法有： 全并算法(MERGE) 和 临时表算法(TEMPTABLE),如果可能，尽可能地使用合并算法。如果是临时表，EXPLAIN会显示派生表(DERIVED)

MySQL不支持在视图上建任何触发器。

### 7.3 外键约束
MySQL目前只有InnoDB只外键的内置存储引擎（PTXT也有外键支持）

外键可以确保两个相关的表始终有一致的数据。

外键在相关数数的删除与更新上，维护代价要高，因为外键约束使得查询需要额外访问一些别的表，这会导致额外的锁等待，甚至会导致一些死锁。

### 7.4 在MySQL内部存储代码
好处：

* 存储代码在服务器内部执行，离数据最近，另外在服务器上执行还可以节省带宽和网络延迟
* 可以代码重用
* 可以简化代码的维护和版本更新
* 可以帮助提升安全，如提供更细粒度的权限控制
* 服务器端可以缓存存储过程的执行计划，对于反复调用的过程，大大降低消耗
* 在服务器端部署，所以备份，维护都可以在服务端完成
* 在应用开发与数据库开发人员之间更好地分工

缺点：

* MySQL本身没有提供好的开发与高度工具
* 较之应用程序的代码，存储代码效率要稍微差一些
* 存储代码可能会给应用程序代码的部署带来额外的复杂性
* 存储程序都部署在服务器内，会带来安全隐患
* 存储过程会给数据库带来新的压力，数据库服务器的扩展性比应用服务器要差很多
* MySQL并没有什么选项可以控制存储过程的资源消耗，有可能一个小错误，拖死整个服务器
* 存储代码的执行计划是连接级别的，游标的物化与临时表相同
* 调试MySQL的过程是一件困难的事情
* 它和基于语句的二进制日志复制合作得并不好

#### 7.4.1 存储过程和函数
MySQL的架构本身与优化器使得存储代码有一些天然的限制：

* 优化器无法使用关键字DETERMINISTIC来优化单个查询中多次调用存储函数的情况
* 优化器无法评估存储函数的执行成本
* 每个连接都有独立的存储过程执行计划，多个连接需要调用同一个存储过程，将会浪费缓存空间来反复缓存同样的执行计划
* 存储程序与复制是级诡异组合。最好不要复制对存储过程的调用。直接复制由存储程序改变的数据则会更好

```
drop procedure id exists insert_many_row;
delimiter //
create procedure insert_many_rows(IN loops INT)
begin
	declare v1 INT;
	set v1=loops;
	while v1 > 0 do
		insert into test_table_values(NULL, 0,
			'qqqqqqqqqqqwwwwwweeeeeeeeerrrrrttt',
			'qqqqqqqqqqqwwwwwweeeeeeeeerrrrrttt');
		set v1 = v1 -1;
	end while;
end;
//

delimiter;
```

#### 7.4.2 触发器
触发器可以在执行INSERT, UPDATE, DELETE的时候，执行一些特定的操作。触发器本身没有返回值。

触发器可以减少客户端与服务器之间的通信，可以简化应用逻辑，提高性能。

使用触发器应注意：

* 对每一个表的每一个事件，最多只能定义一个触发器, 如不能再AFTER INSERT上定义两个触发器
* MySQL只支持基于行的触发，触发器始终是针对一条记录的，而不是针对整个SQL语句的，如变更的数据集较大，效率会很低

以下限制适用于MySql

* 触发器可以掩盖服务器背后的工作，一个简单的SQL语句的背后，因为触发器，可能包含了很多看不见的工作。
* 触发器的问题很难排查，如果是某个性能问题和触发器相关，会很难分析定位
* 触发器可能导致死锁和锁等待，如果触发器失败，那么原来的SQL语句也会失败

MySQL的触发器的实现是‘基于行的触发’，因为性能的原因，很多时候无法使用触发器来维护汇总各缓存表。使用触发器而不批量更新，使用触发器可以保证数据总是一致的。

触发器不能保更新的原子性。MyISAM如果触发器执行失败，是无法进行数据回滚的。
InnoDB表的触发器是在同一个事件中完成，所以其执行操作是原子性的，原操作与触发器同时成功或失败。不过要小心MVCC,不小心会得到错误的结果。在写BEFORE INSERT触发器来检查写入的数据对应列在另一个表中是存在的，一定要使用SELECT FOR UPDATE。

使用触发的用处：

* 实现一些约束，更新反范式化数据，系统维护任务
* 可以使用触发器来记录数据变更日志

例子：

```
create trigger fake_statement_trigger
before insert on sometable
FOR EACH ROW
BEGIN
	declare v_row_count INT default ROW_COUNT();
	IF v_row_count <> 1 THEN
		--- code here
	END IF;
END
```

#### 7.4.3 事件
事件的典型应用有： 定期地维护任务，重建缓存，构建汇总表来模拟物化视图，或者存储用于监控和诊断的状态值。

```
CRREATE EVENT optimize_somedb ON SCHEDDULE EVERY 1 WEEK
DO
CALL optimize_tables('somedb');

//以下例子确保在同一时期内只有一个相同的事件被触发
//CONTINUE HANDLED用来确保即使当事件出了异常，仍然会释放持有的锁
CREATE EVENT optimize_somedb ON SCHEDULE EVERY 1 WEEK
DO
BEGIN
	DECLARE CONTINUE HANDLERFOR SQLEXCEPTION
		BEGIN END;
	IF GET_LOCK('somedb', 0) THEN
		DO CALL optimize_tables('somed');
	END IF;
	DO RELEASE_LOCK('somedb');
END

//该选项一旦设置，线程就会执行各个用户指定的事件中的各段Sql代码。
SET GLOBAL event_scheduler :=1;
```

#### 7.4.4 在存储程序中保留注释
MySQL命令行客户端会自动过滤掉注释。
可以使用版本相关的注释，这样的注释可能被服务器执行。

只需加一个合适的版本号

```
CREATE TRIGGER fake_statement_trigger
BEFORE INSERT ON sometable
FOR EACH ROW
BEGIN
	DECLARE v_row_count INT DEFAULT ROW_COUNT();
	/*!99999 ROW_COUNT() is 1 expect for the first row, so this executes only once per statement */
	IF v_row_count <> 1 THEN
		--code here
	END IF;
END;
```

### 7.5 游标
MySQL在服务端提供只读的，单向的游标，可以在循环中嵌套地使用，基于临时表实现

### 7.6 绑定变量
```
INSERT INTO tbl(col1, col2, col3) VALUES (?, ?, ?)
```
MySQL通过绑定变量可以更高效地执行大量的重复语句，原因有：

* 在服务器端只需要解析一次SQL语句
* 在服务器端某些优化器的工作只需要执行一次，因为它会缓存一部分的执行计划
* 以二进制的方式只发送参数与句柄，比起每次都发送ASCII码文本效率更高。最大的节省来自于BLOB, TEXT字段，绑定变量的形式可以分块传输，无须一次性传输。二进制协议在客户端也可能节省很多内存，减少网络开销，另外还节省了将数据从存储原始格式转换成文本格式的开销。
* 仅仅传递参数，而不是整个查询语句，所以网络开销更小
* MySQL在存储参数的时候，直接将其放到缓存中，不再需要在内存中多次复制。

#### 7.6.3 绑定变量的限制
* 绑定变量是会话级别的，连接之间不能共用绑定变量句柄。一旦连接断开，则原来的句柄也不有再用了。（连接池的持久化连接可以在一定程度上缓解这个问题）
* 在MySQL5.1之前，绑定变量的SQL是不能使用查询缓存的
* 不是所有的时候使用绑定变量都能获得更好的性能。正确使用绑定变量，还需要在使用完成后，释放相关的资源
* 当前版本下，还不能在存储函数中使用的绑定变量（但是在存储过程中可以使用）
* 如果总是忘记释放绑定变量资源，则在服务器端很容易发生资源泄漏。绑定变量SQL的总数的限制是一个全局限制，所以一个地方的错误可能会对所有其他的线程产生影响。
* 一些操作，如BEGIN，无法在绑定变量中完成

客户端模拟的绑定变量
> 客户端的驱动程序接收一个带参数的SQL,再将指定的值带入其中，最后将完整的查询发送给服务器

服务端的绑定变量
> 客户端使用特殊的二进制协议将带参数的字符串发送到服务器端，然后使用二进制协议将具体的值发送给服务器商并执行

SQL接口的绑定变量
> 客户端先发送一个带参数的字符串到服务端，这类似于使用PREPARE的SQL语句，然后发送设置参数的SQL,最后使用EXECUTE来执行SQL，所有这些使用普通的文本传输协议。

### 7.7 用户自定义函数
存储过程只能使用SQL来缩写，而UDF没有这个限制

必须要确保UDF是线程安全的，因这它们需要在MySQL中执行，而MySQL是一个纯粹的多线程环境。

#### 7.9.1 MySQL如何使用字符集
创建对象时的默认设置

* 创建数据库的时候，将数据库服务器上的character_set_server设置来设定该数据库的默认字符集
* 创建表的时候，将根据数据库的字符集设置来指定表的字符集设置
* 创建列的时候，将根据表的设置来指定列的字符集设置

使用前缀和COLLATE子句来指定字符串的字符或者校对字符集

```
select _utf8 'hello world' COLLATE utf8_bin;
```

一些特殊情况

* 诡异的character_set_database设置
	> 此参数设置的默认值和默认数据库的设置相同时。当改变默认数据库的时候，这个变量也会跟着变。所以当连接到MySQL实例上又没有指定要使用的数据库时，默认值会和character_set_database相同
	
* LOAD DATA INFILE
	> 使用LOAD DATA INFILE的时候，数据库总是将文件中的字符集character_set_database来解析。5.0以后的版本可以在LOAD DATA INFILE中使用子句CHARACTER SET来设置字符集。最好的方式是用USE指定数据库，再行行SET NAMES来设定字符集，最后再加载数据。

* SELECT INFO OUTFILE
	>MYSQL会将SELECT INFO OUTFILE的结果不做任何转码地写入文件。除了使用CONVERT()将所有的列都做一次转码外，没有别的办法能够指定输出的字符集
	
* 嵌入式转义序列
	> MySQL会根据character_set_client的设置来解析转义列，即使是字符串包含前缀或者COLLATE子句也一样。对于解析器来说，前缀并不是一个指令，只是一个关键字
	
数据库的字符设置的极简原则： 最好先为服务器或是数据库选择一个合理的字符集，然后根据不同的实际情况，让某些列选择合适的字符集。

如果是InonoDB表，字符集的改变可能导致数据的大小超过可以在页内存储的临界值，需要保存在额外的外部存储区，这会导致很严重的空间浪费，还会带来很多空间碎片。


### 7.10 全文索引
当前在标准的MySQL中，只有MyISAM引擎支持全文索引。但表级锁对性能的影响，数据文件的崩溃，崩溃后的恢复，使得MyISAM对全文索引对于很多场景并不合适。

全文索引并不索引文档中的所有词语，它会：

* 停用词列表中的词都不会被索引。默认的停用词根据通用英语的使用来设置，可以使用参数`ft_stopword_file`指定一组外部文件来使用自定义的停用词。
* 对于长度大于`ft_min_word_len`的词语和长度小于`ft_max_word_len`的词语，都不会被索引。

#### 7.10.1 自然语言的全文索引
自然语言搜索引擎将计算每一个文档对象和查询的相关度。相关度是基于匹配的关键词个数，以及关键词在文档中的出现的次数。在整个索引中出现次数越少的词语，匹配时的相关度就越高。
```
select film_id, title, right(description, 25),
	match(title, description) against('factory cascualties') as relevance from sakila.film_text where match(title, description) against('factory cascualties');
```
和普通查询不同，这类查询自动按照相似度进行排序。在使用全文索引进行排序的时候，MySQL无法使用索引排序。所以如果不想使用文件排序的话，那么就不在查询中使用order by子句。

在一个查询中使用两次match不会有额外的消耗，MySQL只会做一次搜索。但如果将match()函数放到order by子句中，MySQL将会使用文件排序。

在match()函数中指定的列必须和全文索引中指定的列完全相同。否则就无法使用全文索引。

```
select film_id, right(description, 25),
round(match(title, description) against('factory casualties'), 3) as full_rel,
round(match(title) against('factory casualties'), 3) as title_rel
from sakila.film_text
where match(title, description) against('factory casualties') order by (2 * match(title) against('factory casualties')) + match(title, description) against('factory casuslties') desc;
```

#### 7.10.2 布尔全文索引
在布尔搜索中，用户可以在查询中自定义某个被搜索的词语的相关性。

布尔全文搜索通用修饰符

* dinosaur 包含‘dinosaur’的行rank 值更高
* ~ dinosaur 包含‘dinosaur’的行rank 值更低
* + dinosaur 行记录必须包含‘dinosaur’
* —dinosaur 行记录不可以包含‘dinosaur’
* dino* 包含以‘dino’开头的单词的行rank值更高

```
select film_id, title, right(description, 25)
from sakila.film_text
where match(title, description)
against('+factory +casualties' in boolean mode);

select film_id, title, right(description, 25)
from sakila.film_text
where match(title, description)
against('"spirited casualties"' in boolean mode);
```
只有MyISAM引擎才能使用布尔全文索引，但并不是一定要有全文索引才能使用布尔全文搜索。

MySQL的全文索引只有全部在内存中的时候，性能才非常好。相比其他索引类型，当INSERT,UPDATE, DELETE操作时，全文索引的操作代价很大。

* 修改一段文本中的100个单词，需要100次索引操作，而不是一次
* 列长度直接影响全文索引的性能，三个单词的文本和10000个单词的文本，性能可能相差几个数量级
* 全文索引会有更多的碎片，需要更多的optimize table操作。
* - 
* 全文索引只能做全文搜索匹配。其他的操作如where，都必须在MySQL完成全文搜索返回记录后才能进行。
* 全文索引不存储索引列的实际值，无法使用索引覆盖扫描。
* 除了相关排序，全文索引不能使用其他排序，其他都需要使用文件排序。

#### 7.10.5 全文索引的配置和优化
全文索引需要经常使用optimize table来减少碎片，提升性能。

如果希望全文索引能够高效地工作，需要保证索引缓存足够大，从而保证所有的全文索引都能够缓存在内存中。可以设置键缓存（key cache），保证不会被其他的索引缓存挤出内存。

提供一个好的停用词表。

忽略一些太短的单词，也可以提升全文索引的效率，但会降低精度。

当调整‘允许最小词长’，需要通过Optimize table来重新建立索引才会生效。

全文索引的更新是一个消耗很大的操作，当向一个有全文索引的表中导入大量数据的时候，可以通过disable keys来禁用全文索引，然后在导入数据后enable keys来建立全文索引。

如果数据特别大，还可以对数据进行手动分区。


#### XA事务
MySQL本身的插件式架构导致在其内部需要使用XA事务。XA事务为MySQL带来巨大的性有下降。MySQL复制需要二进制和XA事务的支持，若希望数据尽可能安全，可将sync_binlog设置为1，这时存储引擎和二进制日志才是真正的同步的。强烈建议使用还有电池保护的RAID卡写缓存：这个绑缓存可以大大加快fsync()操作的效率。

因为通信延迟与参与者本身可能失败，所以外部XA事务比内部消耗更大。不稳定的网络通信或是用户长时间地等待而不提交，最好不要使用XA事务。可以在本地写入数据，并将其放入队列，然后在一个更小，更快的事务中自动分发。如果由于某些原因不能使用MySQL本身的复制，或者性能并不是瓶颈的时候，可以尝试使用。

### 7.12 查询缓存
MySQL查询缓存保存查询返回的完整结果。当查询命中该缓存，MySQL会立刻返回结果，跳过了解析，优化和执行阶段。

查询缓存系统会跟踪查询中涉及的每个表，如果这些表发生变化，那么和这个表相关的所有缓存数据都将失效。

当查询的表被lock_tables锁住时，查询仍然可以通过查询缓存返回数据。可以通过参数query_cache_wlock_invalidate打开或关闭这种行为。

缓存放在一个引用表中，通过一个哈希值引用。查询本身，客户端协议，协议版本号都会影响哈希值。不规范的编码规则也会影响查询哈希值。

当查询语句中有一些不确定的数据时，如now(), current_data(),current_user, connected_id()这样的查询都不会缓存。事实上，只要查询中包含任何用户自定义函数，存储函数，用户变量，临时表，mysql库听系统表，或者任何包含列级别权限的表，都不会缓存。

查询缓存需要注意：

* 打开查询缓存对读和写操作都会带来额外的消耗。
* 读查询在开始之前必须先检查是否命中缓存。
* 缓存的存储与清除，都会来额外的系统消耗。
* 对写操作的影响。表数据发生变化，相关的缓存都将设置为失效。若查询缓存非常大或是碎片很多，同样会带来很大的系统消耗。
* 对于事务会限制查询缓存。在事务被提交之前，表的相关查询是无法缓存的。长时间运行的事务，会大大降低查询缓存的效率。

当服务器启动时候，它先初始化查询缓存所需要的缓存。当需要缓存时会从大的空间块申请一块小内存。这个内存要大于参数query_cache_min_res_unit的配置，即使查询结果远小于这个值，也要申请这么多空间。

对于消耗大量资源的查询通常是适合缓存的，如一些汇总查询count()；多表join后还需要做排序和分页，这类查询每次消耗都很大，但返回结果集却是很小，适合查询缓存。

缓存命中率：Qcache_hits/(Qcache_hits+Com_select)

只要查询缓存带来的效率提升大于查询缓存带来的额外消耗，对系统性能提升就有好外。

缓存未命中有以下原因：

* 查询无法缓存，可有查询中有不确定的函数，或者查询结果太大无法缓存。这些会导致Qcache_not_cached增加
* MySQL从未处理这个查询，所以结果不曾缓存过
* 若查询缓存内存吃紧，会将某些缓存‘逐出’，数据被修改导致缓存失效。

若大多数查询被缓存，但依然没有命中：

* 查询缓存没有完成预热。MySQL还没有机会将查询结果缓存起来
* 查询语句之前从未执行过。应用不会重复执行一条语句，那么完成预热仍然会有很多缓存未命中
* 缓存失效操作太多了
* 缓存碎片，内存不足，数据修改都会造成缓存失效。

参数说明：

* Com_update, Com_delete可以数据修改情况
* Qcache_lowmen_prunes可以查看多少次失效是由于而在不足引起的
* Com_select, Qcache_inserts相对值可以看缓存的结果在失效前没有被任何select语句使用。若每次查询操作都未命中缓存，然后需要将查询结果放到缓存中，那么Qcache_inserts的大小和Com_select相当。
* 命中与写入的比率：即Qcache_hits, Qcache_inserts的比值，通常大于3：1查询缓存是有效的，最好能达到10：1.

#### 7.12.4 如何配置和维护查询缓存
* query\_caceh_type

	> 是否打开查询缓存。可以设置为OFF, ON, DEMAND,DEMAND表示只有在SQL中明确写明SQL_CACHE的语句才会放入缓存中。变量分为会话级和全局级。
* query\_cache_size
	> 查询缓存使用的内存空间，单位是字节。这个数值必须是1024的整数倍，否则系统实际分配和指定略有不同
* query\_cache\_min\_res_unit
	> 查询缓存中分配内存块时的最小单位。设置合适的值可以平衡每个数据块的大小和每次存储结果时内存块申请的次数。值太小，可以节省空间，但会导致频繁申请操作；值太大，会出现碎片。调整合适的值其实是在平衡内存浪费与CPU消耗。
* query\_cache_limit
	> MySQL能够缓存的最大查询结果。大于这个值，则不会缓存。只有全部数据返回后，MySQL才知道结果是否走出限制。
* query\_caceh_wlock_invalidate
	> 如果某个数据表被其他的连接锁住，是否依然从查询缓存中返回结果。默认是OFF.


查询缓存实际消耗：
(query_cache_size-Qcache_free_memory)/Qcaceh_queries_in_cache,计算单个查询的平均缓存大小。如果此值有的很大，有的很小，那么碎片与反复内存分配无法避免。

可以通过Qcache_free_blocks来观察碎片。如果Qcache_free_blocks大小正好是Qcache_total_blocks/2,那么查询缓存有严重的碎片问题。而如果有很多空闲块，而状态值Qcache_lowmem_prunes还不断地增加，则说明由于碎片导致了过早地在删除查询缓存结果。

FLUSH QUERY CACHE完成碎片整理，将所有查询缓存重新排序，并将所有空闲空间都聚集到查询缓存的一块区域上，不过这会导致服务僵死一段时间。清空缓存则由命令RESET QUERY CACHE来完成。

##### 提高查询缓存的使用率
当查询缓存内存空间太小，新的查询无法缓存的时候，MySQL会删除某个老的缓存结果，并增加状态值Qcache_lowmem_prunes，如果这个值增加地快，可能是：

* 若还有很多空闲块，那么碎片是罪魁祸首
* 若没什么空闲块，则可能是系统压力下，分配的查询缓存空间不够大。可以通检查状态值Qcache_free_memory来查看还有有多少未使用的内存。

可能通过将query_caceh_size设置为0，来关闭查询缓存。改变query_cache_type的全局值并不会影响已经打开的连接，也不会将查询缓存的内存释放给系统。

#### 7.12.5 InnoDB和查询缓存
如果表上有任何的锁，那么这个表的任何查询语句都是无法缓存的。如若某条语句执行了 select for update，在这个锁释放之前，任何其他的事务都无法从查询缓存中读取这个表相关的缓存结果。

* 所有大于该表计数器的事务才可以使用查询缓存。
* 该表的计数器并不是直接更新为对该表进行加锁的事务ID,而是被更新成一个系统事务ID.所以，会发现该事务自身后续的更新操作也无法读取和修改查询缓存。













