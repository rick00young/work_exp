## Flume架构以及应用介绍
### Hadoop业务的整体开发流程： 
Flume数据采集->MapReduce清洗->存入HBase->Hive统计,分析->存入Hive表->Sqoop导出->Mysql数据库->Web展示

### 3、flume架构介绍 
flume之所以这么神奇，是源于它自身的一个设计，这个设计就是agent，agent本身是一个java进程，运行在日志收集节点—所谓日志收集节点就是服务器节点。 
agent里面包含3个核心的组件：source—->channel—–>sink,类似生产者、仓库、消费者的架构。 

source：source组件是专门用来收集数据的，可以处理各种类型、各种格式的日志数据,包括avro、thrift、exec、jms、spooling directory、netcat、sequence generator、syslog、http、legacy、自定义。 

channel：source组件把数据收集来以后，临时存放在channel中，即channel组件在agent中是专门用来存放临时数据的——对采集到的数据进行简单的缓存，可以存放在memory、jdbc、file等等。 

sink：sink组件是用于把数据发送到目的地的组件，目的地包括hdfs、logger、avro、thrift、ipc、file、null、hbase、solr、自定义。 
### 4、flume的运行机制 
flume的核心就是一个agent，这个agent对外有两个进行交互的地方，一个是接受数据的输入——source，一个是数据的输出sink，sink负责将数据发送到外部指定的目的地。source接收到数据之后，将数据发送给channel，channel作为一个数据缓冲区会临时存放这些数据，随后sink会将channel中的数据发送到指定的地方—-例如HDFS等，注意：只有在sink将channel中的数据成功发送出去之后，channel才会将临时数据进行删除，这种机制保证了数据传输的可靠性与安全性。 
### 5、flume的广义用法 
flume之所以这么神奇—-其原因也在于flume可以支持多级flume的agent，即flume可以前后相继，例如sink可以将数据写到下一个agent的source中，这样的话就可以连成串了，可以整体处理了。flume还支持扇入(fan-in)、扇出(fan-out)。所谓扇入就是source可以接受多个输入，所谓扇出就是sink可以将数据输出多个目的地destination中。

### 总结
最后对上面用的几个flume source进行适当总结： 

* ① NetCat Source：监听一个指定的网络端口，即只要应用程序向这个端口里面写数据，这个source组件 
就可以获取到信息。 
* ②Spooling Directory Source：监听一个指定的目录，即只要应用程序向这个指定的目录中添加新的文 
件，source组件就可以获取到该信息，并解析该文件的内容，然后写入到channle。写入完成后，标记 
该文件已完成或者删除该文件。 
* ③Exec Source：监听一个指定的命令，获取一条命令的结果作为它的数据源 
常用的是tail -F file指令，即只要应用程序向日志(文件)里面写数据，source组件就可以获取到日志(文件)中最新的内容 。
	* 总结Exec source：Exec source和Spooling Directory Source是两种常用的日志采集的方式，其中Exec source可以实现对日志的实时采集，Spooling Directory Source在对日志的实时采集上稍有欠缺，尽管Exec source可以实现对日志的实时采集，但是当Flume不运行或者指令执行出错时，Exec source将无法收集到日志数据，日志会出现丢失，从而无法保证收集日志的完整性。 
* ④Avro Source：监听一个指定的Avro 端口，通过Avro 端口可以获取到Avro client发送过来的文件 。即只要应用程序通过Avro 端口发送文件，source组件就可以获取到该文件中的内容。