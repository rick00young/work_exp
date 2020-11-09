# Compress
```
.tar 
　　解包：tar xvf FileName.tar 
　　打包：tar cvf FileName.tar DirName 
　　（注：tar是打包，不是压缩！） 
　　——————————————— 
　　.gz 
　　解压 1：gunzip FileName.gz 
　　解压2：gzip -d FileName.gz 
　　压缩：gzip FileName 
　　.tar.gz 和 .tgz 
　　解压：tar zxvf FileName.tar.gz 
　　压缩：tar zcvf FileName.tar.gz DirName 
　　——————————————— 
　　.bz2 
　　解压1：bzip2 -d FileName.bz2 
　　解压2：bunzip2 FileName.bz2 
　　压缩： bzip2 -z FileName 
　　.tar.bz2 
　　解压：tar jxvf FileName.tar.bz2        或tar --bzip xvf FileName.tar.bz2 
　　压缩：tar jcvf FileName.tar.bz2 DirName 
　　 ——————————————— 
　　.bz 
　　解压1：bzip2 -d FileName.bz 
　　解压2：bunzip2 FileName.bz 
　　压缩：未知 
　　.tar.bz 
　　解压：tar jxvf FileName.tar.bz 
　　压缩：未知 
　　——————————————— 
　　.Z 
　　解压：uncompress FileName.Z 
　　压缩：compress FileName 
　　.tar.Z 
　　解压：tar Zxvf FileName.tar.Z 
　　压缩：tar Zcvf FileName.tar.Z DirName 
　　——————————————— 
　　.zip 
　　解压：unzip FileName.zip 
　　压缩：zip FileName.zip DirName 
　　压缩一个目录使用 -r 参数，-r 递归。例： $ zip -r FileName.zip DirName 
　　——————————————— 
　　.rar 
　　解压：rar x FileName.rar 
　　压缩：rar a FileName.rar DirName 
　　 
　　rar 请到：http://www.rarsoft.com/download.htm 下载！ 
　　解压后请将rar_static拷贝到/usr /bin目录（其他由$PATH环境变量指定的目录也可以）： 
　　[root@www2 tmp]# cp rar_static /usr/bin/rar 
　　——————————————— 
　　.lha 
　　解压：lha -e FileName.lha 
　　压缩：lha -a FileName.lha FileName 
　　 
　　lha请到：http://www.infor.kanazawa-it.ac.jp/~ishii/lhaunix/下载！ 
　　>解压后请将 lha拷贝到/usr/bin目录（其他由$PATH环境变量指定的目录也可以）： 
　　[root@www2 tmp]# cp lha /usr/bin/ 
　　——————————————— 
　　.rpm 
　　解包：rpm2cpio FileName.rpm | cpio -div 
　　——————————————— 
　　.deb 
　　解包：ar p FileName.deb data.tar.gz | tar zxf - 
　　——————————————— 
　　.tar .tgz .tar.gz .tar.Z .tar.bz .tar.bz2 .zip .cpio .rpm .deb .slp .arj .rar .ace .lha .lzh .lzx .lzs .arc .sda .sfx .lnx .zoo .cab .kar .cpt .pit .sit .sea 
　　解压：sEx x FileName.* 
　　压缩：sEx a FileName.* FileName 
```