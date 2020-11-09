## 数据面试-Kafka
### Kafka相关
1. 容错机制
	* 分区备份，存在主备partition
2. 同一topic不同partition分区
	* ？？？？
3. kafka数据流向
	* Producer  leader partition  follower partition(半数以上) consumer

4. kafka中存储目录data/dir.....topic1和topic2怎么存储的，存储结构，data.....目录下有多少个分区，每个分区的存储格式是什么样的？
	* 1、topic是按照“主题名-分区”存储的
	* 2、分区个数由配置文件决定
	* 3、每个分区下最重要的两个文件是0000000000.log和000000.index，0000000.log以默认1G大小回滚。

好处
以下是Kafka的几个好处 -

可靠性 - Kafka是分布式，分区，复制和容错的。

可扩展性 - Kafka消息传递系统轻松缩放，无需停机。

耐用性 - Kafka使用分布式提交日志，这意味着消息会尽可能快地保留在磁盘上，因此它是持久的。

性能 - Kafka对于发布和订阅消息都具有高吞吐量。 即使存储了许多TB的消息，它也保持稳定的性能。

Kafka非常快，并保证零停机和零数据丢失。