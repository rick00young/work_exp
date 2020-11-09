# linux定时任务的设置 crontab 配置指南

****

##为当前用户创建cron服务

##1.  键入 crontab  -e 编辑crontab服务文件

例如 文件内容如下：

     */2 * * * * /bin/sh /home/admin/jiaoben/buy/deleteFile.sh 

     保存文件并并退出

     */2 * * * * /bin/sh /home/admin/jiaoben/buy/deleteFile.sh

     */2 * * * * 通过这段字段可以设定什么时候执行脚本

    /bin/sh /home/admin/jiaoben/buy/deleteFile.sh 这一字段可以设定你要执行的脚本，这里要注意一下bin/sh 是指运行  脚本的命令  后面一段时指脚本存放的路径

 

##2. 查看该用户下的crontab服务是否创建成功， 用 crontab  -l 命令  

 

##3. 启动crontab服务 

>一般启动服务用  /sbin/service crond start 若是根用户的cron服务可以用 sudo service crond start， 这里还是要注意  下 不同版本linux系统启动的服务的命令也不同 ，像我的虚拟机里只需用 sudo service cron restart 即可，若是在根用下直接键入service cron start就能启动服务

 

##4. 查看服务是否已经运行用 
ps -ax | grep cron 

##5. crontab命令

>cron服务提供crontab命令来设定cron服务的，以下是这个命令的一些参数与说明:

>crontab -u //设定某个用户的cron服务，一般root用户在执行这个命令的时候需要此参数  

	
	crontab -l //列出某个用户cron服务的详细内容

	crontab -r //删除没个用户的cron服务

	crontab -e //编辑某个用户的cron服务
　　
　　
>比如说root查看自己的cron设置:crontab -u root -l
>
>再例如，root想删除fred的cron设置:crontab -u fred -r

 在编辑cron服务时，编辑的内容有一些格式和约定，输入:crontab -u root -e 进入vi编辑模式，编辑的内容一定要符合下面的格式:*/1 * * * * ls >> /tmp/ls.txt
 
 任务调度的crond常驻命令
 crond 是linux用来定期执行程序的命令。当安装完成操作系统之后，默认便会启动此
       

  任务调度命令。crond命令每分锺会定期检查是否有要执行的工作，如果有要执行的工作便会自动执行该工作。

 

##6. crontab命令选项:

     -u指定一个用户

     -l列出某个用户的任务计划

     -r删除某个用户的任务

     -e编辑某个用户的任务

##7. cron文件语法:

      分     小时    日       月       星期     命令

      0-59   0-23   1-31   1-12     0-6     command     (取值范围,0表示周日一般一行对应一个任务)

     记住几个特殊符号的含义:

     “*”代表取值范围内的数字,
     “/”代表”每”,
     “-”代表从某个数字到某个数字,
     “,”分开几个离散的数字

##8. 任务调度设置文件的写法
    可用crontab -e命令来编辑,编辑的是/var/spool/cron下对应用户的cron文件,也可以直接修改/etc/crontab文件
    具体格式如下：
    Minute Hour Day Month Dayofweek   command
    分钟     小时   天     月       天每星期       命令
    每个字段代表的含义如下：
    Minute             每个小时的第几分钟执行该任务
    Hour               每天的第几个小时执行该任务
    Day                 每月的第几天执行该任务
    Month             每年的第几个月执行该任务
    DayOfWeek     每周的第几天执行该任务
    Command       指定要执行的程序
    在这些字段里，除了“Command”是每次都必须指定的字段以外，其它字段皆为可选

    字段，可视需要决定。对于不指定的字段，要用“*”来填补其位置。
    举例如下：
    5       *       *           *     *     ls 				   //指定每小时的第5分钟执行一次ls命令
    30     5       *           *     *     ls        				  //指定每天的 5:30 执行ls命令
    30     7       8         *     *     ls             //指定每月8号的7：30分执行ls命令
    30     5       8         6     *     ls             //指定每年的6月8日5：30执行ls命令
    30     6       *           *     0     ls             //指定每星期日的6:30执行ls命令[注：0表示星期天，1表示星期1，

    以此类推，也可以用英文来表示，sun表示星期天，mon表示星期一等。]

****	
  	30     3     10,20     *     *     ls     每月10号及20号的3：30执行ls命令[注：“，”用来连接多个不连续的时段]

   	25     8-11 *           *     *     ls       每天8-11点的第25分钟执行ls命令[注：“-”用来连接连续的时段]

   	*/15   *       *           *     *     ls         每15分钟执行一次ls命令 [即每个小时的第0 15 30 45 60分钟执行ls命令 ]

   	30   6     */10         *     *     ls       每个月中，每隔10天6:30执行一次ls命令[即每月的1、11、21、31日是的6：30执行一次ls 命令。 ]

   	每天7：50以root 身份执行/etc/cron.daily目录中的所有可执行文件

    50   7       *             *     *     root     run-parts     /etc/cron.daily   [ 注：run-parts参数表示，执行后面目录中的所有可执行文件。 ]

 

##9. 新增调度任务

   	新增调度任务可用两种方法：
   	1)、在命令行输入: crontab -e 然后添加相应的任务，wq存盘退出。
   	2)、直接编辑/etc/crontab 文件，即vi /etc/crontab，添加相应的任务。

##10. 查看调度任务
   	crontab -l //列出当前的所有调度任务
   	crontab -l -u jp   //列出用户jp的所有调度任务

##11. 删除任务调度工作
	crontab -r   //删除所有任务调度工作

##12. 任务调度执行结果的转向
	例1：每天5：30执行ls命令，并把结果输出到/jp/test文件中
	0 5 * * * ls >/jp/test 2>&1
	注：2>&1 表示执行结果及错误信息。
	编辑/etc/crontab 文件配置cron  

	cron服务每分钟不仅要读一次/var/spool/cron内的所有文件，还需要读一次 /etc/crontab,因此我们配置这个文件也能运用cron服务做一些事情。用crontab配置是针对某个用户的，而编辑/etc/crontab是针对系统的任务。此文件的文件格式是:  

	SHELL=/bin/bash  

	PATH=/sbin:/bin:/usr/sbin:/usr/bin 

	MAILTO=root //如果出现错误，或者有数据输出，数据作为邮件发给这个帐号  

	HOME=/ //使用者运行的路径,这里是根目录  
	# run-parts  

	01   *   *   *   *     root run-parts /etc/cron.hourly         //每小时执行

	/etc/cron.hourly内的脚本  

	02   4   *   *   *     root run-parts /etc/cron.daily           //每天执行/etc/cron.daily内的脚本  

	22   4   *   *   0     root run-parts /etc/cron.weekly       //每星期执行 /etc/cron.weekly内的脚本  

	42   4   1   *   *     root run-parts /etc/cron.monthly     //每月去执行/etc/cron.monthly内的脚本  

大家注意”run-parts”这个参数了，如果去掉这个参数的话，后面就可以写要运行的某个脚本名，而不是文件夹名了

	例如：

	1)在命令行输入: crontab -e 然后添加相应的任务，wq存盘退出。

	2)直接编辑/etc/crontab 文件，即vi /etc/crontab，添加相应的任务
	
	11 2 21 10 * rm -rf /mnt/fb  
	
##Example

```
#每小时执行一次
2 * * * *       cd /opt/www/sc_poppy/python/scripts/ && /usr/local/bin/python /opt/www/sc_poppy/python/scripts/user_quantity_channel.py hour >> /opt/www/sc_poppy/python/log/user_quantity_channel.log

#每天凌晨00:03执行一次
3 0 * * *       cd /opt/www/sc_poppy/python/scripts/ && /usr/local/bin/python /opt/www/sc_poppy/python/scripts/user_quantity_channel.py day >> /opt/www/sc_poppy/python/log/user_quantity_channel.log

#每天凌晨01:12执行一次
12 1 * * *      cd /opt/www/sc_poppy/python/scripts/ && /usr/local/bin/python /opt/www/sc_poppy/python/scripts/user_activity.script.py day >> /opt/www/sc_poppy/python/log/user_activity.log

#每天凌晨02:22执行一次
22 2 * * *      cd /opt/www/sc_poppy/python/scripts/ && /usr/local/bin/python /opt/www/sc_poppy/python/scripts/user_fate.script.py day >> /opt/www/sc_poppy/python/log/user_fate.log

#每周一凌晨00:20执行一次
20 0 * * 1      cd /opt/www/sc_poppy/python/scripts/ && /usr/local/bin/python /opt/www/sc_poppy/python/scripts/user_fate.script.py week >> /opt/www/sc_poppy/python/log/user_fate.log

#每五分钟执行一次
*/5 * * * *     cd /opt/www/sc_poppy/python/scripts && /opt/www/python_env/bin/python /opt/www/sc_poppy/python/scripts/user_market.script.py > //opt/www/sc_poppy/python/scripts/user_market.log
```