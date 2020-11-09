## macOs system commnd

> Mac OS X提供了Terminal，即“终端”程序作为命令行交互接口。命令行的工作方式确实给一些工作带来便利，比如一些系统的管理和监控，以及一些对配置文本的简单查看和处理等。很多用户可能有在Terminal使用一些基本命令的经历，如ls,rm,mkdir,rmdir,cp等等。本文介绍一些稍微进阶又不如ls普及的Terminal命令，主要用于系统的监控和管理。

在黑漆漆（或惨白）的终端程序里，你是否曾打错一行命令，然后按着退格键按到手指酸痛？或者还用左右箭头让那个闪烁的小光标来回地游走？命令行下控制光标的几个快捷键一定得掌握，绝对的易用方便。

光标控制

* Control-A: 将光标移动到行首

* Control-C: 将光标移动到行尾

* Control-U: 删除行内光标之前的所有字符

* Control-K: 删除行内光标之后的所有字符

监控相关

* top: 实时显示系统中各个进程的资源占用状况

* who: 显示账户信息

* uptime: 本次已开机的时间

* last: 查看上次用户登录后的相关日志

* df –h: 查看文件系统信息

* fdisk –l: 查看分区信息（单系统单盘的OS X用户就不用看了）

* du -sh *: 查看当前目录下各文件夹大小

* iostat: 查看CPU和磁盘 I/O 相关的统计信息

* lsof: 查看打开的所有文件

* lpq: 查看打印队列

* diskutil: 全功能的磁盘工具

* dmesg: 查看内核消息

* sysctl: 显示和设置内核参数

* ifconfig: 查看网卡配置

* bg/fg: 将作业放在后台/前台运行

* jobs: 查看当前作业

* kill -9 [pid]: 强行结束某个进程，其中[pid]是进程号

* uname –a: 显示操作系统信息

其他控制

* ctrl+c 中止任务

* ctrl+d 终止任务

* ctrl+z 后台运行任务

* j/f 命令行下的页面导航

就这么多。如果你对Mac OS X的底层UNIX以及苹果对它的改造较有兴趣，推荐一本入门书《A Practical Guide to UNIX for Mac OS X Users》
