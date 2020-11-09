# awk 的环境变量

[参考整理](http://sebug.net/paper/books/awk/)

[awk命令](http://man.linuxde.net/awk)

```
变量        描述
$n          当前记录的第n个字段，字段间由FS分隔。
$0          完整的输入记录。
ARGC        命令行参数的数目。
ARGIND      命令行中当前文件的位置(从0开始算)。
ARGV        包含命令行参数的数组。
CONVFMT     数字转换格式(默认值为%.6g)
ENVIRON     环境变量关联数组。
ERRNO       最后一个系统错误的描述。
FIELDWIDTHS 字段宽度列表(用空格键分隔)。
FILENAME    当前文件名。
FNR         同NR，但相对于当前文件。
FS          字段分隔符(默认是任何空格)。
IGNORECASE  如果为真，则进行忽略大小写的匹配。
NF          当前记录中的字段数。
NR          当前记录数。
OFMT        数字的输出格式(默认值是%.6g)。
OFS         输出字段分隔符(默认值是一个空格)。
ORS         输出记录分隔符(默认值是一个换行符)。
RLENGTH     由match函数所匹配的字符串的长度。
RS          记录分隔符(默认是一个换行符)。
RSTART      由match函数所匹配的字符串的第一个位置。
SUBSEP      数组下标分隔符(默认值是\034)。
```

# awk 运算符

```
运算符                      描述
= += -= *= /= %= ^= **=     赋值
?:                          C 条件表达式
||                          逻辑或
&&                          逻辑与
~ ~!                        匹配正则表达式和不匹配正则表达式
< <= > >= != ==             关系运算符
空格                        连接
+ -                         加，减
* / &                       乘，除与求余
+ - !                       一元加，减和逻辑非
^ ***                       求幂
++ --                       增加或减少，作为前缀或后缀
$                           字段引用
in                          数组成员
```

# 命令选项

```
-F fs or --field-separator fs
    指定输入文件折分隔符，fs是一个字符串或者是一个正则表达式，如-F:。

-v var=value or --asign var=value
    赋值一个用户定义变量。
```

# 数组

awk 中的数组的下标可以是数字和字母，称为关联数组。

## 下标与关联数组

- 用变量作为数组下标。如：`$ awk {name[x++] = $2;} END{for (i = 0; i < NR; i++) print i, name[i]}' test`。数组 name 中的下标是一个自定义变量 x，awk 初始化 x 的值为 0，在每次使用后增加 1。第二个域的值被赋给 name 数组的各个元素。在 END 模块中，for 循环被用于循环整个数组，从下标为 0 的元素开始，打印那些存储在数组中的值。因为下标是关健字，所以它不一定从 0 开始，可以从任何值开始。
- special for 循环用于读取关联数组中的元素。格式如下：

```
{
    for (item in arrayname) {
        print arrayname[item];
    }
}
$ awk '/^tom/{name[NR] = $1;} END{for (i in name) {print name[i];} }' test
```

打印有值的数组元素。打印的顺序是随机的。

- 用字符串作为下标。如：count["test"]
- 用域值作为数组的下标。一种新的 for 循环方式，for (index_value in array) statement。如: `$ awk '{count[$1]++} END{for (name in count) print name, count[name]}' test`。该语句将打印 $1 中字符串出现的次数。它首先以第一个域作数组 count 的下标，第一个域变化，索引就变化。
- delete 函数用于删除数组元素。如：`$ awk '{line[x++] = $1} END{for (x in line) delete(line[x])}' test`。分配给数组 line 的是第一个域的值，所有记录处理完成后，special for 循环将删除每一个元素。

# 内置函数

## 字符串函数

### 总览

函数名 | 说明
------ | ---
gsub(r,s) |  在整个$0中用s替代r
gsub(r,s,t) | 在整个t中用s替代r
index(s,t) |  返回s中字符串t的第一位置
length(s) | 返回s长度
match(s,r) | 测试s是否包含匹配r的字符串
split(s,a,fs) |  在fs上将s分成序列a
sprint(fmt,exp) | 返回经fmt格式化后的exp
sub(r,s) |  用$0中最左边最长的子串代替s
substr(s,p) | 返回字符串s中从p开始的后缀部分
substr(s,p,n) | 返回字符串s中从p开始长度为n的后缀部分

### 详解

- sub 函数匹配记录中最大、最靠左边的子字符串的正则表达式，并用替换字符串替换这些字符串。如果没有指定目标字符串就默认使用整个记录。替换只发生在第一次匹配的时候。

格式:

```
sub (regular expression, substitution string);
sub (regular expression, substitution string, target string)
```

实例:

```
$ awk '{ sub(/test/, "mytest"); print }' testfile
$ awk '{ sub(/test/, "mytest", $1); print }' testfile
```

- gsub 函数作用如 sub，但它在整个文档中进行匹配。
- index 函数返回子字符串第一次被匹配的位置，偏移量从位置1开始。

格式:

```
index(string, substring);
```

实例:

```
$ awk '{ print index("test", "mytest") }' testfile
```

- length函数返回记录的字符数。

格式:

```
length( string );
length
```

实例:

```
$ awk '{ print length( "test" ) }' testfile
$ awk '{ print length }' testfile

第二个实例输出 testfile 文件中每条记录的字符数。
```

- substr 函数返回从位置1开始的子字符串，如果指定长度超过实际长度，就返回整个字符串。

格式:

```
substr( string, starting position );
substr( string, starting position, length of string );
```

实例:

```
$ awk '{ print substr( "hello world", 7, 11 ) }' testfile
```

- match 函数返回在字符串中正则表达式位置的索引，如果找不到指定的正则表达式则返回 0。match 函数会设置内建变量 RSTART 为字符串中子字符串的开始位置，RLENGTH 为到子字符串末尾的字符个数。substr 可利于这些变量来截取字符串。

格式:

```
match( string, regular expression );
```

实例:

```
$ awk '{start = match("this is a test", /[a-z]+$/); print start}' testfile
$ awk '{start = match("this is a test", /[a-z]+$/); print start, RSTART, RLENGTH}' testfile
```

- toupper 和 tolower 函数可用于字符串大小间的转换。

格式:

```
toupper( string );
tolower( string );
```

- split 函数可按给定的分隔符把字符串分割为一个数组。如果分隔符没提供，则按当前 FS 值进行分割

格式:

```
split( string, array, field separator );
split( string, array )
```

实例:

```
$ awk '{ split( "20:18:00", time, ":" ); print time[2] }' testfile
```

- 格式化输出. awk 提供了 printf() 和 sprintf()，等同于相应的 C 语言函数。printf() 会将格式化字符串打印到 stdout，而 sprintf() 则返回可以赋值给变量的格式化字符串。在 Linux 系统上，可以输入 "man 3 printf" 来查看 printf() 帮助页面。

格式:

```
sprintf(Format, Expr, Expr, . . . );
```

##  时间函数

- systime 函数返回从`1970年1月1日`开始到当前时间(不计闰年)的整秒数。

格式和实例:

```
systime();

$ echo "" | awk '{ now = systime(); print now }'
```

- strftime 函数使用 C 库中的 strftime 函数格式化时间。

格式:

```
strftime( [format specification][,timestamp] );
```

日期和时间格式说明符

格式  |  描述
----- | ----
%a | 星期几的缩写(Sun)
%A | 星期几的完整写法(Sunday)
%b | 月名的缩写(Oct)
%B | 月名的完整写法(October)
%c | 本地日期和时间
%d | 十进制日期
%D | 日期 08/20/99
%e | 日期，如果只有一位会补上一个空格
%H | 用十进制表示24小时格式的小时
%I | 用十进制表示12小时格式的小时
%j | 从1月1日起一年中的第几天
%m | 十进制表示的月份
%M | 十进制表示的分钟
%p | 12小时表示法(AM/PM)
%S | 十进制表示的秒
%U | 十进制表示的一年中的第几个星期(星期天作为一个星期的开始)
%w | 十进制表示的星期几(星期天是0)
%W | 十进制表示的一年中的第几个星期(星期一作为一个星期的开始)
%x | 重新设置本地日期(08/20/99)
%X | 重新设置本地时间(12：00：00)
%y | 两位数字表示的年(99)
%Y | 当前月份
%Z | 时区(PDT)
%% | 百分号(%)

## 数学函数

函数名称  |  返回值
--------- | ------
atan2(x,y) | y,x范围内的余切
cos(x) | 余弦函数
exp(x) | 求幂
int(x) | 取整，过程没有舍入
log(x) | 自然对数
rand() | 随机数
sin(x) | 正弦
sqrt(x) | 平方根
srand(x)  |  x是rand()函数的种子
rand() | 产生一个大于等于0而小于1的随机数

## 自定义函数

在awk中还可自定义函数，格式如下：

```
function name ( parameter, parameter, parameter, ... ) {
    statements
    return expression   # the return statement and expression are optional
}
```

## 调用 shell 命令 system 函数

格式:

```
system(cmd);
```

system() 的返回值是 cmd 的退出状态.如果要获得 cmd 的输出,就要和 `getline` 结合使用.

***getline 会增加 awk 编程复杂度,吃力不讨好,建议用别的可行方案代替,不到万不得已,别查 getline.***

*systime, strftime 在 gawk 下有效*



-----



### awk常用内置变量：

```
FS: field separator（输入字段分隔符），默认是空白字符
OFS:output field separator，输出字段分隔符
NF：Number of Field，当前记录的field个数
RS: Record separator（记录分隔符），默认是换行符
NR: The number of input records，awk命令所处理的记录数；如果有多个文件，这个数目会把处理的多个文件中行统一计数
FNR: 与NR不同的是，FNR用于记录正处理的行是当前这一文件中被总共处理的行数
```
### awk命令的使用格式：
```
awk [options] 'script' file1,file2,...
awk [options] 'PATTERN { action }' file1,file2,... 


根据指定的分隔符将读入的文本切片，默认分隔符为空格，引用第一段$1,引用第二段$2,...引用全部字段$0
```

用法示例：

```
[root@rs1 test]# awk '{print $1}' a.txt
[root@rs1 test]# df -hP | awk '{print $1}'
awk中字段分隔符的指定方式：
1、[root@rs1 ~]# awk -F : '{print $1}' /etc/passwd 指定以”：“为分隔符
2、[root@rs1 test]# awk -v FS=: '{print $NF}' /etc/passwd指定以”：“为分隔符 -v表示声明一个变量
3、[root@rs1 ~]# awk 'BEGIN{FS=":"}{print $1,$3}' /etc/passwd在命令执行之前为变量赋值
4、[root@rs1 test]# awk -v OFS=: '{print $1,$2}' a.txt OFS 指定输出字段分隔符

```
### 一、print子命令的用法
```
print的使用格式：
 print item1, item2, ...
要点：
1、各项目之间使用逗号隔开，而输出时则以空白字符分隔
2、输出的item可以为字符串或数值、当前记录的字段(如$1)、变量或awk的表达式；数值会先转换为字符串，而后再输出
3、print命令后面的item可以省略，此时其功能相当于print $0, 因此，如果想输出空白行，则需要使用print ""
用法示例：
# awk 'BEGIN { print "line one\nline two\nline three" }'
# awk -F: '{ print $1, $2 }' /etc/passwd
```
### 二、printf
```
printf命令的使用格式：
printf format, item1, item2, ...
要点：
1、其与print命令的最大不同是，printf需要指定format
2、format用于指定后面的每个item的输出格式
3、printf语句不会自动打印换行符，换行时在模式中指定\n

format格式的指示符都以%开头，后跟一个字符，如下：
%c: 显示字符的ASCII码；
%d, %i：十进制整数；
%e, %E：科学计数法显示数值；
%f: 显示浮点数；
%g, %G: 以科学计数法的格式或浮点数的格式显示数值；
%s: 显示字符串；
%u: 无符号整数；
%%: 显示%自身；
修饰符：
N（数字）: 显示宽度；
-: 左对齐；
+：显示数值符号；
```

用法示例：

```
# awk -F: '{printf "%-15s %i\n",$1,$3}' /etc/passwd
[root@rs1 test]# awk '{printf "%-10s%s\n",$1,$2}' a.txt
```
### 三、输出重定向
```
print items > output-file 保存到某文件中
print items >> output-file 追加到某文件中
print items | command 使用管道交给某些命令处理
特殊文件描述符：
/dev/stdin：标准输入
/dev/sdtout: 标准输出
/dev/stderr: 错误输出
/dev/fd/N: 某特定文件描述符，如/dev/stdin就相当于/dev/fd/0
```

用法示例：

```
# awk -F: '{printf "%-15s %i\n",$1,$3 > "/dev/stderr" }' /etc/passwd
```

awk中常见的模式类型：

```
1、Regexp: 正则表达式，格式为/regular expression/
2、expresssion：表达式，其值非0或为非空字符时满足条件，如：$1 ~ /foo/ 或 $1 == "magedu"，用运算符~(匹配)和~!(不匹配)
3、Ranges： 指定的匹配范围，格式为pat1,pat2  /bash/,/awk/从被/bash/匹配到的行开始到被/awk/匹配到的行结束
4、BEGIN/END：特殊模式，仅在awk命令执行前运行一次或结束前运行一次
5、Empty(空模式)：匹配任意输入行
```

用法示例：

```
[root@rs1 test]# awk 'BEGIN{print "a" "b"}'字符串操作符，将两个字符串直接连接
[root@rs1 test]# awk -F: '$1 ~ /^root/ {print $3,$4,$NF}' /etc/passwd 显示被模式匹配到的行的第三第四和最有一个字段
[root@rs1 test]# awk -F: '$1 !~ /^root/ {print $3,$4,$NF}' /etc/passwd不能被模式匹配
[root@rs1 test]# awk -F: '/bash/{print $0}' /etc/passwd
[root@rs1 test]# awk -F: '$3>=500{print $1,$3}' /etc/passwd
[root@rs1 ~]# awk -F: 'BEGIN{print "Username       UID"}{printf "%-15s%s\n",$1,$3}END{print "Over"}' /etc/passwd
```

### awk中的控制语句：

#### 1、if-else

```
语法：if (condition) {then-body} else {[ else-body ]}
例子：
awk -F: '{if ($1=="root") print $1, "Admin"; else print $1, "Common User"}' /etc/passwd
awk -F: '{if ($1=="root") printf "%-15s: %s\n", $1,"Admin"; else printf "%-15s: %s\n", $1, "Common User"}' /etc/passwd
awk -F: -v sum=0 '{if ($3>=500) sum++}END{print sum}' /etc/passwd
```
#### 2、while

```
语法： while (condition){statement1; statment2; ...}
[root@rs1 ~]# awk -F: '$1!~/root/{i=1;while (i<=4) {print $i;i++}}' /etc/passwd
[root@rs1 ~]# awk -F: '$1!~/root/{i=1;while (i<=NF) {print $i;i+=2}}' /etc/passwd只显示奇数字段
```
#### 3、do-while

```
语法： do {statement1, statement2, ...} while (condition)
```
 
#### 4、for

```
语法： for ( variable assignment; condition; iteration process) { statement1, statement2, ...}
for循环还可以用来遍历数组元素：
语法： for (i in array) {statement1, statement2, ...}
遍历数组中的每一个元素
for {A in ARRAY} {print ARRAY[A]}
 A中保存数组下标
[root@rs1 ~]# awk 'BEGIN{A["m"]="hello";A["n"]="world";for (B in A) print A[B]}' B中保留数组A的下标
[root@rs1 ~]# awk -F: '{for(i=1;i<=NF;i+=2) print $i}' /etc/passwd
[root@rs1 ~]# netstat -ant | awk '$1~/tcp/{S[$NF]++}END{for (A in S) print A,S[A]}'
[root@rs1 ~]# awk -F: '$NF!~/^$/{SHELL[$NF]++}END{for(A in SHELL) print A,SHELL[A]}' /etc/passwd
[root@rs1 httpd]# awk '{IP[$1]++}END{for (A in IP) print A,IP[A]}' access_log.1
```
#### 5、case

```
语法：switch (expression) { case VALUE or /REGEXP/: statement1, statement2,... default: statement1, ...}
```

#### 6、break 和 continue
常用于循环或case语句中

#### 7、next
提前结束对本行文本的处理，并接着处理下一行
 
#### awk中使用数组：

```
array[index-expression]
index-expression可以使用任意字符串；需要注意的是，如果某数据组元素事先不存在，那么在引用其时，awk会自动创建此元素并初始化为空串；因此，要判断某数据组中是否存在某元素，需要使用index in array的方式。
```

用法示例：

```
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
每出现一被/^tcp/模式匹配到的行，数组S[$NF]就加1，NF为当前匹配到的行的最后一个字段，此处用其值做为数组S的元素索引；
awk '{counts[$1]++}; END {for(url in counts) print counts[url], url}' /var/log/httpd/access_log
用法与上一个例子相同，用于统计某日志文件中IP地的访问量
```
 
#### awk的内置函数：

```
split(string, array [, fieldsep [, seps ] ])
功能：将string表示的字符串以fieldsep为分隔符进行分隔，并将分隔后的结果保存至array为名的数组中；

netstat -ant | awk '/:80/{split($5,clients,":");IP[clients[1]]++}END{for(i in IP){print IP[i],i}}' | sort -rn | head -50
```

```
length([string])
功能：返回string字符串中字符的个数；

substr(string, start [, length])
功能：取string字符串中的子串，从start开始，取length个；start从1开始计数；

system(command)
功能：执行系统command并将结果返回至awk命令
systime()
功能：取系统当前时间
```

echo '[0.987]' | awk 'BEGIN{large=0;small=0} {large++} END{print large}'