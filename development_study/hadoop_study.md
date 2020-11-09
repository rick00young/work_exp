### Hadoop安装完后，启动时报Error: JAVA_HOME is not set and could not be found.

解决办法：

```
修改/etc/hadoop/hadoop-env.sh中设JAVA_HOME。
应当使用绝对路径。
export JAVA_HOME=$JAVA_HOME                  //错误，不能这么改
export JAVA_HOME=/usr/local/lib/jdk1.8.0_60        //正确，应该这么改
```

export JAVA_HOME=/usr/java/jdk1.8.0_91



Delete all docker containers

docker rm $(docker ps -a -q)
Delete all docker images

docker rmi $(docker images -q)