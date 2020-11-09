# mysql_study
### 1. mysql5.7 datetime 默认值为‘0000-00-00 00:00:00'值无法创建问题解决

新建表结构

```
DROP TABLE IF EXISTS `yx_test`;
CREATE TABLE `yx_test` (
      `mobile` char(11) NOT NULL DEFAULT '' COMMENT '手机号',
      `is_delete` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态,0.删除，1.正常',
      `deleted_at` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '删除时间',
      `created_at` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '创建时间',
      `updated_at` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '更新时间'
) ENGINE=InnoDB AUTO_INCREMENT=10000043 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='测试表';
```

报错信息：
```
ERROR 1067 (42000): Invalid default value for 'deleted_at'
```

解决方案：

使用root登陆数据库

1、查看sql_mode：

```
select @@sql_mode;
```
获得结果：

```
ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
```
2、NO_ZERO_IN_DATE,NO_ZERO_DATE是无法默认为‘0000-00-00 00:00:00’的根源，去掉之后再次新建表就可以了

```
SET GLOBAL sql_mode='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
```
注： 
NO_ZERO_IN_DATE：在严格模式下，不允许日期和月份为零 
NO_ZERO_DATE：设置该值，mysql数据库不允许插入零日期，插入零日期会抛出错误而不是警告。




