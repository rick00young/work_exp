
```
textFile = spark.read.text("hdfs://localhost:9000//user/hive/warehouse/README.md")

textFile.first()

textFile.filter(textFile.value.contains('Spark')).count()

from pyspark.sql.functions import *
textFile.select(size(split(textFile.value, "\s+")).name("numWords")).agg(max(col("numWords"))).collect()

textFile.select(explode(split(textFile.value, "\s+")).alias("word")).groupBy("word").count().colllect()
[Row(word=u'online', count=1), Row(word=u'graphs', count=1),
```


```
from pyspark import SparkContext, SparkConf
conf = SparkConf().setAppName('test').setMaster()
```

//rdd
```
lines = sc.textFile("/Users/rick/src/hadoop/spark-2.2.1-bin-hadoop2.7/data/graphx/data.txt")
pairs = lines.map(lambda s: (s, 1))
counts = pairs.reduceByKey(lambda a, b: a + b)
```

//SQL, dataFrames DataSets


//Creating DataFrames

```
# spark is an existing SparkSession
df = spark.read.json("examples/src/main/resources/people.json")
# Displays the content of the DataFrame to stdout
df.show()
# +----+-------+
# | age|   name|
# +----+-------+
# |null|Michael|
# |  30|   Andy|
# |  19| Justin|
# +----+-------+

```

```
//Untyped Dataset Operations (aka DataFrame Operations)
# spark, df are from the previous example
# Print the schema in a tree format
df.printSchema()
# root
# |-- age: long (nullable = true)
# |-- name: string (nullable = true)

# Select only the "name" column
df.select("name").show()
# +-------+
# |   name|
# +-------+
# |Michael|
# |   Andy|
# | Justin|
# +-------+

# Select everybody, but increment the age by 1
df.select(df['name'], df['age'] + 1).show()
# +-------+---------+
# |   name|(age + 1)|
# +-------+---------+
# |Michael|     null|
# |   Andy|       31|
# | Justin|       20|
# +-------+---------+

# Select people older than 21
df.filter(df['age'] > 21).show()
# +---+----+
# |age|name|
# +---+----+
# | 30|Andy|
# +---+----+

# Count people by age
df.groupBy("age").count().show()
# +----+-----+
# | age|count|
# +----+-----+
# |  19|    1|
# |null|    1|
# |  30|    1|
# +----+-----+
```

```
//Running SQL Queries Programmatically
# Register the DataFrame as a SQL temporary view
df.createOrReplaceTempView("people")

sqlDF = spark.sql("SELECT * FROM people")
sqlDF.show()
# +----+-------+
# | age|   name|
# +----+-------+
# |null|Michael|
# |  30|   Andy|
# |  19| Justin|
# +----+-------+
```

```
//global temporay view
# Register the DataFrame as a global temporary view
df.createGlobalTempView("people")

# Global temporary view is tied to a system preserved database `global_temp`
spark.sql("SELECT * FROM global_temp.people").show()
# +----+-------+
# | age|   name|
# +----+-------+
# |null|Michael|
# |  30|   Andy|
# |  19| Justin|
# +----+-------+

# Global temporary view is cross-session
spark.newSession().sql("SELECT * FROM global_temp.people").show()
# +----+-------+
# | age|   name|
# +----+-------+
# |null|Michael|
# |  30|   Andy|
# |  19| Justin|
# +----+-------+
```

```
from pyspark.sql import Row

sc = spark.sparkContext

# Load a text file and convert each line to a Row.
lines = sc.textFile("examples/src/main/resources/people.txt")
parts = lines.map(lambda l: l.split(","))
people = parts.map(lambda p: Row(name=p[0], age=int(p[1])))

# Infer the schema, and register the DataFrame as a table.
schemaPeople = spark.createDataFrame(people)
schemaPeople.createOrReplaceTempView("people")

# SQL can be run over DataFrames that have been registered as a table.
teenagers = spark.sql("SELECT name FROM people WHERE age >= 13 AND age <= 19")

# The results of SQL queries are Dataframe objects.
# rdd returns the content as an :class:`pyspark.RDD` of :class:`Row`.
teenNames = teenagers.rdd.map(lambda p: "Name: " + p.name).collect()
for name in teenNames:
    print(name)
```

```
Programmatically Specifying the Schema
# Import data types
from pyspark.sql.types import *

sc = spark.sparkContext

# Load a text file and convert each line to a Row.
lines = sc.textFile("examples/src/main/resources/people.txt")
parts = lines.map(lambda l: l.split(","))
# Each line is converted to a tuple.
people = parts.map(lambda p: (p[0], p[1].strip()))

# The schema is encoded in a string.
schemaString = "name age"

fields = [StructField(field_name, StringType(), True) for field_name in schemaString.split()]
schema = StructType(fields)

# Apply the schema to the RDD.
schemaPeople = spark.createDataFrame(people, schema)

# Creates a temporary view using the DataFrame
schemaPeople.createOrReplaceTempView("people")

# SQL can be run over DataFrames that have been registered as a table.
results = spark.sql("SELECT name FROM people")

results.show()
# +-------+
# |   name|
# +-------+
# |Michael|
# |   Andy|
# | Justin|
# +-------+
```

```
Aggregations

```

###  Spark基本原理以及核心概念  Spark基本工作原理 
1. Client客户端：我们在本地编写了spark程序，打成jar包，或python脚本,通过spark submit命令提交到Spark集群； 
2. 只有Spark程序在Spark集群上运行才能拿到Spark资源，来读取数据源的数据进入到内存里； 
3. 客户端就在Spark分布式内存中并行迭代地处理数据，注意每个处理过程都是在内存中并行迭代完成；注意：每一批节点上的每一批数据，实际上就是一个RDD！！！一个RDD是分布式的，所以数据都散落在一批节点上了，每个节点都存储了RDD的部分partition。 
4. Spark与MapReduce最大的不同在于，迭代式计算模型：MapReduce，分为两个阶段，map和reduce，两个阶段完了，就结束了，所以我们在一个job里能做的处理很有限； Spark，计算模型，可以分为n个阶段，因为它是内存迭代式的。我们在处理完一个阶段以后，可以继续往下处理很多个阶段，而不只是两个阶段。所以，Spark相较于MapReduce来说，计算模型可以提供更强大的功能。

### RDD以及其特性 
1. RDD是Spark提供的核心抽象，全称为Resillient Distributed Dataset，即弹性分布式数据集; 
2. RDD在抽象上来说是一种元素集合，包含了数据。它是被分区的，分为多个分区，每个分区分布在集群中的不同节点上，从而让RDD中的数据可以被并行操作。（分布式数据集）; 
3. RDD通常通过Hadoop上的文件，即HDFS文件或者Hive表，来进行创建；有时也可以通过应用程序中的集合来创建; 
4. RDD最重要的特性就是，提供了容错性，可以自动从节点失败中恢复过来。即如果某个节点上的RDD partition，因为节点故障，导致数据丢了，那么RDD会自动通过自己的数据来源重新计算该partition。这一切对使用者是透明的; 
5. RDD的数据默认情况下存放在内存中的，但是在内存资源不足时，Spark会自动将RDD数据写入磁盘。（弹性）。

### 问题：RDD分布式是什么意思？ 
* 一个RDD，在逻辑上，抽象地代表了一个HDFS文件；但是，它实际上是被分为多个分区；多个分区散落在Spark集群中，不同的节点上。比如说，RDD有900万数据。分为9个partition，9个分区。
### 问题：RDD弹性是什么意思，体现在哪一方面？ 
* RDD的每个partition，在spark节点上存储时，默认都是放在内存中的。但是如果说内存放不下这么多数据时，比如每个节点最多放50万数据，结果你每个partition是100万数据。那么就会把partition中的部分数据写入磁盘上，进行保存。 
而上述这一切，对于用户来说，都是完全透明的。也就是说，你不用去管RDD的数据存储在哪里，内存，还是磁盘。只要关注，你针对RDD来进行计算，和处理，等等操作即可。所以说，RDD的这种自动进行内存和磁盘之间权衡和切换的机制，就是RDD的弹性的特点所在。

### 问题：RDD容错性体现在哪方面？ 
* 现在，节点9出了些故障，导致partition9的数据丢失了。那么此时Spark会脆弱到直接报错，直接挂掉吗？不可能！！ 
RDD是有很强的容错性的，当它发现自己的数据丢失了以后，会自动从自己来源的数据进行重计算，重新获取自己这份数据，这一切对用户，都是完全透明的。

### 什么是Spark开发 
1. 核心开发：离线批处理 / 延迟性的交互式数据处理 
Spark的核心编程是什么？其实，就是： 
首先，第一，定义初始的RDD，就是说，你要定义第一个RDD是从哪里，读取数据，hdfs、linux本地文件、程序中的集合。 
第二，定义对RDD的计算操作，这个在spark里称之为算子，map、reduce、flatMap、groupByKey，比mapreduce提供的map和reduce强大的太多太多了。 
第三，其实就是循环往复的过程，第一个计算完了以后，数据可能就会到了新的一批节点上，也就是变成一个新的RDD。然后再次反复，针对新的RDD定义计算操作。。。。 
第四，最后，就是获得最终的数据，将数据保存起来。 
2. SQL查询：底层都是RDD和计算操作 
3. 实时计算：底层都是RDD和计算操作

### 两种方式实现word_count
```
//1.
textFile = spark.read.textFile("../readme.md")
val words = textFile.flatMap({line => line.split(" ")}).groupByKey(identity).count()
var wordCounts = words.collect()

//2.
textFile = sctextFile("../readme.md")
val words = textFile.flatMat(line => line.split(" "))
val wordsCount = words.map(line => (line, 1)).reduceByKey((x, y) => x+ y)
```
### spark中的RDD究竟怎么理解？
rdd是spark的灵魂，中文翻译弹性分布式数据集，一个rdd代表一个可以被分区的只读数据集。rdd内部可以有许多分区(partitions)，每个分区又拥有大量的记录(records)。

rdd的五个特征：

* dependencies:建立RDD的依赖关系，主要rdd之间是宽窄依赖的关系，具有窄依赖关系的rdd可以在同一个stage中进行计算。
* partition：一个rdd会有若干个分区，分区的大小决定了对这个rdd计算的粒度，每个rdd的分区的计算都在一个单独的任务中进行。
* preferedlocations:按照“移动数据不如移动计算”原则，在spark进行任务调度的时候，优先将任务分配到数据块存储的位置
* compute：spark中的计算都是以分区为基本单位的，compute函数只是对迭代器进行复合，并不保存单次计算的结果。
* partitioner：只存在于（K,V）类型的rdd中，非（K,V）类型的partitioner的值就是None。

rdd的算子主要分成2类，action和transformation。这里的算子概念，可以理解成就是对数据集的变换。action会触发真正的作业提交，而transformation算子是不会立即触发作业提交的。每一个 transformation() 方法返回一个 新的RDD。只是某些transformation() 比较复杂，会包含多个子 transformation()，因而会生成多个 RDD。这就是实际 RDD 个数比我们想象的多一些 的原因。通常是，当遇到action算子时会触发一个job的提交，然后反推回去看前面的transformation算子，进而形成一张有向无环图。在DAG中又进行stage的划分，划分的依据是依赖是否是shuffle的，每个stage又可以划分成若干task。接下来的事情就是driver发送task到executor，executor自己的线程池去执行这些task，完成之后将结果返回给driver。action算子是划分不同job的依据。shuffle dependency是stage划分的依据。

再说几观点：spark程序中，我们用到的每一个rdd，在丢失或者操作失败后都是重建的。rdd更多的是一个逻辑概念，我们对于rdd的操作最终会映射到内存或者磁盘当中，也就是操作rdd通过映射就等同于操作内存或者磁盘。在实际的生产环境中，rdd内部的分区数以及分区内部的记录数可能远比我们想象的多。RDD 本身的依赖关系由 transformation() 生成的每一个 RDD 本身语义决定。每个 RDD 中的 compute() 调用 parentRDD.iter() 来将 parent RDDs 中的 records 一个个 拉取过来。

### Spark Streaming之updateStateByKey和mapWithState比较

[https://www.cnblogs.com/clnchanpin/p/7098822.html](https://www.cnblogs.com/clnchanpin/p/7098822.html)

UpdateStateByKey：统计全局的key的状态，但是就算没有数据输入，他也会在每一个批次的时候返回之前的key的状态。假设5s产生一个批次的数据，那么5s的时候就会更新一次的key的值，然后返回。

这样的缺点就是，如果数据量太大的话，而且我们需要checkpoint数据，这样会占用较大的存储。

如果要使用updateStateByKey,就需要设置一个checkpoint目录，开启checkpoint机制。因为key的state是在内存维护的，如果宕机，则重启之后之前维护的状态就没有了，所以要长期保存它的话需要启用checkpoint，以便恢复数据。

MapWithState：也是用于全局统计key的状态，但是它如果没有数据输入，便不会返回之前的key的状态，有一点增量的感觉。

这样做的好处是，我们可以只是关心那些已经发生的变化的key，对于没有数据输入，则不会返回那些没有变化的key的数据。这样的话，即使数据量很大，checkpoint也不会像updateStateByKey那样，占用太多的存储。

```
StatefulNetworkWordCount

object StatefulNetworkWordCount {
def main(args: Array[String]) {
if (args.length < 2) {
  System.err.println("Usage: StatefulNetworkWordCount <hostname> <port>")
  System.exit(1)
}

Logger.getLogger("org.apache.spark").setLevel(Level.WARN)

val updateFunc = (values: Seq[Int], state: Option[Int]) => {
  val currentCount = values.sum

  val previousCount = state.getOrElse(0)

  Some(currentCount + previousCount)
}

val newUpdateFunc = (iterator: Iterator[(String, Seq[Int], Option[Int])]) => {
  iterator.flatMap(t => updateFunc(t._2, t._3).map(s => (t._1, s)))
}

val sparkConf = new SparkConf().setAppName("StatefulNetworkWordCount").setMaster("local")
// Create the context with a 1 second batch size
val ssc = new StreamingContext(sparkConf, Seconds(1))
ssc.checkpoint(".")

// Initial RDD input to updateStateByKey
val initialRDD = ssc.sparkContext.parallelize(List(("hello", 1), ("world", 1)))

// Create a ReceiverInputDStream on target ip:port and count the
// words in input stream of \n delimited test (eg. generated by 'nc')
val lines = ssc.socketTextStream(args(0), args(1).toInt)
val words = lines.flatMap(_.split(" "))
val wordDstream = words.map(x => (x, 1))

// Update the cumulative count using updateStateByKey
// This will give a Dstream made of state (which is the cumulative count of the words)
val stateDstream = wordDstream.updateStateByKey[Int](newUpdateFunc,
  new HashPartitioner (ssc.sparkContext.defaultParallelism), true, initialRDD)
stateDstream.print()
ssc.start()
ssc.awaitTermination()
}
}

NetworkWordCount


import org.apache.spark.SparkConf
import org.apache.spark.HashPartitioner
import org.apache.spark.streaming.{Seconds, StreamingContext}
import org.apache.spark.streaming.StreamingContext._

object NetworkWordCount {
  def main(args: Array[String]) {
    if (args.length < 2) {
      System.err.println("Usage: NetworkWordCount <hostname> <port>")
      System.exit(1)
    }


    val sparkConf = new SparkConf().setAppName("NetworkWordCount")
    val ssc = new StreamingContext(sparkConf, Seconds(10))
    //使用updateStateByKey前须要设置checkpoint
    ssc.checkpoint("hdfs://master:8020/spark/checkpoint")

    val addFunc = (currValues: Seq[Int], prevValueState: Option[Int]) => {
      //通过Spark内部的reduceByKey按key规约。然后这里传入某key当前批次的Seq/List,再计算当前批次的总和
      val currentCount = currValues.sum
      // 已累加的值
      val previousCount = prevValueState.getOrElse(0)
      // 返回累加后的结果。是一个Option[Int]类型
      Some(currentCount + previousCount)
    }

    val lines = ssc.socketTextStream(args(0), args(1).toInt)
    val words = lines.flatMap(_.split(" "))
    val pairs = words.map(word => (word, 1))

    //val currWordCounts = pairs.reduceByKey(_ + _)
    //currWordCounts.print()

    val totalWordCounts = pairs.updateStateByKey[Int](addFunc)
    totalWordCounts.print()

    ssc.start()
    ssc.awaitTermination()
  }
}
```



### Spark RDD collect与collectPartitions
collectPartitions：同样属于Action的一种操作，同样也会将数据汇集到Driver节点上，与collect区别并不是很大，唯一的区别是：collectPartitions产生数据类型不同于collect，collect是将所有RDD汇集到一个数组里，而collectPartitions是将各个分区内所有元素存储到一个数组里，再将这些数组汇集到driver端产生一个数组；collect产生一维数组，而collectPartitions产生二维数组。


例：
RDD类型data，数据类型为[labeledPoint]，labeledPoint为（label，features）

那么 val collectArr = data.collect();(collectArr内数组元素为labeledPoint[label，features])

而val collectPArr= data.collectPartitions();(collectPArr内数组元素为Array[label,features]，即为二维数组)


```
val data = Seq(
  (7, Vectors.dense(0.0, 0.0, 18.0, 1.0), 1.0),
  (8, Vectors.dense(0.0, 1.0, 12.0, 0.0), 0.0),
  (9, Vectors.dense(1.0, 0.0, 15.0, 0.1), 0.0)
)

val df = spark.createDataset(data).toDF("id", "features", "clicked")

```

###谈谈RDD、DataFrame、Dataset的区别和各自的优势
```
转化：
RDD、DataFrame、Dataset三者有许多共性，有各自适用的场景常常需要在三者之间转换

DataFrame/Dataset转RDD：
这个转换很简单
val rdd1=testDF.rdd
val rdd2=testDS.rdd


RDD转DataFrame：
import spark.implicits._
val testDF = rdd.map {line=>
      (line._1,line._2)
    }.toDF("col1","col2")
一般用元组把一行的数据写在一起，然后在toDF中指定字段名

RDD转Dataset：
import spark.implicits._
case class Coltest(col1:String,col2:Int)extends Serializable //定义字段名和类型
val testDS = rdd.map {line=>
      Coltest(line._1,line._2)
    }.toDS
可以注意到，定义每一行的类型（case class）时，已经给出了字段名和类型，后面只要往case class里面添加值即可

Dataset转DataFrame：
这个也很简单，因为只是把case class封装成Row
import spark.implicits._
val testDF = testDS.toDF

DataFrame转Dataset：
import spark.implicits._
case class Coltest(col1:String,col2:Int)extends Serializable //定义字段名和类型
val testDS = testDF.as[Coltest]
这种方法就是在给出每一列的类型后，使用as方法，转成Dataset，这在数据类型是DataFrame又需要针对各个字段处理时极为方便

特别注意：
在使用一些特殊的操作时，一定要加上 import spark.implicits._ 不然toDF、toDS无法使用
```


### udf
```
def allInOne(seq: Seq[Any], sep: String): String = seq.mkString(sep)

在sql中使用

sqlContext.udf.register("allInOne", allInOne _)

//将col1,col2,col3三个字段合并，使用','分割
val sql =
    """
      |select allInOne(array(col1,col2,col3),",") as col
      |from tableName
    """.stripMargin
sqlContext.sql(sql).show()


在DataFrame中使用

import org.apache.spark.sql.functions.{udf，array,lit}
val myFunc = udf(allInOne _)
val cols = array("col1","col2","col3")
val sep = lit(",")
df.select(myFunc(cols,sep).alias("col")).show()

```

### Spark DataFrame一行分割为多行
```
scala> movies.show(truncate = false)
+-------+---------+-----------------------+
|movieId|movieName|genre                  |
+-------+---------+-----------------------+
|1      |example1 |action|thriller|romance|
|2      |example2 |fantastic|action       |
+-------+---------+-----------------------+

假设有DataFrame movies如上所示，要将genre字段按|切开，并将切开的每个子集保存为一行该如何操作？

scala> movies.withColumn("genre", explode(split($"genre", "[|]"))).show
+-------+---------+---------+
|movieId|movieName|    genre|
+-------+---------+---------+
|      1| example1|   action|
|      1| example1| thriller|
|      1| example1|  romance|
|      2| example2|fantastic|
|      2| example2|   action|
+-------+---------+---------+

```
### save Spark dataframe to Hive: table not readable because “parquet not a SequenceFile”

```
spark-shell>sqlContext.sql("SET spark.sql.hive.convertMetastoreParquet=false")
spark-shell>df.write
              .partitionBy("ts")
              .mode(SaveMode.Overwrite)
              .saveAsTable("Happy_HIVE")//Suppose this table is saved at /apps/hive/warehouse/Happy_HIVE


hive> DROP TABLE IF EXISTS Happy_HIVE;
hive> CREATE EXTERNAL TABLE Happy_HIVE (user_id string,email string,ts string)
                                       PARTITIONED BY(day STRING)
                                       STORED AS PARQUET
                                       LOCATION '/apps/hive/warehouse/Happy_HIVE';
hive> MSCK REPAIR TABLE Happy_HIVE;
```