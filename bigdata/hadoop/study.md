## 文件操作  

* 查看目录文件  * $ hadoop dfs -ls /user/cl  

* 创建文件目录  * $ hadoop dfs -mkdir /user/cl/temp  

* 删除文件  * $ hadoop dfs -rm /user/cl/temp/a.txt   

* 删除目录与目录下所有文件  * $ hadoop dfs -rmr /user/cl/temp    
* cat
	使用方法：hadoop fs -cat URI [URI …]
	
	将路径指定文件的内容输出到stdout。
	
	示例：
	
	hadoop fs -cat hdfs://host1:port1/file1 hdfs://host2:port2/file2
	hadoop fs -cat file:///file3 /user/hadoop/file4
	
	hadoop fs -text file | head -n 100

## 上传文件  

* 上传一个本机/home/cl/local.txt到hdfs中/user/cl/temp目录下  

* $ hadoop dfs -put /home/cl/local.txt /user/cl/temp    

## 下载文件  

* 下载hdfs中/user/cl/temp目录下的hdfs.txt文件到本机/home/cl/中  

* $ hadoop dfs -get /user/cl/temp/hdfs.txt /home/cl   

* 查看文件  * $ hadoop dfs –cat /home/cl/hdfs.txt  

* 将制定目录下的所有内容merge成一个文件，下载到本地

* hadoop dfs -getmerge /hellodir wa 

```
copyFromLocal
使用方法：hadoop fs -copyFromLocal <localsrc> URI

copyToLocal
使用方法：hadoop fs -copyToLocal [-ignorecrc] [-crc] URI <localdst>

除了限定目标路径是一个本地文件外，和get命令类似。
```

## Job操作

 * 提交MapReduce Job, Hadoop所有的MapReduce Job都是一个jar包

 * $ hadoop jar <local-jar-file> <java-class> <hdfs-input-file> <hdfs-output-dir>

 * $ hadoop jar sandbox-mapred-0.0.20.jar sandbox.mapred.WordCountJob /user/cl/input.dat /user/cl/outputdir  *  * 杀死某个正在运行的Job  * 假设Job_Id为：job_201207121738_0001  * $ hadoop job -kill job_201207121738_0001

 
## map reduce  yarn
> yarn允许应用程序为任务请求任意规模的内存量(需在预定范围内),节点管理器从一个内存池中中分配内存,这意味着可同时运行数据依赖于内存需求量,而非槽数量
>
> 基于槽的模型导致集群未被充分利用,原因是map和reduce的槽之间的比率是固定的,不同的阶段,map-reduce的槽的需求会不断变化. 

## hadoop 名词解释
* ResourceManager：是YARN资源控制框架的中心模块，负责集群中所有的资源的统一管理和分配。它接收来自NM(NodeManager)的汇报，建立AM，并将资源派送给AM(ApplicationMaster)。

* NodeManager:简称NM，NodeManager是ResourceManager在每台机器的上代理，负责容器的管理，并监控他们的资源使用情况（cpu，内存，磁盘及网络等），以及向 ResourceManager提供这些资源使用报告。

* ApplicationMaster:以下简称AM。YARN中每个应用都会启动一个AM，负责向RM申请资源，请求NM启动container，并告诉container做什么事情。

* Container：资源容器。YARN中所有的应用都是在container之上运行的。AM也是在container上运行的，不过AM的container是RM申请的。

* 1.Container是YARN中资源的抽象，它封装了某个节点上一定量的资源（CPU和内存两类资源）。

* 2.Container由ApplicationMaster向ResourceManager申请的，由ResouceManager中的资源调度器异步分配给ApplicationMaster；

* 3.Container的运行是由ApplicationMaster向资源所在的NodeManager发起的，Container运行时需提供内部执行的任务命令（可以是任何命令，比如java、Python、C++进程启动命令均可）以及该命令执行所需的环境变量和外部资源（比如词典文件、可执行文件、jar包等）。

另外，一个应用程序所需的Container分为两大类，如下：
* （1） 运行ApplicationMaster的Container：这是由ResourceManager（向内部的资源调度器）申请和启动的，用户提交应用程序时，可指定唯一的ApplicationMaster所需的资源；
* （2） 运行各类任务的Container：这是由ApplicationMaster向ResourceManager申请的，并由ApplicationMaster与NodeManager通信以启动之。
以上两类Container可能在任意节点上，它们的位置通常而言是随机的，即ApplicationMaster可能与它管理的任务运行在一个节点上。

* 整个MapReduce的过程大致分为 Map-->Shuffle（排序）-->Combine（组合）-->Reduce