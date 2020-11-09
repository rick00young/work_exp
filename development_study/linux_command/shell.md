# shell
## 1.for
 
```
for i in $(ls); do echo $i $(ll $i'/list_city'|wc -l); done

1.列表for循环
for varible1 in {1..5}  
#for varible1 in 1 2 3 4 5  
do  
     echo "Hello, Welcome $varible1 times "  
done  


# 2为步长
sum=0  
for i in {1..100..2}  
do  
    let "sum+=i"  
done  
echo "sum=$sum"
或者
for i in $(seq 1 2 100)
do
	let "sum+=i" 
done  


for file in $( ls )  
#for file in *  
do  
   echo "file: $file"  
done  


echo "number of arguments is $#"  
echo "What you input is: "  
for argument in "$@"  
do  
    echo "$argument"  
done  

2.不带列表for循环
echo "number of arguments is $#"  
echo "What you input is: "  
for argument  
do  
    echo "$argument"  
done  

3.类C风格的for循环
for((integer = 1; integer <= 5; integer++))  
do  
    echo "$integer"  
done  

sum=0  
  
for(( i = 1; i <= 100; i = i + 2 ))  
do  
     let "sum += i"  
done  
echo "sum=$sum
```

## 2.while
```
1.计数器控制的while循环
sum=0  
i=1  
while(( i <= 100 ))  
do  
     let "sum+=i"  
     let "i += 2"     
done  
echo "sum=$sum"  

2.结束标记控制的while循环
echo "Please input the num(1-10) "  
read num  
while [[ "$num" != 4 ]]  
do   
   if [ "$num" -lt 4 ]  
   then  
        echo "Too small. Try again!"  
        read num  
   elif [ "$num" -gt 4 ]  
   then  
         echo "To high. Try again"   
         read num  
   else  
       exit 0  
    fi  
done   
echo "Congratulation, you are right! " 


echo "Please input the num "  
read num  
factorial=1  
while [ "$num" -gt 0 ]  
do  
    let "factorial= factorial*num"  
    let "num--"  
done  
echo "The factorial is $factorial" 

3.标志控制的while循环
echo "Please input the num "  
read num  
sum=0  
i=1  
signal=0  
while [[ "$signal" -ne 1 ]]  
do  
    if [ "$i" -eq "$num" ]  
    then   
       let "signal=1"  
       let "sum+=i"  
       echo "1+2+...+$num=$sum"  
    else  
       let "sum=sum+i"  
       let "i++"  
    fi  
done    

4.命令行控制的while循环

使用命令行来指定输出参数和参数个数，通常与shift结合使用，shift命令使位置变量下移一位（$2代替$1、$3代替$2，并使$#变量递减），当最后一个参数显示给用户，$#会等于0，$*也等于空。


echo "number of arguments is $#"  
echo "What you input is: "  
while [[ "$*" != "" ]]  
do  
    echo "$1"  
    shift  
done  
```

## 3.until循环
```
i=0  
  
until [[ "$i" -gt 5 ]]    #大于5  
do  
    let "square=i*i"  
    echo "$i * $i = $square"  
    let "i++"  
done  
```

## 4.循环嵌套
```
1.嵌套循环实现九九乘法表
for (( i = 1; i <=9; i++ ))  
do  
      
    for (( j=1; j <= i; j++ ))  
    do  
        let "temp = i * j"       
        echo -n "$i*$j=$temp  "  
     done   
       
     echo ""   #output newline  
done  

2.for循环嵌套实现*图案排列
for ((i=1; i <= 9; i++))  
do  
    j=9;  
    while ((j > i))  
    do  
        echo -n " "  
        let "j--"  
    done  
    k=1  
    while ((k <= i))  
    do  
        echo -n "*"  
        let "k++"  
    done  
    echo ""  
done  

```

## 5.循环控制符break和continue
若须退出循环可使用break循环控制符，若退出本次循环执行后继续循环可使用continue循环控制符。

```
1.break
在for、while和until循环中break可强行退出循环，break语句仅能退出当前的循环，如果是两层循环嵌套，则需要在外层循环中使用break

sum=0  
for (( i=1; i <= 100; i++))  
do   
    let "sum+=i"  
  
    if [ "$sum" -gt 1000 ]  
    then  
        echo "1+2+...+$i=$sum"  
        break  
    fi  
done  

2.continue
在for、while和until中用于让脚本跳过其后面的语句，执行下一次循环。continue用于显示100内能被7整除的数。

m=1  
for (( i=1; i < 100; i++ ))  
do  
    let "temp1=i%7"         #被7整除  
   
    if [ "$temp1" -ne 0 ]  
    then  
        continue  
    fi  
      
    echo -n "$i  "  
      
    let "temp2=m%7"          #7个数字换一行  
      
    if  [ "$temp2" -eq 0 ]  
    then  
        echo ""  
    fi  
      
    let "m++"  
done  
```
## 6.select结构
select结构从技术角度看不能算是循环结构，只是相似而已，它是bash的扩展结构用于交互式菜单显示，功能类似于case结构比case的交互性要好。

```
1.select带参数列表
echo "What is your favourite color? "  
select color in "red" "blue" "green" "white" "black"  
do   
    break  
done  
echo "You have selected $color"  

2.select不带参数列表
该结构通过命令行来传递参数列表，由用户自己设定参数列表。
echo "What is your favourite color? "  
  
select color  
do   
    break  
done  
  
echo "You have selected $color"  
```

## 7.Linux shell中单引号，双引号及不加引号的简单区别
```
单引号：

　　可以说是所见即所得：即将单引号内的内容原样输出，或者描述为单引号里面看见的是什么就会输出什么。

 

双引号：

　　把双引号内的内容输出出来；如果内容中有命令，变量等，会先把变量，命令解析出结果，然后在输出最终内容来。

　　双引号内命令或变量的写法为\`命令或变量\`或$（命令或变量）。

 

无引号：
把内容输出出来，可能不会讲含有空格的字符串视为一个整体输出，如果内容中有命令，变量等，会先把变量，命令解析结果，然后在输出最终内容来，如果字符串中带有空格等特殊字符，则不能完整的输出，需要改加双引号，一般连续的字符串，数字，路径等可以用，不过最好用双引号替代之
```
## 8.Shell中获取字符串长度的七种方法
1.利用${#str}来获取字符串的长度

```
str="ABCDEF"
echo ${#str}
```
2.利用awk的length方法

```
str="ABCDEF"
echo ${str} | awk '{print length($0)}'
```

> 1) 最好用{}来放置变量
> 2) 也可以用length($0)来统计文件中每行的长度
> 3) 利用awk的NF项来获取字符串长度

```
str="ABCDEF"
echo $str | awk -F "" '{print NF}'
``` 

4.利用wc的-L参数来获取字符串的长度

```
str="ABCDEF"
echo ${str} | wc -L

cat /etc/passwd | wc -L
```

5.利用wc的-l参数，结合echo -n参数

```
str="ABCDEF"
echo -n "ABCDEF" | wc -c

echo "ABCDEF" | wc -c
```
备注: 

1) -c参数: 统计字符的个数

2) -n参数: 去除"\n"换行符，不去除的话，默认带换行符，字符个数就成了7

6.利用expr的length方法

```
str="ABCDEF"
expr length ${str}
```

7.利用expr的$str : ".*"技巧

```

str="ABCDEF"
expr $str : ".*"
```

备注: .*代表任意字符，即用任意字符来匹配字符串，结果是匹配到6个，即字符串的长度为6

## 9.Linux 前后台进程切换


```
1. command  & 让进程在后台运行
2. jobs –l 查看后台运行的进程
3. fg %n 让后台运行的进程n到前台来
4. bg %n 让进程n到后台去;
5. kill %1

PS："n"为jobs查看到的进程编号。
```

## shell逻辑判断&&和-a区别

- | [] | [[]]
--- | --- | ---
数字测试 | -eq -ne -lt -le -gt -ge | 同[]
文件测试 | -r -l -w -x -f -d -s -nt -ot | 同[]
字符测试 | = != -n -z ===(同=), 不可以用<= >= | 同[]
逻辑测试 | -a -o ! | && || !
数据运算 | 不可以使用 | + - * / %
组合 用各自逻辑符号连接的数字(运算)测试,文件测试,字符测试

情况比较复杂的字符测试

字符测试 | [] | [[]]
--- | --- | ---
<>(首个单挑) | 比较结果异常,如: $ [ 44 > 45 ] 与 $ [ 45 > 44] 的返回值一样; $ [ ccca > ccccb ] 与$ [ ccccb > ccca ]的返回值一样 | 根据相应ASCII码比较(如果是多个字母或数字组合,则先比较首个,若相同接着比较下一个)
\> \< (首个单挑) | 根据相应的ASCII比较(如果是多个字母或数字组合,则先比较首个,若相同接着比较下一个) | 不可以使用


### linux find命令之exec简单概述
exec解释：

-exec 参数后面跟的是command命令，它的终止是以;为结束标志的，所以这句命令后面的分号是不可缺少的，考虑到各个系统中分号会有不同的意义，所以前面加反斜杠。

{} 花括号代表前面find查找出来的文件名。


exec选项后面跟随着所要执行的命令或脚本，然后是一对儿{ }，一个空格和一个\，最后是一个分号。为了使用exec选项，必须要同时使用print选项。如果验证一下find命令，会发现该命令只输出从当前路径起的相对路径及文件名。

```
ls -l命令放在find命令的-exec选项中 
find . -type f -exec ls -l {} \;


在目录中查找更改时间在n日以前的文件并删除它们 
find . -type f -mtime +14 -exec rm {} \; 


在目录中查找更改时间在n日以前的文件并删除它们，在删除之前先给出提示 
find . -name "*.log" -mtime +5 -ok rm {} \;


-exec中使用grep命令 
find /etc -name "passwd*" -exec grep "root" {} \;

查找文件移动到指定目录 
find . -name "*.log" -exec mv {} .. \;

用exec选项执行cp命令 
find . -name "*.log" -exec cp {} test3 \;
```


### expect
[http://www.cnblogs.com/lixigang/articles/4849527.html](http://www.cnblogs.com/lixigang/articles/4849527.html)

(http://www.cnblogs.com/lixigang/articles/4849527.html)[]
shell expect的简单用法

```
脚本代码如下： 
　　############################################## 
　　#!/usr/bin/expect 
　　set timeout 30 
　　spawn ssh -l username 192.168.1.1 
　　expect "password:" 
　　send "ispass/r" 
　　interact 
　　############################################## 
　　1. ［#!/usr/bin/expect］ 
　　这一行告诉操作系统脚本里的代码使用那一个shell来执行。这里的expect其实和linux下的bash、windows下的cmd是一类东西。 
　　注意：这一行需要在脚本的第一行。 
　　2. ［set timeout 30］ 
　　基本上认识英文的都知道这是设置超时时间的，现在你只要记住他的计时单位是：秒 
　　3. ［spawn ssh -l username 192.168.1.1］
　　spawn是进入expect环境后才可以执行的expect内部命令，如果没有装expect或者直接在默认的SHELL下执行是找不到spawn命令的。所以不要用 “which spawn“之类的命令去找spawn命令。好比windows里的dir就是一个内部命令，这个命令由shell自带，你无法找到一个dir.com 或 dir.exe 的可执行文件。
　　它主要的功能是给ssh运行进程加个壳，用来传递交互指令。 
　　4. ［expect "password:"］ 
　　这里的expect也是expect的一个内部命令，有点晕吧，expect的shell命令和内部命令是一样的，但不是一个功能，习惯就好了。这个命令的意思是判断上次输出结果里是否包含“password:”的字符串，如果有则立即返回，否则就等待一段时间后返回，这里等待时长就是前面设置的30秒
　　5. ［send "ispass/r"］ 
　　这里就是执行交互动作，与手工输入密码的动作等效。 
　　温馨提示： 命令字符串结尾别忘记加上“/r”，如果出现异常等待的状态可以核查一下。 
　　6. ［interact］ 
　　执行完成后保持交互状态，把控制权交给控制台，这个时候就可以手工操作了。如果没有这一句登录完成后会退出，而不是留在远程终端上。如果你只是登录过去执行 
　　
expect expect-scp.sh或者
./expect-scp.sh会有结果

---
下面是从网上查询的用法总结：

1. expect中的判断语句：     
if { condition } {
     # do your things
} elseif {
     # do your things
} else {
     # do your things
}
expect中没有小括号（）,所有的if/else, while, for的条件全部使用大括号{}, 并且{ 与左边要有空格，否则会报错。另，else 不能单独占一行，否则会报错。
2. 字符串比较
if { "$node" == "apple" } {
     puts "apple"
} elseif { "$node" == "other" } {
     puts "invalid name"
     exit 70
} else {
     puts "asd"
}
对比string，使用==表示相等, !=标示不相等。
3. switch 语句
switch $location {
    "apple" { puts "apple" }
    "banana" { puts "banana" }
    default {
        puts "other"
     }
}
记得左大括号{ 的左边要有空格，否则会报错
4. 读取用户输入
expect_user -re "(.*)\n"
send_user "$expect_out(1, string)\n"
expect_user -re 表示正则表达式匹配用户按下回车前输入的所有字符
expect_out(1, string) 表示第一个匹配的内容，即回车前所有字符
expect_out(buffer) 所有的buffer内容
5. break && continue
如c中一样，expect一样可以使用break && continue, 并且功能相同。注：只能用在循环中。


```

```
if 判断条件；then
    statement1
    statement2
    .......
fi

if 判断条件；then
    statement1
    statement2
    .....
    else
    statement3
    statement4
fi

二元比较操作符,比较变量或者比较数字.注意数字与字符串的区别. 
整数比较 
-eq       等于,如:if [ "$a" -eq "$b" ] 
-ne       不等于,如:if [ "$a" -ne "$b" ] 
-gt       大于,如:if [ "$a" -gt "$b" ] 
-ge       大于等于,如:if [ "$a" -ge "$b" ] 
-lt       小于,如:if [ "$a" -lt "$b" ] 
-le       小于等于,如:if [ "$a" -le "$b" ] 
<       小于(需要双括号),如:(("$a" &lt; "$b")) 
&lt;=       小于等于(需要双括号),如:(("$a" &lt;= "$b")) 
>       大于(需要双括号),如:(("$a" &gt; "$b")) 
&gt;=       大于等于(需要双括号),如:(("$a" &gt;= "$b")) 
小数据比较可使用AWK 
字符串比较 
=       等于,如:if [ "$a" = "$b" ] 
==       等于,如:if [ "$a" == "$b" ],与=等价 
注意:==的功能在[[]]和[]中的行为是不同的,如下: 
       1 [[ $a == z* ]]    # 如果$a以"z"开头(模式匹配)那么将为true 
       2 [[ $a == "z\*" ]] # 如果$a等于z*(字符匹配),那么结果为true 
       3 
       4 [ $a == z* ]      # File globbing 和word splitting将会发生 
       5 [ "$a" == "z*" ] # 如果$a等于z*(字符匹配),那么结果为true 
一点解释,关于File globbing是一种关于文件的速记法,比如"\*.c"就是,再如~也是. 
但是file globbing并不是严格的正则表达式,虽然绝大多数情况下结构比较像. 
!=       不等于,如:if [ "$a" != "$b" ] 
这个操作符将在[[]]结构中使用模式匹配. 
<       小于,在ASCII字母顺序下.如: 
       if [[ "$a" &lt; "$b" ]] 
       if [ "$a" \&lt; "$b" ] 
注意:在[]结构中"&lt;"需要被转义. 
>       大于,在ASCII字母顺序下.如: 
       if [[ "$a" &gt; "$b" ]] 
       if [ "$a" \&gt; "$b" ] 
注意:在[]结构中"&gt;"需要被转义. 
具体参考Example 26-11来查看这个操作符应用的例子. 
-z       字符串为"null".就是长度为0. 
-n       字符串不为"null" 
注意: 
使用-n在[]结构中测试必须要用""把变量引起来.使用一个未被""的字符串来使用! -z 
或者就是未用""引用的字符串本身,放到[]结构中。虽然一般情况下可 
以工作,但这是不安全的.习惯于使用""来测试字符串是一种好习惯.

条件测试的写法：

1、执行一个命令的结果
 if grep -q "rm" fs.sh;then 

2、传回一个命令执行结果的相反值
 if ！grep -q "rm" fs.sh;then 

3、使用复合命令（（算式））
 if ((a>b));then 

4、使用bash关键字 [[判断式]]
 if [[ str > xyz ]];then 

5、使用内置命令：test 判断式
 if test "str" \> "xyz";then 

6、使用内置命令：[判断式]  类似test
 if [ "str" \> "xyz" ];then 

7、使用-a -o进行逻辑组合
 [ -r filename -a -x filename ] 

8、命令&&命令
 if grep -q "rm" fn.sh && [ $a -lt 100 ];then 

9、命令||命令
 if grep -q "rm" fn.sh || [ $a -lt 100 ];then 


"#/bin/bash
"#Pragram:This pragram is calculation your grade
"#import an argument
read -p "Please input your grade:" x
declare -i x
"#jugemet $x value is none or not
if [ "$x" == "" ];then
    echo "You don't input your grade...."
    exit 5
fi
"#judgement the gread level
if [[ "$x" -ge "90" && "$x" -le "100" ]];then
    echo "Congratulation,Your grade is A."
elif [[ "$x" -ge "80" && "$x" -le "89" ]];then
    echo "Good,Your grade is B."
elif [[ "$x" -ge "70" && "$x" -le "79" ]];then
    echo "Ok.Your grade is C."
elif [[ "$x" -ge "60" && "$x" -le "69" ]];then
    echo "Yeah,Your grade is D."
elif [[ "$x" -lt "60" ]];then
    echo "Right,Your grade is F."
else
    echo "Unknow argument...."
fi
```
### mail
```
mailSend(){
    echo -e "Date: "`date +"%y-%m-%d %T"`"\n\nHost: "`hostname`"\n\nService :$SERVICE_NAME\n\nProblem: $1 is no data within an hour.Please check it" |mail -s "$SERVICE_NAME Warnning" lijianjun@doumi.com
}

mailSendAll(){
    echo -e "Date: "`date +"%y-%m-%d %T"`"\n\nHost: "`hostname`"\n\nService :$SERVICE_NAME\n\nProblem: $1 is no data within an hour.Please check it" |mail -s "$SERVICE_NAME Warnning" $2
}

mailSendRedis(){
    echo -e "Date: "`date +"%y-%m-%d %T"`"\n\nHost: "`hostname`"\n\nService :redis cluster\n\nProblem: No data can be found in redis.Please check it.\n($1)" |mail -s "Redis Query Warnning" $2
}

```

### 查看端口占用
```
netstat -lntp | grep 80
lsof -i tcp:80

//一次性的清除占用80端口的程序
lsof -i :80|grep -v "PID"|awk '{print "kill -9",$2}'|sh

/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT   写入修改
/etc/init.d/iptables save   保存修改
service iptables restart    重启防火墙，修改生效

//检查端口被哪个进程占用
netstat -lnp|grep 88
```

### 用shell脚本 计算两个数的加减乘除取余
```
read -p '请输入数：' a                  //输入
read -p '请输入数：' b
echo '$a+$b=' $(( a +  b ))            //输出
echo '$a-$b=' $(( a -  b ))
echo '$a*$b=' $(( a *  b ))
echo '$a/$b=' $(( a /  b ))
echo '$a%$b=' $(( a %  b ))
```

###  脚本-清除源码所有注释
```
#!/bin/sh
path=$(cd "$(dirname "$0")";pwd)
echo ${path}


# 删除 //注释
find ${path} \( -name "*.m" -o  -name "*.h" -o -name "*.mm" \) -print | xargs sed -ig 's/^[[:space:]]*\/\/.*//g'

# 删除 //注释
find ${path} \( -name "*.m" -o  -name "*.h" -o -name "*.mm" \) | xargs sed -ig 's/[[:space:]]\/\/.*//g'

# 删除不跨行 /* */
find ${path} \( -name "*.m" -o  -name "*.h" -o -name "*.mm" \) | xargs sed -ig 's/\/\*.*\*\///g'

# 删除跨行 /* */在行内
find ${path} \( -name "*.m" -o  -name "*.h" -o -name "*.mm" \) | xargs sed -ig '/\W\/\*/,/\*\//d'

# 删除跨行 /* */在行首
find ${path} \( -name "*.m" -o  -name "*.h" -o -name "*.mm" \) | xargs sed -ig '/^[[:space:]]*\/\*/,/\*\//d'

# 删除 #pragma
find ${path} \( -name "*.m" -o  -name "*.h" -o -name "*.mm" \) | xargs sed -ig '/#pragma/d'

# 删除 #warning
find ${path} \( -name "*.m" -o  -name "*.h" -o  -name "*.mmg"  \) | xargs sed -ig '/#warning/d'

# 删除备份文件
find ${path} \( -name "*.mg" -o  -name "*.hg" -o  -name "*.mmg" \) | xargs rm

del_com(){
    if [ -e "$1" ]; then
        echo "$1"
    else
        echo "$1" " is not exist!"
        exit 1
    fi
    #cat test.scala | sed 's/^[[:space:]]*\/\/.*//g' | sed 's/[[:space:]]\/\/.*//g' | sed '/^$/d'
    cat $1 | sed 's/^[[:space:]]*\/\/.*//g' | \
    sed 's/[[:space:]]\/\/.*//g' |  \
    sed 's/\/\*.*\*\///g' | \
    sed '/\W\/\*/,/\*\//d' | \
    sed '/^$/d' | \
    sed '/^[[:space:]]*\/\*/,/\*\//d' > "$2"
}
```