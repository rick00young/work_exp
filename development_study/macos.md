# Os常用知识

### 在MAC终端下打开Finder
```
open .

指定打开文件的程序: -a

open -a Safari http://www.baidu.com
调用TextEdit编辑文件: -e

open -e main.c
打开finder,并且以某个文件为焦点

open -R main.c

```

### Mac电脑如何截图

```
截取全屏：快捷键（Shift＋Command＋3）
直接按“Shift＋Command＋3“快捷键组合，即可截取电脑全屏，图片自动保存在桌面。


截图窗口：快捷键（Shift+Command+4，然后按空格键）
▲直接按“Shift＋Command＋4“快捷键组合，会出现十字架的坐标图标；
▲将此坐标图标移动到需要截取的窗口上，然后按空格键；
▲按空格键后，会出现一个照相机的图标，单击鼠标，图片会自动保存在桌面。

截取任意窗口：快捷键（Shift＋Command＋4）
▲直接按“Shift＋Command＋4“快捷键组合，出现十字架的坐标图标；
▲拖动坐标图标，选取任意区域后释放鼠标，图片会自动保存在桌面。

```


### 在Terminal中查看当前目录下所有文件（包含文件夹）大小：
```
du -hs *
或者：

du -shc *
第二个命令能在最后显示一个Total大小，即当前目录的总大小。
```

### mac 查看端口
```
lsof -i:8002

COMMAND   PID USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
node    15813 rick   13u  IPv6 0xd297ca3495b11661      0t0  TCP *:teradataordbms (LISTEN)
```

### Mac Command 切换桌面或应用

```
# 切到PyCharm
osascript -e 'tell application "PyCharm" to activate'
# 切到Terminal
osascript -e 'tell application "Terminal" to activate'
# 切到Chrome
osascript -e 'tell application "Chrome" to activate'
```

### Mac 截图:
1. Command + Shift + 4 鼠标框选区域 默认保存在桌面
2. Command + Shift + 3 截取整个屏幕 默认保存在桌面

### MAC OS Finder 中快速定位指定路径
```
Shift + Command + G: 调出一个如图所示的小面板，把你在操作步骤里看到的路径地址复制粘贴进去，然后就可以轻松的定位到想要的目录了

Shift + Command + A：定位到应用程序(Applications)

Shift + Command + C：定位的计算机(Computer)

Shift + Command + D：定位到桌面(Desktop)

Shift + Command + I： 定位到 iDisk

Shift + Command + K：定位到网络(Network)

Shift + Command + T：添加当前目录到 Dock 最喜爱部分

Shift + Command + U：定位到实用工具(Utilities)

```

### 查看端口
```
//前所有监听的端口以及对应的Command和PID
lsof -nP -iTCP -sTCP:LISTEN | grep python

//查看指定端口对应的Command和PID
lsof -nP -iTCP:4000 -sTCP:LISTEN

//输出占用该端口的 PID
lsof -nP -iTCP:4000 |grep LISTEN|awk '{print $2;}'
```

### osascript
```
osascript \
-e 'tell application "iTerm" to activate' \
-e 'tell application "System Events" to tell process "iTerm" to keystroke "t" using command down' \
-e 'tell application "System Events" to tell process "iTerm" to keystroke "ls"' \
-e 'tell application "System Events" to tell process "iTerm" to key code 52'


//此代码没有验证
activate application "iTerm"
tell application "System Events" to keystroke "t" using command down
tell application "iTerm" to tell session -1 of current terminal to write text "pwd"


//此代码没有验证
tell application "iTerm"
    activate
    select first terminal window

    # Create new tab
    tell current window
        create tab with default profile
    end tell

    # Split pane
    tell current session of current window
        split vertically with default profile
        split vertically with default profile
    end tell

    # Exec commands
    tell first session of current tab of current window
        write text "cd ~/Developer/master-node"
        write text "coffee"
    end tell
    tell second session of current tab of current window
        write text "gulp w"
    end tell
    tell third session of current tab of current window
    end tell
end tell

//利用mac 的 osascript 直接查看本地IPv4
osascript -e "IPv4 address of (system info)"
```