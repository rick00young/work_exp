## 数据面试-Spark
### Sparks相关
1. 公司之后倾向用spark 开发,你会么(就用java代码去写)?
	* spark使用scala开发的，在scala中可以随意使用jdk的类库，可以用java开发，但是最好用原生的scala开发，兼容性好，scala更灵活。
	
2. spark原理  
	* Spark应用转换流程
		* 1.spark应用提交后，经历了一系列的转换，最后成为task在每个节点上执行
		* 2.RDD的Action算子触发Job的提交，生成RDD DAG
		* 3.由DAGScheduler将RDD DAG转化为Stage DAG，每个Stage中产生相应的Task集合
		* 4.TaskScheduler将任务分发到Executor执行
		* 5.每个任务对应相应的一个数据块，只用用户定义的函数处理数据块


	* Driver运行在Worker上
	* 通过org.apache.spark.deploy.Client类执行作业，作业运行命令如下：
	* 作业执行流程描述：
		* 1、客户端提交作业给Master
		* 2、Master让一个Worker启动Driver，即SchedulerBackend。Worker创建一个DriverRunner线程，DriverRunner启动SchedulerBackend进程。
		* 3、另外Master还会让其余Worker启动Exeuctor，即ExecutorBackend。Worker创建一个ExecutorRunner线程，ExecutorRunner会启动ExecutorBackend进程。
		* 4、ExecutorBackend启动后会向Driver的SchedulerBackend注册。SchedulerBackend进程中包含DAGScheduler，它会根据用户程序，生成执行计划，并调度执行。对于每个stage的task，都会被存放到TaskScheduler中，ExecutorBackend向SchedulerBackend汇报的时候把TaskScheduler中的task调度到ExecutorBackend执行。
		* 5、所有stage都完成后作业结束。
		
	* Driver运行在客户端
	* 作业执行流程描述：
		* 1、客户端启动后直接运行用户程序，启动Driver相关的工作：DAGScheduler和BlockManagerMaster等。
		* 2、客户端的Driver向Master注册。
		* 3、Master还会让Worker启动Exeuctor。Worker创建一个ExecutorRunner线程，ExecutorRunner会启动ExecutorBackend进程。
		* 4、ExecutorBackend启动后会向Driver的SchedulerBackend注册。Driver的DAGScheduler解析作业并生成相应的Stage，每个Stage包含的Task通过TaskScheduler分配给Executor执行。
		* 5、所有stage都完成后作业结束。