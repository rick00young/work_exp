### Scala $的用法

> Scala 代码中发现 $ 符具有在String 中直接拼接 字符串 和数字 等类型 。简化了字符串拼接的困扰，是Scala不错的设计。

```
object  ForTest  {
	def main(args:Array[String]):Unit= {
		val word="abcds "
		val num=123
		println(s"see there is a word $word and a Num $num")
	}
}
```
 
### Scala shell 使用外部包方法
 
```
//1.引用单个包
scala
Welcome to Scala 2.12.7 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_181).
Type in expressions for evaluation. Or try :help.

scala> :require /path/something/commons.jar


//2.使用脚本方式
cat scala.sh

#!/bin/bash
allJars=""
for file in /Users/lake/project/target/lib/*
do
  allJars="$allJars:$file"
done

scala -cp $allJars

./scala.sh

//3.
scala -classpath  spark_scala_demo.jar 
```