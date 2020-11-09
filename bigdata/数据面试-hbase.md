## 数据面试-HBase
### HBase相关
1. Hbase 的特性,以及你怎么去设计 rowkey 和 columnFamily ,怎么去建一个table?
	* 因为hbase是列式数据库，列非表schema的一部分，所以在设计初期只需要考虑rowkey 和 columnFamily即可，rowkey有位置相关性，所以如果数据是练习查询的，最好对同类数据加一个前缀，而每个columnFamily实际上在底层是一个文件，那么文件越小，查询越快，所以讲经
常一起查询的列设计到一个列簇，但是列簇不宜过多。
2. 什么是HBase?
	* Hbase是分布式、面向列的开源数据库（其实准确的说是面向列族）。HDFS为Hbase提供可靠的底层数据存储服务，MapReduce为Hbase提供高性能的计算能力，Zookeeper为Hbase提供稳定服务和Failover机制，因此我们说Hbase是一个通过大量廉价的机器解决海量数据的高速存储和读取的分布式数据库解决方案。
	* 海量存储, 列式存储, 极易扩展, 高并发, 稀疏4

3. HMaster的作用
hmaster的作用
	* 为region server分配region.
	* 负责region server的负载均衡。
	* 发现失效的region server并重新分配其上的region.
	* Gfs上的垃圾文件回收。
	* 处理schema更新请求。