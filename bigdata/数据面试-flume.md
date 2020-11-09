## 数据面试-Flume
### Flume相关
1. 数据怎么采集到Kafka，实现方式?
	* 使用官方提供的flumeKafka插件，插件的实现方式是自定义了flume的sink，将数据从channle中取出，通过kafka的producer写入到kafka中，
可以自定义分区等。

2. flume管道内存，flume宕机了数据丢失怎么解决?
	* 1、Flume的channel分为很多种，可以将数据写入到文件
	* 2、防止非首个agent宕机的方法数可以做集群或者主备
3. flume配置方式，flume集群（问的很详细）
	* Flume的配置围绕着source、channel、sink叙述，flume的集群是做在agent上的，而非机器上。
	
4. flume不采集Nginx日志，通过Logger4j采集日志，优缺点是什么？
	* 优点：Nginx的日志格式是固定的，但是缺少sessionid，通过logger4j采集的日志是带有sessionid的，而session可以通过redis共享，
保证了集群日志中的同一session落到不同的tomcat时，sessionId还是一样的，而且logger4j的方式比较稳定，不会宕机。
	* 缺点：不够灵活，logger4j的方式和项目结合过于紧密，而flume的方式比较灵活，拔插式比较好，不会影响项目性能。

5. flume和kafka采集日志区别，采集日志时中间停了，怎么记录之前的日志。
	* Flume采集日志是通过流的方式直接将日志收集到存储层，而kafka试讲日志缓存在kafka集群，待后期可以采集到存储层。
	* Flume采集中间停了，可以采用文件的方式记录之前的日志，而kafka是采用offset的方式记录之前的日志。

