```
./pip install virtualenv
sudo apt-get install python-virtualenv
./virtualenv /Users/rick/work_space/python_2
./pip install pycrypto
./pip install pyDes
./pip install redis
./pip install hiredis
./pip install MySQL-python
./pip install elasticsearch
./pip install numpy
./pip install pandas
./pip install psycopg2
./pip install pyahocorasick ac 关键字匹配
```


```
Q: Error: pg_config executable not found.
A: for centOs: yum install postgresql-devel

Q: Error: You need to install postgresql-server-dev-X.Y for building a server-side extension or libpq-dev for building a client-side application.
A: sudo apt-get install libpq-dev
sudo apt-get install postgresql postgresql-contrib
```


print "%.2f" % a 

datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

```
yesterday = datetime.date.fromordinal(datetime.date.today().toordinal()-1)

time_from_str =  '%s 00:00:00' % yesterday.strftime("%Y-%m-%d")

time_from = int(time.mktime(time.strptime(time_from_str, "%Y-%m-%d %H:%M:%S")))

time_to_str = '%s 23:59:59' % yesterday.strftime("%Y-%m-%d")
	
time_to = int(time.mktime(time.strptime(time_to_str, "%Y-%m-%d %H:%M:%S")))

3.时间戳转换为指定格式日期:
	方法一:
		利用localtime()转换为时间数组,然后格式化为需要的格式,如
		timeStamp = 1381419600
		timeArray = time.localtime(timeStamp)
		otherStyleTime = time.strftime("%Y-%m-%d %H:%M:%S", timeArray)
		otherStyletime == "2013-10-10 23:40:00"

	方法二:
		import datetime
		timeStamp = 1381419600
		dateArray = datetime.datetime.utcfromtimestamp(timeStamp)
		otherStyleTime = dateArray.strftime("%Y-%m-%d %H:%M:%S")
		otherStyletime == "2013-10-10 23:40:00"
		注意：使用此方法时必须先设置好时区，否则有时差
```


python 字典（dict）的特点就是无序的，按照键（key）来提取相应值（value），如果我们需要字典按值排序的话，那可以用下面的方法来进行：

1 下面的是按照value的值从大到小的顺序来排序。

```
dic = {'a':31, 'bc':5, 'c':3, 'asd':4, 'aa':74, 'd':0}
dict= sorted(dic.iteritems(), key=lambda d:d[1], reverse = True)
print dict
```

输出的结果：

```
[('aa', 74), ('a', 31), ('bc', 5), ('asd', 4), ('c', 3), ('d', 0)]
```

下面我们分解下代码
print dic.iteritems() 得到[(键，值)]的列表。
然后用sorted方法，通过key这个参数，指定排序是按照value，也就是第一个元素d[1的值来排序。reverse = True表示是需要翻转的，默认是从小到大，翻转的话，那就是从大到小。

2 对字典按键（key）排序：

```
dic = {'a':31, 'bc':5, 'c':3, 'asd':4, 'aa':74, 'd':0}

dict= sorted(dic.iteritems(), key=lambda d:d[0]) d[0]

表示字典的键
print dict
```

### Three Ways to Read A Text File Line by Line in Python
1.One easy way to read a text file and parse each line is to use the python statement “readlines” on a file object. 

```
## Open the file with read only permit
f = open('myTextFile.txt', "r")

## use readlines to read all lines in the file
## The variable "lines" is a list containing all lines
lines = f.readlines()

## close the file after reading the lines.
f.close()

```

2.Read a Text File Line by Line Using While Statement in Python

```
## Open the file with read only permit
f = open('myTextFile.txt')
## Read the first line 
line = f.readline()

## If the file is not empty keep reading line one at a time
## till the file is empty
while line:
    print line
    line = f.readline()
f.close()
```

3.Read a Text File Line by Line Using an Iterator in Python

```
f = open('myfile.txt')
for line in iter(f):
    print line
f.close()
```


##IDE 使用技巧：
pycharm python 代码格式化： command + alt + l


### Add alternatives to '%matplotlib inline' in ipython

```
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


goog = pd.read_csv("/Users/rick/Downloads/goog.csv")
goog['Log_Ret'] = np.log(goog['Close'] / goog['Close'].shift(1))
goog['Volatility'] = pd.rolling_std(goog['Log_Ret'], window=252)*np.sqrt(252)

#for linux
%matplotlib inline goog[['Close', 'Volatility']].plot(subplots=True, color='blue', figsize=(8, 6))

#for mac
%matplotlib osx goog[['Close', 'Volatility']].plot(subplots=True, color='blue', figsize=(8, 6))


ts = pd.Series(np.random.randn(1000), index=pd.date_range('1/1/2000', periods=1000));
ts = ts.cumsum()
ts.plot()
```



### OS X 10.8.x, uWSGI 2.0.3 linking error

```
C_INCLUDE_PATH=/usr/local/include LIBRARY_PATH=/usr/local/lib pip install uwsgi


uwsgi --socket 0.0.0.0:8800 --protocol=http -w wsgi

uwsgi --http-socket :9090 --plugin python --wsgi-file app/index.py
```

### python uwsgi

```
/home/www/suiyue/python_3/bin/uwsgi uwsgi.ini

[uwsgi]
// 开启主线程
master = true

// 项目目录
base = /home/www/suiyue/sy_poppy

// 移动到项目目录 cd
chdir = %(base)

// 本地的ip和端口
#socket = 127.0.0.1:8001
socket = :5000

// Python 虚拟环境目录
home = /home/www/suiyue/python_3

// 程序启动文件
wsgi-file = manage.py

// 项目中引用 flask 实例的变量名
callable = app

// 处理器数
processes = 2

// 线程数
threads = 4

// 获取uwsgi统计信息的服务地址
stats = 127.0.0.1:9191

```

### 解决UnicodeEncodeError: 'ascii' codec can't encode characters in position 0-11

原因是python2.7在安装时，默认的编码是ascii，当程序中出现非ascii编码时，python的处理常常会报这样的错，不过在python3就不会有这样的问题。

临时解决方法：

```
代码中加入如下三行
import sys  
reload(sys)  
sys.setdefaultencoding('utf8')  
```

如果不想在每个文件中都加这三行，就在python的Lib\site-packages文件夹下新建一个sitecustomize.py
内容如下：

```
# encoding=utf8  
import sys  

reload(sys)  
sys.setdefaultencoding('utf8')  
```
这样的话，系统在python启动的时候，自行调用该文件，设置系统的默认编码

## brew install essestia
```
You can install these using
   pip install ipython matplotlib
   Or using the installation method you prefer.

<<<<<<< HEAD
   Python modules have been installed and Homebrew's site-packages is not
   in your Python sys.path, so you will not be able to import the modules
   this formula installed. If you plan to develop with these modules,
   please run:
     mkdir -p /Users/rick/Library/Python/2.7/lib/python/site-packages
       echo 'import site; site.addsitedir("/Users/rick/homebrew/lib/python2.7/site-packages")' >> /Users/rick/Library/Python/2.7/lib/python/site-packages/homebrew.pth
```
=======
## python install opencv error:
can't find *.so

```
ln -n */*s/cv.py path/python/lib/site-package/cv.py

ln -n */*s/cv2.so path/python/lib/site-package/cv.so

```
## python3.5/bz2.py ImportError: No module named '_bz2
```
yum install bzip2 bzip2-devel
```

## 使用国内镜像源来加速python pypi包的安装
export PIP_FIND_LINKS="http://mirror1.example.com http://mirror2.example.com"

export PIP_FIND_LINKS="https://pypi.douban.com/simple"

pip install xxx -i https://pypi.douban.com/simple

## ImportError: No module named _tkinter, please install the python-tk package

```
sudo apt-get install python-tk
```

## ImportError: dlopen(/Users/rick/homebrew/lib/python2.7/site-packages/essentia/_essentia.so, 2): Library not loaded: /private/tmp/essentia-20161214-27293-1yv8n2u/essentia-2.1_beta3/build/src/libessentia.dylib

```
ln -s /Users/rick/homebrew/lib/libessentia.dylib /private/tmp/essentia-20161214-27293-1yv8n2u/essentia-2.1_beta3/build/src/libessentia.dylib
```

## brew install cartr/qt4/qt

```
We agreed to the Qt opensource license for you.
If this is unacceptable you should uninstall.

Qt Designer no longer picks up changes to the QT_PLUGIN_PATH environment
variable as it was tweaked to search for plug-ins provided by formulae in
  /Users/rick/homebrew/lib/qt4/plugins

Phonon is not supported on macOS Sierra or with Xcode 8.

.app bundles were installed.
Run `brew linkapps qt` to symlink these to /Applications.
```


###
```
1.Shutdown the VM and quit VirtualBox
Open the Terminal app and use the following command to navigate to the VirtualBox app directory:
cd /Applications/VirtualBox.app/Contents/Resources/VirtualBoxVM.app/Contents/MacOS/

2.Now in the proper directory, you’re ready to run the resize command with the following syntax:
VBoxManage modifyhd --resize [new size in MB] [/path/to/vdi]

3.For example, let’s say there’s a Windows 10 VM VDI file located at /Users/Paul/Documents/VM/Windows10.vdi and we want it to grow from 15GB to 30GB, the syntax would be:
VBoxManage modifyhd --resize 30000 ~/Documents/VM/Windows10.vdi

4.If desired, verify the change has taken place with the showhdinfo command:
VBoxManage showhdinfo ~/path/to/vmdrive.vdi

Relaunch VirtualBox and boot your newly resized guest OS
```

### pythob %matplotlin inline
```
ipython qtconsole --matplotlib inline 
ipython console --matplotlib inline
ipython notebook --matplotlib inline
ipython qtconsole --matplotlib inline --ConsoleWidget.font_family="Anonymous Pro" --ConsoleWidget.font_size=9
```

### Centos install python 依懒
```
yum install bzip2-devel curses-devel dbm-devel gdbm-devel xz-devel sqlite sqlite-devel openssl openssl-devel tkinter tcl-devel tk-devel readline readline-devel zlib zlib-devel
```

### python list dir
```
file_dir = self.recommend_config['recommend_hot_model_dir']
        model_files = os.listdir(file_dir)
        if model_files:
            model_files.reverse()
        hot_list = []
        for kk in model_files:
            if not kk.startswith(RecommendConfig.WORKS_HOT_MODEL):
                continue

            with open('%s/%s' % (file_dir, kk)) as f:
                dict_reader = csv.DictReader(f)
                for row in dict_reader:
                    hot_list.append({
                        'works_id': row['works_id'] if 'works_id' in row else 0,
                        'rank': row['rank'] if 'rank' in row else 0,
                    })
            if len(hot_list) > 100:
                break
```

### merge list just like in php
```
['it'] + ['was'] + ['annoying']
```


### mac python opencv openssl
```
pip3 install opencv-python
pips install pyopenssl
```

### mac install opencv
```
brew install python
brew install python3
brew install opencv3 --with-contrib --with-python3
echo /Users/rick/homebrew/opt/opencv3/lib/python2.7/site-packages >> /Users/rick/homebrew/lib/python2.7/site-packages/opencv3.pth

echo /Users/rick/homebrew/opt/opencv3/lib/python3.6/site-packages >> /Users/rick/homebrew/lib/python3.6/site-packages/opencv3.pth

link cv2.so
test 
```


### NumPy入门详解
```
http://blog.topspeedsnail.com/archives/599
```

### python 匹配中英文
```
python 匹配中文和英文

在处理文本时经常会匹配中文名或者英文word，python中可以在utf-8编码下方便的进行处理。

中文unicode编码范围[\u4e00-\u9fa5]

英文字符编码范围[a-zA-Z]

此时匹配连续的中文或者英文就很方便了，例如：

>>> import re
>>> strings = u'中国china美国American'
>>> print strings
中国china美国American
>>> ch_pat = re.compile(ur'[\u4e00-\u9fa5]+')
>>> en_pat = re.compile('[a-zA-Z]+')
>>> ch_words = ch_pat.findall(strings)
>>> en_words = en_pat.findall(strings)
>>> print ch_words
[u'\u4e2d\u56fd', u'\u7f8e\u56fd']
>>> print en_words
[u'china', u'American']
 
```


### canda install dlib
```
conda create -n python35 python=3.5
To install this package with conda run:
conda install -c menpo dlib 
```

### conda install opencv3
```
To install this package with conda run:
conda install -c menpo opencv3 
remind: python version <= 3.5 for now
```


#### brew install dlib opencv
```
1. brew install openblas
2. brew install opencv
3. brew install boost
4. brew install boost-python --with-python3
3. install X11
   cd /user/local/opt
   ln -s /opt/X11 X11
4. git clone https://github.com/davisking/dlib.git
   cd dlib/examples
   mkdir build
   cd build
   cmake .. -DUSE_SSE4_INSTRUCTIONS=ON
   cmake --build . --config Release

   cd dlib
   python setup.py install
   不报错则说明安装成功
5. 测试试是否安装成功
  python
  import cv2
  import dib
```

```
1. for ... in ...
with open("file") as fh:
    for line in fh:
        print(line.strip())
2. while fh.readline():
with open("file") as fh:
    line = fh.readline()
    while line:
        print(line.strip())
        line = fh.readline()
最简洁优雅又高效的自然是第一种, 如果题主非要用readline(), 则可以使用第二种, while循环, 读到最后一行没有内容会退出循环, 中间有空行不要紧, 空行不等于结尾(\n != EOF)
```