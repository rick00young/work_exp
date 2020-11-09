```
//导数据到hdfs
sqoop import --connect jdbc:mysql://localhost:3306/employees --username root --password root --table employees --target-dir /user/hive/warehouse/employees

//导数据,并创建hive表
sqoop import --connect jdbc:mysql://localhost:3306/employees --username root --password root --table employees --target-dir /user/hive/warehouse/employees --hive-table data_mysql.employees --fields-terminated-by "\t" --lines-terminated-by "\n" --hive-import --hive-overwrite --create-hive-table --delete-target-dir




//导weg_log数据,并创建hive表
sqoop import --connect jdbc:mysql://localhost:3306/hive --username root --password root --table web_log --target-dir /user/hive/warehouse/web_log --hive-table data_mysql.web_log --fields-terminated-by "\t" --lines-terminated-by "\n" --hive-import --hive-overwrite --create-hive-table --delete-target-dir

```