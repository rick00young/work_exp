## HBase
[https://www.jianshu.com/p/569106a3008f](https://www.jianshu.com/p/569106a3008f)

### HBase与关系型数据库比较
diff | Hbase | rdbms
----|----|---
数据类型 | 字符串 | 丰富的数据类型
数据操作 | 简单增删改查 | 丰富的SQL支持
存储模式 | 列存储 | 行存储
数据保护 | 保留 | 替换
可伸缩性 | 好 | 差

## 扩展:
* 通过横向添加RegionServer进行水平扩展,提升Hbase上层处理能力,提升Hbase服务更多Region的能力
* 通过横向添加Datanode机器,进行存储层扩容,提升Hbase存储能力各提升后端读写能力.

## Column Family
Hbase表创建的时候,必须指定列族,列簇并不是越多越好, 最好小于或是等于3, 一般都是1个.

## Rowkey
Rowkey的概念和mysql中的主键是完全一样的，Hbase使用Rowkey来唯一的区分某一行的数据。
由于Hbase只支持3中查询方式：

* 基于Rowkey的单行查询
* 基于Rowkey的范围扫描
* 全表扫描

## Region
Region的概念和关系型数据库的分区或者分片差不多。

* Hbase会将一个大表的数据基于Rowkey的不同范围分配到不通的Region中，每个Region负责一定范围的数据访问和存储。这样即使是一张巨大的表，由于被切割到不通的region，访问起来的时延也很低。

##  Timestamp
TimeStamp对Hbase来说至关重要，因为它是实现Hbase多版本的关键。在Hbase中使用不同的timestame来标识相同rowkey行对应的不通版本的数据。

在写入数据的时候，如果用户没有指定对应的timestamp，Hbase会自动添加一个timestamp，timestamp和服务器时间保持一致。

在Hbase中，相同rowkey的数据按照timestamp倒序排列。默认查询的是最新的版本，用户可同指定timestamp的值来读取旧版本的数据。

## Hbase架构
Hbase是由Client、Zookeeper、Master、HRegionServer、HDFS等几个组建组成

* Client

Client包含了访问Hbase的接口，另外Client还维护了对应的cache来加速Hbase的访问，比如cache的.META.元数据的信息

* Zookeeper

Hbase通过Zookeeper来做master的高可用、RegionServer的监控、元数据的入口以及集群配置的维护等工作。具体工作如下：

通过Zoopkeeper来保证集群中只有1个master在运行，如果master异常，会通过竞争机制产生新的master提供服务

通过Zoopkeeper来监控RegionServer的状态，当RegionSevrer有异常的时候，通过回调的形式通知Master RegionServer上下限的信息

通过Zoopkeeper存储元数据的统一入口地址

* Hmaster

master节点的主要职责如下：

为RegionServer分配Region

维护整个集群的负载均衡

维护集群的元数据信息

发现失效的Region，并将失效的Region分配到正常的RegionServer上

当RegionSever失效的时候，协调对应Hlog的拆分

* HregionServer

HregionServer直接对接用户的读写请求，是真正的“干活”的节点。它的功能概括如下：

管理master为其分配的Region

处理来自客户端的读写请求

负责和底层HDFS的交互，存储数据到HDFS

负责Region变大以后的拆分

负责Storefile的合并工作

* HDFS

HDFS为Hbase提供最终的底层数据存储服务，同时为Hbase提供高可用（Hlog存储在HDFS）的支持，具体功能概括如下：

提供元数据和表数据的底层分布式存储服务

数据多副本，保证的高可靠和高可用性

* Hbase的使用场景

Hbase是一个通过廉价PC机器集群来存储海量数据的分布式数据库解决方案。它比较适合的场景概括如下：

是巨量大（百T、PB级别）

查询简单（基于rowkey或者rowkey范围查询）

不涉及到复杂的关联

有几个典型的场景特别适合使用Hbase来存储：

海量订单流水数据（长久保存）

交易记录

数据库历史数据

## Region的拆分 
Hbase Region的拆分策略有比较多，比如除了3种默认过的策略，还有DelimitedKeyPrefixRegionSplitPolicy、KeyPrefixRegionSplitPolicy、DisableSplitPolicy等策略，这里只介绍3种默认的策略。分别是ConstantSizeRegionSplitPolicy策略、IncreasingToUpperBoundRegionSplitPolicy策略和SteppingSplitPolicy策略。

* ConstantSizeRegionSplitPolicy

ConstantSizeRegionSplitPolicy策略是0.94版本之前的默认拆分策略，这个策略的拆分规则是：当region大小达到hbase.hregion.max.filesize（默认10G）后拆分。

这种拆分策略对于小表不太友好，按照默认的设置，如果1个表的Hfile小于10G就一直不会拆分。注意10G是压缩后的大小，如果使用了压缩的话。

如果1个表一直不拆分，访问量小也不会有问题，但是如果这个表访问量比较大的话，就比较容易出现性能问题。这个时候只能手工进行拆分。还是很不方便。

* IncreasingToUpperBoundRegionSplitPolicy

IncreasingToUpperBoundRegionSplitPolicy策略是Hbase的0.94~2.0版本默认的拆分策略，这个策略相较于ConstantSizeRegionSplitPolicy策略做了一些优化，该策略的算法为：min(r^2*flushSize，maxFileSize )，最大为maxFileSize 。

从这个算是我们可以得出flushsize为128M、maxFileSize为10G的情况下，可以计算出Region的分裂情况如下：
第一次拆分大小为：min(10G，1*1*128M)=128M

第二次拆分大小为：min(10G，3*3*128M)=1152M

第三次拆分大小为：min(10G，5*5*128M)=3200M

第四次拆分大小为：min(10G，7*7*128M)=6272M

第五次拆分大小为：min(10G，9*9*128M)=10G

第五次拆分大小为：min(10G，11*11*128M)=10G

从上面的计算我们可以看到这种策略能够自适应大表和小表，但是这种策略会导致小表产生比较多的小region，对于小表还是不是很完美。

* SteppingSplitPolicy

SteppingSplitPolicy是在Hbase 2.0版本后的默认策略，，拆分规则为：If region=1 then: flush size * 2 else: MaxRegionFileSize。

还是以flushsize为128M、maxFileSize为10场景为列，计算出Region的分裂情况如下：

第一次拆分大小为：2*128M=256M

第二次拆分大小为：10G

从上面的计算我们可以看出，这种策略兼顾了ConstantSizeRegionSplitPolicy策略和IncreasingToUpperBoundRegionSplitPolicy策略，对于小表也肯呢个比较好的适配。


## Hbase中存储设计主要思想
SML树原理把一棵大树拆分成N棵小树，它首先写入内存中，随着小树越来越大，内存中的小树会flush到磁盘中，磁盘中的树定期可以做merge操作，合并成一棵大树，以优化读性能。

* 因为小树先写到内存中，为了防止内存数据丢失，写内存的同时需要暂时持久化到磁盘，对应了HBase的MemStore和HLog
* MemStore上的树达到一定大小之后，需要flush到HRegion磁盘中（一般是Hadoop DataNode），这样MemStore就变成了DataNode上的磁盘文件StoreFile，定期HRegionServer对DataNode的数据做merge操作，彻底删除无效空间，多棵小树在这个时机合并成大树，来增强读性能。


```
//创建表
> create 'testtable', 'colfam1'

> list 'testtable'
> put 'testtable', 'myrow-1', 'colfam1:q1', 'value-1'
> put 'testtable', 'myrow-2', 'colfam1:q2', 'value-2'
> put 'testtable', 'myrow-2', 'colfam1:q3', 'value-3'

//确认新增的数据是否能被检索
> scan 'testtable'
> 或 get 'testtable', 'myrow-1'
//删除数据
> delte 'testtable', 'myrow-2', 'colfam1:q2'
> scan 'testtable'
//禁用并删除表
> disable 'testtable'
> drop 'testtable'
//退出
> exit

//与ruby混用
> for i in 'a'..'z' do for j in 'a'..'z' do put 'testtable', "row-#{i}#{j}", "colfam:#{j}", "#{j}" end end
> scan 'test',{VERSIONS => 3}

> create 'testtable2', 'colfam1', {SPLITS => ['row-300', 'row-500', 'row-700', 'row-900']}
> for i in '0'..'9' do for j in '0'..'9' do for k in '0'..'9' do put 'testtable2', "row-#{i}#{j}#{k}", "colfam1:#{j}#{j}", "#{j}#{k}" end end end
> flush "testtable2"


> create 'web', 'contents', 'anchor', 'people'
> put 'web', 'com.cn.www', 'contents:html', 'test'
> put 'web', 'com.cn.www', 'anchor:href', 'www.baidu.com'
```

### 名词
LSM树 log-structed merge-tree树

TTL time-to-live

Write-Ahead Log: WAL预写日志

用户应当将需要查询的维度或信息存储在行键中,因为它的筛选数据效率最高

### demo
[https://www.cnblogs.com/cxzdy/p/5583239.html](https://www.cnblogs.com/cxzdy/p/5583239.html)

要注意shutdown与exit之间的不同：shutdown表示关闭hbase服务，必须重新启动hbase才可以恢复，exit只是退出hbase shell,退出之后完全可以重新进入。

* hbase使用坐标来定位表中的数据，行健是第一个坐标，下一个坐标是列族。

* hbase是一个在线系统，和hadoop mapreduce的紧密结合又赋予它离线访问的功能。

* hbase接到命令后存下变化信息或者写入失败异常的抛出，默认情况下。执行写入时会写到两个地方：预写式日志（write-ahead log,也称hlog）和memstore,以保证数据持久化。memstore是内存里的写入缓冲区。客户端在写的过程中不会与底层的hfile直接交互，当menstore写满时，会刷新到硬盘，生成一个新的hfile.hfile是hbase使用的底层存储格式。menstore的大小由hbase-site.xml文件里的系统级属性hbase.hregion.memstore.flush.size来定义。

* hbase在读操作上使用了lru缓存机制（blockcache），blockcache设计用来保存从hfile里读入内存的频繁访问的数据，避免硬盘读。每个列族都有自己的blockcache。blockcache中的block是hbase从硬盘完成一次读取的数据单位。block是建立索引的最小数据单位，也是从硬盘读取的最小数据单位。如果主要用于随机查询，小一点的block会好一些，但是会导致索引变大，消耗更多内存，如果主要执行顺序扫描，大一点的block会好一些，block变大索引项变小，因此节省内存。

* LRU是Least Recently Used 近期最少使用算法。内存管理的一种页面置换算法，对于在内存中但又不用的数据块（内存块）叫做LRU，操作系统会根据哪些数据属于LRU而将其移出内存而腾出空间来加载另外的数据。

 

* 数据模型概括：

	* 表（table）---------hbase用表来组织数据。表名是字符串（string）,由可以在文件系统路径里使用的字符组成。

	* 行（row）---------在表里，数据按行存储。行由行健（rowkey）唯一标识。行健没有数据类型，总是视为字节数组byte[].

	* 列族（column family）-----------行里的数据按照列族分组，列族也影响到hbase数据的物理存放。因此，它们必须事前定义并且不轻易修改。表中每行拥有相同列族，尽管行不需要在每个列族里存储数据。列族名字是字符串，由可以在文件系统路径里使用的字符组成。(HBase建表是可以添加列族，alter 't1', {NAME => 'f1', VERSIONS => 5} 把表disable后alter,然后enable)

	* 列限定符（column qualifier）--------列族里的数据通过列限定符或列来定位。列限定符不必事前定义。列限定符不必在不同行之间保持一致，就像行健一样，列限定符没有数据类型，总是视为字节数组byte[].

	* 单元（cell）-------行健，列族和列限定符一起确定一个单元。存储在单元里的数据称为单元值（value），值也没有数据类型，总是视为字节数组byte[].

	* 时间版本（version）--------单元值有时间版本，时间版本用时间戳标识，是一个long。没有指定时间版本时，当前时间戳作为操作的基本。hbase保留单元值时间版本的数量基于列族进行配置。默认数量是3个。

* hbase在表里存储数据使用的是四维坐标系统，依次是：行健，列族，列限定符和时间版本。 hbase按照时间戳降序排列各时间版本，其他映射建按照升序排序。

* hbase把数据存放在一个提供单一命名空间的分布式文件系统上。一张表由多个小一点的region组成，托管region的服务器叫做regionserver.单个region大小由配置参数hbase.hregion.max.filesize决定，当一个region大小变得大于该值时，会切分成2个region.

* hbase是一种搭建在hadoop上的数据库。依靠hadoop来实现数据访问和数据可靠性。hbase是一种以低延迟为目标的在线系统，而hadoop是一种为吞吐量优化的离线系统。互补可以搭建水平扩展的数据应用。

HBASE中的表示按column family来存储的

```
//建立一个有3个column family的表
create 't1', {NAME => 'f1', VERSIONS => 1}, {NAME => 'f2', VERSIONS => 1}, {NAME => 'f3', VERSIONS => 1}
//定义表的时候只需要指定column family的名字，列名在put的时候动态指定
//插入数据
//下面插入没有指定column的名字
put 't1', 'r1', 'f1', 'v1'
put 't1', 'r2', 'f2', 'v2'
put 't1', 'r3', 'f3', 'v3'

//下面插入指定column的名字
put 't1', 'r4', 'f1:c1', 'v1'
put 't1', 'r5', 'f2:c2', 'v2'
put 't1', 'r6', 'f3:c3', 'v3'
```

# HBase 权威指南
## 每一章
HBase的存储架构中，出现NULL的列可以省略，因此空值是没有任何港人消耗的，不占用任何空间。

所有数据通过row按字典顺序存储。
每个HFile都有一个块索引，在内存中进行二分查找，确定可以包含的键。

因为存储文件是不可被删除的，所以无法通过移除某个键/值对来删除值，可以做个删除标记，在检索过程中，删除标记掩盖了实际值，客户端读不到实际值。


文件合并：
	1. minor合并：将多个小文件合并为数量较少的大文件，减少存储文件的数量，多路全并，因为HFile都是经过归类的，所以合并很快，只受磁盘i/o影响。
	2. major合并：将一个region中的一个一列族的若干个HFile重写为一个新HFile，与minor合并相比，major合并扫描所有的键值对，顺序重写全部的数据，此时会删除做了删除标记的数据。

这种架构来源于LSM树(Log-Structured Sort-and-Merge-Mpa)

主服务器提供负载均衡与集群管理，不为region服务器或客户端提供数据服务，属于轻量服务器，此外还提供了元数据的管理，如建表与创建列族。

后台运维可以处理预先设定的删除请求，TTL触发。

在没有太多的修改时，B+树表现的很好。

HBase 主要处理两种文件： 一种是预写日志(Write-Ahead Log WAL)，一种是实际的数据文件。

关闭region服务器 会强制所有的memstore被刷写到磁盘。


## 第九章
HBase表的数据分割主要是使用列族而不是列。
磁盘上一个列族下所有的单元格都存储在一个存储文件（store file）中，不同列族的单元格不会存在同一个存储文件中。
同一个单元格的多个版本被存储为连续的单元格。

keyvalue设计时考虑把一些得要的筛选信息左移到合适的位置，加快查询效率。

用户将需要查询的维度或信息存储在行键中，用它筛选数据效率最高。

HBase只能按列分片，因此高表更有优势。


为避免同一个rowkey下数据太多，写入数据过于集中而导致整个系统性能下降，可以使用salting方式，在rowkey前加前缀，将数据打散，这样的缺点是查询时需要对多个region服务器发起请求，但也带来好处，可以多线程并行读取数据。
也可以字段交换提升权重


 