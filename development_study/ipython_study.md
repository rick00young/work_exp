## ipython study

### 魔术方法

一、基础使用

* 1.魔力函数（built-in）[以前我并不知道这是什么东西,也就是ipython的内置的一些方法]
   IPython 会将任何第一个字母为%的行，视为对魔力函数的特殊调用。这样你就可以控制ipython，为其增加许多系统级的特征。魔力函数都是以%为前缀，并且参数中不包含括号或者引号。

查看可用的magic

```  
In [46]: %lsmagic
Out[46]: 
Available line magics:
%alias  %alias_magic  %autocall  %autoindent  %automagic  %bookmark  %cat  %cd  %clear  %colors  %config  %cp  %cpaste  %debug  %dhist  %dirs  %doctest_mode  %ed  %edit  %env  %gui  %hist  %history  %install_default_config  %install_ext  %install_profiles  %killbgscripts  %ldir  %less  %lf  %lk  %ll  %load  %load_ext  %loadpy  %logoff  %logon  %logstart  %logstate  %logstop  %ls  %lsmagic  %lx  %macro  %magic  %man  %matplotlib  %mkdir  %more  %mv  %notebook  %page  %paste  %pastebin  %pdb  %pdef  %pdoc  %pfile  %pinfo  %pinfo2  %popd  %pprint  %precision  %profile  %prun  %psearch  %psource  %pushd  %pwd  %pycat  %pylab  %quickref  %recall  %rehashx  %reload_ext  %rep  %rerun  %reset  %reset_selective  %rm  %rmdir  %run  %save  %sc  %set_env  %store  %sx  %system  %tb  %time  %timeit  %unalias  %unload_ext  %who  %who_ls  %whos  %xdel  %xmode
  
Available cell magics:
%%!  %%HTML  %%SVG  %%bash  %%capture  %%debug  %%file  %%html  %%javascript  %%latex  %%perl  %%prun  %%pypy  %%python  %%python2  %%python3  %%ruby  %%script  %%sh  %%svg  %%sx  %%system  %%time  %%timeit  %%writefile
  
Automagic is ON, % prefix IS NOT needed for line magics.
```	
	
魔力【魔术】函数 ，它们分为两类%%与%，比如%time,%%time,%表示专门针对一行的命令，%%表示针对多行的命令
值的一说的是：%quickref 它就是ipython中魔术函数的手册，它己经为你总结出每一个 magic func 的用法

*  2.?与??
    ?：修饰魔术方法获取更详细的信息。但是不只是这样，?其实是可以修饰python所有的对象。考虑到python中一切都是对象，所以你懂的
   ??：可以用于查看变量，类、包、类中方法、内置函数的源码。

* 3.！xxx
ipython提供了一个额外的!语法去直接执行linux命令;
使用$可以将变量传递到shell命令中；
！！可以替换！，除了使用！！无法保存结果到变量之外，两者完全相同.


```
In [50]: user='sysadmin'
  
In [51]: process='bash'
  
In [52]: l=!ps aux |grep $user |grep $process
  
In [53]: l
Out[53]: 
['root     18119  0.0  0.0 106096  1144 pts/8    S+   14:00   0:00 /bin/sh -c ps aux |grep sysadmin |grep bash',
 'sysadmin 24270  0.0  0.0 108340  1848 pts/0    Ss   09:36   0:00 -bash',
 'sysadmin 27048  0.0  0.0 108476  1860 pts/7    Ss   10:06   0:00 -bash']
 
```

* 4.%run
   有了它之后，就可以不用退出ipython而运行*.py;
   
   常用的选项:
     -t:打印出cpu timings
     -N#:表示重复次数
     -p:这个选项会开启python profiler，从而打印出详细的执行时间、函数调用等等信息供优化参考。
     -d:会进入单步调试模式（ipdb），可以看到程序内部执行流程 
     
```
In [108]: %run -tp temp.py
Space used in /tmp directory
8.0K    /tmp/ipython_edit_MrCrjh
4.0K    /tmp/.ICE-unix
8.0K    /tmp/ipython_edit_k8BYnO
...
82 function calls in 0.027 seconds
 
Ordered by: internal time
 
   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
        1    0.010    0.010    0.010    0.010 {posix.fork}
        1    0.007    0.007    0.007    0.007 {posix.read}
        1    0.005    0.005    0.005    0.005 {posix.waitpid}
        1    0.001    0.001    0.019    0.019 subprocess.py:1111(_execute_child)
        1    0.001    0.001    0.026    0.026 {execfile}
        1    0.000    0.000    0.027    0.027 interactiveshell.py:2616(safe_execfile)
        4    0.000    0.000    0.000    0.000 {fcntl.fcntl}
        1    0.000    0.000    0.025    0.025 subprocess.py:485(call)
```
 
 * 5.alias
   能够衔接python与UNIX shell功能的第一个特征就是alias魔术函数

```
In [24]: alias nss netstat -talp
  
In [25]: nss |grep http
tcp        0      0 *:http                      *:*                         LISTEN      22902/nginx
```

当然了，这都是常用的功能，还有另一种功能“格式化替换”

```
In [42]: alias nss netstat %l |grep :6011
  
In [43]: nss -talp
tcp        0      0 localhost:6011              *:*                         LISTEN      27047/sshd          
tcp        0      0 localhost:6011              *:*                         LISTEN      27047/sshd
```

这是的%l（字母l）该方法用于将行的其它部分插入到alias中,还可以通过命令字任串插入不同的参数，用%s表示字符串

```
In [44]: alias aecho echo firt "#%s#",second "#%s#"
  
In [45]: 
  
In [45]: aecho JACK pam
firt #JACK#,second #pam#
```

 如果输入的参数少于需要的参数则会报错，但多余需要的参数则不会【23333..】
 
 * 6.%store
   可以使用他保留所使用的别名，下次打开ipython就可以直接使用了

```
In [46]: %store nss
Alias stored: nss (netstat %l |grep :6011)
```
    注：这需要SQLite的支持，否则打开新的会话将无法使用别名 
    
二、进阶用法
   * 1.字符串处理
      ipython 另一个强大的功能是采用字符串方式处理系统 shell命令执行结果
      
```
In [8]: ps =!ps -aux 
  
In [9]: ps.
ps.append     ps.fields     ps.get_paths  ps.index      ps.list       ps.p          ps.remove     ps.sort
ps.count      ps.get_list   ps.get_spstr  ps.insert     ps.n          ps.paths      ps.reverse    ps.spstr
ps.extend     ps.get_nlstr  ps.grep       ps.l          ps.nlstr      ps.pop        ps.s          
  
In [9]: ps.grep('ssh')
Out[9]: 
['root      6854  0.0  0.0  66140   240 ?        Ss   Oct09   0:00 /usr/sbin/sshd',
 'root     21334  0.0  0.0 100348     8 ?        Ss   14:49   0:00 sshd: sysadmin [priv]',
 'sysadmin 21336  0.0  0.0 100496   356 ?        S    14:49   0:01 sshd: sysadmin@pts/3',
 'root     29347  0.0  0.2 100352  4304 ?        Ss   16:49   0:00 sshd: sysadmin [priv]',
 'sysadmin 29351  0.0  0.1 100760  2280 ?        S    16:49   0:00 sshd: sysadmin@pts/0',
 'root     30684  0.0  0.2 100352  4280 ?        Ss   17:08   0:00 sshd: sysadmin [priv]',
 'sysadmin 30739  0.0  0.0 100352  1884 ?        S    17:08   0:00 sshd: sysadmin@pts/4']
```
这里面除了有列表的属性还有一些其它附加的属性

```
In [20]: ps.grep('sshd')
Out[20]: 
['root      1033  0.0  0.0  66144  1180 ?        Ss   18:13   0:00 /usr/sbin/sshd',
 'root      1157  0.0  0.0 100352  4304 ?        Ss   18:13   0:00 sshd: sysadmin [priv]',
 'sysadmin  1159  0.0  0.0 100496  2024 ?        S    18:13   0:00 sshd: sysadmin@pts/0',
 'root      1348  0.0  0.0 100352  4312 ?        Ss   18:16   0:00 sshd: sysadmin [priv]',
 'sysadmin  1350  0.0  0.0 100352  1888 ?        S    18:16   0:00 sshd: sysadmin@pts/1']
  
In [21]: ps.grep('sshd').fields(0,1,8)
Out[21]: 
['root 1033 18:13',
 'root 1157 18:13',
 'sysadmin 1159 18:13',
 'root 1348 18:16',
 'sysadmin 1350 18:16']
```
还可以这样

```
ps.grep('ssh').fields(1).s
Out[29]: '1033 1157 1159 1348 1350'
```

 2、信息收集
 
```
  a、pdef、pdoc、pfile、pinfo、psoure、psearch函数
    pdef:打印出可调用的对象的定义名或是函数声明

In [40]: def tmp_space():
   ....:         '''return somting directory used info'''
   ....:         tmp_usage = 'du'
   ....:         tmp_arg = '-h'
   ....:         path = '/tmp'
   ....:         print "Space used in /tmp directory"
   ....:         subprocess.call([tmp_usage,tmp_arg,path])
   ....:     
  
In [41]: pdef tmp_space
 tmp_space()
```

pdoc:输出注释信息与使用示例

```
In [42]: pdoc tmp_space
Class docstring:
    return somting directory used info
Call docstring:
    x.__call__(...) <==> x(...)  
In [43]:
```

pfile:了解代码如何运行的 【module??】的功能是一样的

```

In [46]: import commands
  
In [47]: pfile commands
  
In [48]: commands??
```

pinfo:获取类型、类、命令空间和注释等信息

```
In [1]: import commands
  
In [2]: pinfo
%pinfo   %pinfo2  
  
In [2]: pinfo commands
  
In [3]: pinfo commands
  
Type:        module
String form: <module 'commands' from '/usr/local/python27/lib/python2.7/commands.pyc'>
File:        /usr/local/python27/lib/python2.7/commands.py
Docstring:
Execute shell commands via os.popen() and return status, output.
  
Interface summary:
  
import commands
  
outtext = commands.getoutput(cmd)
       (exitstatus, outtext) = commands.getstatusoutput(cmd)
       outtext = commands.getstatus(file)  # returns output of "ls -ld file"
  
A trailing newline is removed from the output string.
  
Encapsulates the basic operation:
  
      pipe = os.popen('{ ' + cmd + '; } 2>&1', 'r')
      text = pipe.read()
      sts = pipe.close()
  
 [Note:  it would be nice to add functions to interpret the exit status.]
(END)
```

psource:通过运行page显示源代码

```   
In [1]: %cd /tmp
/tmp
  
In [2]: import temp
  
In [3]: psource temp
  
In [4]: psource temp
```
 
``` 
#!/usr/bin/env python
   
import subprocess
  
def tmp_space():
    '''return somting directory used info'''
    tmp_usage = 'du'
    tmp_arg = '-h'
    path = '/tmp'
    print "Space used in /tmp directory"
:
In [5]: psource temp.
temp.main        temp.py          temp.pyc         temp.subprocess  temp.tmp_space   
 
In [5]: psource temp.tmp_space
def tmp_space():
    '''return somting directory used info'''
    tmp_usage = 'du'
    tmp_arg = '-h'
    path = '/tmp'
    print "Space used in /tmp directory"
    subprocess.call([tmp_usage,tmp_arg,path])
```

psearch: 根据名称查找python对象

```
In [6]: psearch a*
abs
all
any
apply
In [9]: import os 
  
In [10]: os.li*? #psearch os.li*
os.linesep
os.link
os.listdir

```

  常用的选项有：
    -s: 指定范围【范围空间有builtin,user,user_global,internal和alias】
    -e:排除搜索范围

```
In [17]: %psearch -e builtin a*
  
  
In [18]: a='abc'
  
In [19]: %psearch -e builtin a*
a
  
In [24]: psearch -e builtin * int
  
  
In [25]: psearch -e builtin * string
__
___
__doc__
__name__
a
  
In [26]: __
Out[26]: ''
  
In [27]: ___
Out[27]: ''
  
In [28]: __doc__
Out[28]: 'Automatically created module for IPython interactive environment'
  
In [29]: a
Out[29]: 'abc'
```

b、who函数：列出所有交互定义的对象

```
In [30]: who
a    os     temp   
  
In [31]: !who
sysadmin pts/3        2015-11-12 20:26 (219.235.192.74)
sysadmin pts/4        2015-11-12 20:26 (219.235.192.74)
In [32]: who str
a  
In [35]: who module
os   temp 
In [36]: whos
Variable   Type      Data/Info
------------------------------
a          str       abc
os         module    <module 'os' from '/usr/l<...>27/lib/python2.7/os.pyc'>
temp       module    <module 'temp' from 'temp.py'>
 
In [37]: who_ls
Out[37]: ['a', 'os', 'temp']
```

c、rep 函数：
   它是一个自动启用函数，rep 函数有一些你或觉得有用的参数[对于我来说]；不使用还参数的rep可以取回最近处理的结果，并在一行输出时设置一个字符串表示

```
In [92]: a=!which ls
  
In [93]: a[0]
Out[93]: '/bin/ls'
  
In [94]: rep
  
In [95]: /bin/ls
  
In [95]: x=!/bin/ls
  
In [96]: x
Out[96]: 
['151111.sql',
 '151111.tar.gz',
 '22_40.SQL',
 'agent2610.log',
 'crm.log',
 'ip.log',
 'ipython_edit_k8BYnO',
 'ipython_edit_MrCrjh',
 'ipython_edit_RLhXgZ',
 'ipython_edit_z87hKG',
 'pdb-bin.460',
 'pic',
 'temp.py',
 'temp.pyc',
 'user.log']
  
In [97]:
```