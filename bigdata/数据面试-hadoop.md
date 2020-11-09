## 数据面试-Hadoop
### Hadoop相关
1. hadoop 的 namenode 宕机,怎么解决?
	* 先分析宕机后的损失，宕机后直接导致client无法访问，内存中的元数据丢失，但是硬盘中的元数据应该还存在，如果只是节点挂了， 重启即可，如果是机器挂了，重启机器后看节点是否能重启，不能重启就要找到原因修复了。但是最终的解决方案应该是在设计集群的初期

2. 一个datanode 宕机,怎么一个流程恢复?
	* Datanode宕机了后，如果是短暂的宕机，可以实现写好脚本监控，将它启动起来。如果是长时间宕机了，那么datanode上的数据应该已经被备份到其他机器了，那这台datanode就是一台新的datanode了，删除他的所有数据文件和状态文件，重新启动。

3. 一些传统的hadoop 问题,mapreduce 他就问shuffle 阶段,你怎么理解的?
	* Shuffle意义在于将不同map处理后的数据进行合理分配，让reduce处理，从而产生了排序、分区。

4. yarn流程是什么?
[https://www.cnblogs.com/chushiyaoyue/p/5784871.html](https://www.cnblogs.com/chushiyaoyue/p/5784871.html)
	* 1) 用户向`YARN`中提交应用程序，其中包括`ApplicationMaster` 程序、启动`ApplicationMaster` 的命令、用户程序等。
	* 2) `ResourceManager`为该应用程序分配第一个`Container`， 并与对应的`NodeManager`通信，要求它在这个`Container`中启动应用程序
的`ApplicationMaster`。
	* 3) ApplicationMaster 首先向ResourceManager 注册， 这样用户可以直接通过ResourceManage 查看应用程序的运行状态，然后它将为各个任务申请资源，并监控它的运行状态，直到运行结束，即重复步骤4~7。
	* 4) ApplicationMaster 采用轮询的方式通过RPC 协议向ResourceManager 申请和领取资源。
	* 5) 一旦ApplicationMaster 申请到资源后，便与对应的NodeManager 通信，要求它启动任务。
	* 6) NodeManager 为任务设置好运行环境（包括环境变量、JAR 包、二进制程序等）后，将任务启动命令写到一个脚本中，并通过运行
该脚本启动任务。
	* 7) 各个任务通过某个RPC 协议向ApplicationMaster 汇报自己的状态和进度，以让ApplicationMaster 随时掌握各个任务的运行状态，从而可以在任务失败时重新启动任务。在应用程序运行过程中，用户可随时通过RPC 向ApplicationMaster 查询应用程序的当前运行状态。
	* 8) 应用程序运行完成后，ApplicationMaster 向ResourceManager 注销并关闭自己。

5. 简述hadoop的调度器
	* FIFO schedular：默认，先进先出的原则
	* Capacity schedular：计算能力调度器，选择占用最小、优先级高的先执行，依此类推
	* Fair schedular：公平调度，所有的job具有相同的资源。

6. MapReduce中combine、partition、shuffle的作用是什么?
	* combine分为map端和reduce端，作用是把同一个key的键值对合并在一起，可以自定义的。所以combiner也可以看作特殊的Reducer。
		* 不是每种作业都可以做combiner操作的，只有满足以下条件才可以 
		* combiner只应该用于那种Reduce的输入key/value与输出key/value类型完全一致，因为combine本质上就是reduce操作
		* 计算逻辑上，combine操作后不会影响计算结果，像求和，最大值就不会影响，求平均值就影响了。
	* partition: partition是分割map每个节点的结果，按照key分别映射给不同的reduce，也是可以自定义的。这里其实可以理解归类。
我们对于错综复杂的数据归类。比如在动物园里有牛羊鸡鸭鹅，他们都是混在一起的，但是到了晚上他们就各自牛回牛棚，羊回羊圈，鸡回鸡窝。partition的作用就是把这些数据归类。只不过在写程序的时候，mapreduce使用哈希HashPartitioner帮我们归类了。这个我们也可以自定义。
	* shuffle过程有一部分是在Map端，有一部分是在Reduce端
		* 完整地从map task端拉取数据到reduce 端。
		* 在跨节点拉取数据时，尽可能地减少对带宽的不必要消耗。
		* 减少磁盘IO对task执行的影响。

	* 总结: shuffle就是map和reduce之间的过程，包含了两端的combiner和partition
	
	难点：
	
	*	不知道这个reduce和mapreduce中的reduce区别是什么?
下面简单说一下：后面慢慢琢磨：在mapreduce中，map多，reduce少。
在reduce中由于数据量比较多，所以干脆，我们先把自己map里面的数据归类，这样到了reduce的时候就减轻了压力。

7. Shuffle产生的意义是什么？
Shuffle过程的期望可以有： 
	* 完整地从map task端拉取数据到reduce 端。
	* 在跨节点拉取数据时，尽可能地减少对带宽的不必要消耗。
	* 减少磁盘IO对task执行的影响。

8. 每个map task都有一个内存缓冲区，存储着map的输出结果，当缓冲区快满的时候需要将缓冲区的数据该如何处理？
	* 每个map task都有一个内存缓冲区，存储着map的输出结果，当缓冲区快满的时候需要将缓冲区的数据以一个临时文件的方式存放到磁盘，当整个map task结束后再对磁盘中这个map task产生的所有临时文件做合并，生成最终的正式输出文件，然后等待reduce task来拉数据。

9. MapReduce提供Partitioner接口，它的作用是什么？
	* MapReduce提供Partitioner接口，它的作用就是根据key或value及reduce的数量来决定当前的这对输出数据最终应该交由哪个reduce task处理。默认对key hash后再以reduce task数量取模。默认的取模方式只是为了平均reduce的处理能力，如果用户自己对Partitioner有需求，可以订制并设置到job上。

10. 什么是溢写？
	* 在一定条件下将缓冲区中的数据临时写入磁盘，然后重新利用这块缓冲区。这个从内存往磁盘写数据的过程被称为Spill，中文可译为溢写。
	
11. 溢写是为什么不影响往缓冲区写map结果的线程？
	* 溢写线程启动时不应该阻止map的结果输出，所以整个缓冲区有个溢写的比例spill.percent。这个比例默认是0.8，也就是当缓冲区的数据已经达到阈值（buffer size * spill percent = 100MB * 0.8 = 80MB），溢写线程启动，锁定这80MB的内存，执行溢写过程。Map task的输出结果还可以往剩下的20MB内存中写，互不影响。

12. 当溢写线程启动后，需要对这80MB空间内的key做排序(Sort)。排序是MapReduce模型默认的行为，这里的排序也是对谁的排序？
	* 当溢写线程启动后，需要对这80MB空间内的key做排序(Sort)。排序是MapReduce模型默认的行为，这里的排序也是对序列化的字节做的排序。 

13. 溢写过程中如果有很多个key/value对需要发送到某个reduce端去，那么如何处理这些key/value值？
	* 如果有很多个key/value对需要发送到某个reduce端去，那么需要将这些key/value值拼接到一块，减少与partition相关的索引记录。

14. 哪些场景才能使用Combiner呢？
	* Combiner的输出是Reducer的输入，Combiner绝不能改变最终的计算结果。所以从我的想法来看，Combiner只应该用于那种Reduce的输入key/value与输出key/value类型完全一致，且不影响最终结果的场景。比如累加，最大值等。Combiner的使用一定得慎重，如果用好，它对job执行效率有帮助，反之会影响reduce的最终结果。 

15. Merge的作用是什么？
	* 最终磁盘中会至少有一个这样的溢写文件存在(如果map的输出结果很少，当map执行完成时，只会产生一个溢写文件)，因为最终的文件只有一个，所以需要将这些溢写文件归并到一起，这个过程就叫做Merge

16. 每个reduce task不断的通过什么协议从JobTracker那里获取map task是否完成的信息？
	* 每个reduce task不断地通过RPC从JobTracker那里获取map task是否完成的信息

17. reduce中Copy过程采用是什么协议？
	* Copy过程，简单地拉取数据。Reduce进程启动一些数据copy线程(Fetcher)，通过HTTP方式请求map task所在的TaskTracker获取map task的输出文件。

18. reduce中merge过程有几种方式？
	* merge有三种形式：1)内存到内存  2)内存到磁盘  3)磁盘到磁盘。默认情况下第一种形式不启用，让人比较困惑，是吧。当内存中的数据量到达一定阈值，就启动内存到磁盘的merge。与map 端类似，这也是溢写的过程，这个过程中如果你设置有Combiner，也是会启用的，然后在磁盘中生成了众多的溢写文件。第二种merge方式一直在运行，直到没有map端的数据时才结束，然后启动第三种磁盘到磁盘的merge方式生成最终的那个文件。

19.  Mapreduce 的 map 数量 和 reduce 数量 怎么确定 ,怎么配置?
	* map的数量由数据块决定，reduce数量随便配置。 
20. shuffle 阶段,你怎么理解的 
	* shuffle过程包括在Map和Reduce两端中。 
21. 我们开发job时，是否可以去掉reduce阶段。 
	* 可以。设置reduce数为0 即可。 
22. datanode在什么情况下不会备份 
	* datanode在强制关闭或者非正常断电不会备份。 
 
23. hdfs的体系结构 
	* hdfs有namenode、secondraynamenode、datanode组成。 为n+1模式 
	* namenode负责管理datanode和记录元数据 
	* secondraynamenode负责合并日志 
	* datanode负责存储数据 

24. 3个datanode中有一个datanode出现错误会怎样？ 
	* 这个datanode的数据会在其他的datanode上重新做备份。 
25. 描述一下hadoop中，有哪些地方使用了缓存机制，作用分别是什么？ 
	* 在mapreduce提交job的获取id之后，会将所有文件存储到分布式缓存上，这样文件可以被所有的mapreduce共享。 
26. 如何确定hadoop集群的健康状态 
	* 通过页面监控,脚本监控。 
27. 避免namenode故障导致集群宕机的解决方法是什么？ 
	* 自己书写脚本监控重启 
28.  Mapreduce 的 map 数量 和 reduce 数量 怎么确定 ,怎么配置 
	* map的数量由数据块决定，reduce数量随便配置。

[http://www.aboutyun.com/forum.php?mod=viewthread&tid=21404&extra=page%3D1](http://www.aboutyun.com/forum.php?mod=viewthread&tid=21404&extra=page%3D1)
29. 过程解析：详解
这里描述的 是一个256M的文件上传过程 
	* ① 由客户端 向 NameNode节点节点 发出请求
	* ②NameNode 向Client返回可以可以存数据的 DataNode 这里遵循  机架感应  原则

	* ③客户端 首先 根据返回的信息 先将 文件分块（Hadoop2.X版本 每一个block为 128M 而之前的版本为 64M）
	* ④然后通过那么Node返回的DataNode信息 直接发送给DataNode 并且是 流式写入  同时 会复制到其他两台机器
	* ⑤dataNode 向 Client通信 表示已经传完 数据块 同时向NameNode报告
	* ⑥依照上面（④到⑤）的原理将 所有的数据块都上传结束 向 NameNode 报告 表明 已经传完所有的数据块 
	
30. HDFS在上传文件的时候，如果其中一个块突然损坏了怎么办
	* 其中一个块坏了，只要有其它块存在，会自动检测还原。

31. NameNode的作用
	* namenode总体来说是管理和记录恢复功能。
	* 比如管理datanode，保持心跳，如果超时则排除。
	* 对于上传文件都有镜像images和edits,这些可以用来恢复。更多：
深度了解namenode---其 内部关键数据结构原理简介

32. NameNode的HA
	* NameNode的HA一个备用，一个工作，且一个失败后，另一个被激活。他们通过journal node来实现共享数据。
更多:Hadoop之NameNode+ResourceManager高可用原理分析

33. combiner出现在那个过程 
	* 出现在map阶段的map方法后等。

34. shuffer的流程是什么?
	[https://www.cnblogs.com/jxhd1/p/6528633.html](https://www.cnblogs.com/jxhd1/p/6528633.html)
	[http://blog.csdn.net/tanggao1314/article/details/51275812](http://blog.csdn.net/tanggao1314/article/details/51275812)
	* Shuffle实际上包括map端和reduce端的两个过程，在map端中我们称之为前半段，在reduce端我们称之为后半段
	* Shuffle前半段过程主要包括：
		* 1、split过程
	
		> 在map task执行时，它的输入数据来源于HDFS的block，当然在MapReduce概念中，map task只读取split。Split与block的对应关系可能是多对一，默认是一对一.将文件拆分成splits(片)，并将每个split按行分割形成<key,value>对.
		
		* 2、partition过程：partition是分割map每个节点的结果，按照key分别映射给不同的reduce，也是可以自定义的。
		* 3、溢写过程
		* 4、Merge过程
	* 简单地说，reduce task在执行之前的工作就是不断地拉取当前job里每个map task的最终结果，然后对从不同地方拉取过来的数据不断地做merge，也最终形成一个文件作为reduce task的输入文件
	* Shuffle在reduce端的过程也能用三点来概括, 当前reduce copy数据的前提是它要从JobTracker获得有哪些map task已执行结束。Reducer真正运行之前，所有的时间都是在拉取数据，做merge，且不断重复地在做
		* 1.Copy过程，简单地拉取数据。Reduce进程启动一些数据copy线程(Fetcher)，通过HTTP方式请求map task所在的TaskTracker获取map task的输出文件。因为map task早已结束，这些文件就归TaskTracker管理在本地磁盘中。 
		* 2.Merge阶段。这里的merge如map端的merge动作，只是数组中存放的是不同map端copy来的数值。Copy过来的数据会先放入内存缓冲区中，这里的缓冲区大小要比map端的更为灵活，它基于JVM的heap size设置，因为Shuffle阶段Reducer不运行，所以应该把绝大部分的内存都给Shuffle用。这里需要强调的是，merge有三种形式：1)内存到内存  2)内存到磁盘  3)磁盘到磁盘。默认情况下第一种形式不启用，让人比较困惑，是吧。当内存中的数据量到达一定阈值，就启动内存到磁盘的merge。与map 端类似，这也是溢写的过程，这个过程中如果你设置有Combiner，也是会启用的，然后在磁盘中生成了众多的溢写文件。第二种merge方式一直在运行，直到没有map端的数据时才结束，然后启动第三种磁盘到磁盘的merge方式生成最终的那个文件。 
		* 3.Reducer的输入文件。不断地merge后，最后会生成一个“最终文件”。为什么加引号？因为这个文件可能存在于磁盘上，也可能存在于内存中。对我们来说，当然希望它存放于内存中，直接作为Reducer的输入，但默认情况下，这个文件是存放于磁盘中的。当Reducer的输入文件已定，整个Shuffle才最终结束。然后就是Reducer执行，把结果放到HDFS上。 	