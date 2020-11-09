## vim 技巧记录

### 批量替换：
vim 批量替换

XXX是需要替换的字符串,YYY是替换后的字符串。

只对当前行进行替换：

Example
1
:s/XXX/YYY/g
,如果需要进行全部替换：

Example
1
:%s/XXX/YYY/g
如果需要对指定部分进行替换,可以用V进入visual模式,再进行

Example
1
:s/XXX/YYY/g
或者可以指定行数对指定范围进行替换:

Example
1
:10,31s/XXX/YYY/g
若需要显示行号，在vim下

Example
1
:set nu
取消显示行号：

Example
1
:set nonu

	%s/\/Users\/rick\/local\/sphinx\/sphinx_github/\/service\/sphinx/g 
	
	vi/vim 中可以使用 ：s 命令来替换字符串§以前只会使用一种格式来全文替换，今天发现该命令有很多种写法（vi 真是强大啊飕还有很多需要学习），记录几种在此，方便以后查询
	
	：s/vivian/sky/ 替换当前行第一个 vivian 为 sky

	：s/vivian/sky/g 替换当前行所有 vivian 为 sky
	
	：n，$s/vivian/sky/ 替换第 n 行开始到最后一行中每一行的第一个 vivian 为 sky
	
	：n，$s/vivian/sky/g 替换第 n 行开始到最后一行中每一行所有 vivian 为 sky, n 为数字，若 n 为 .，表示从当前行开始到最后一行

	：%s/vivian/sky/（等同于 ：g/vivian/s//sky/） 替换每一行的第一个 vivian 为 sky

	：%s/vivian/sky/g（等同于 ：g/vivian/s//sky/g） 替换每一行中所有 vivian 为 sky

可以使用 # 作为分隔符，此时中间出现的 / 不会作为分隔符
	
	：s#vivian/#sky/# 替换当前行第一个 vivian/ 为 sky/

	：%s /oradata/apras/ /user01/apras1 （使用 来 替换 / ）： /oradata/apras/替换成/user01/apras1/

	：s/vivian/sky/ 替换当前
	
## Vim 使用 regex 將 "," 取代成換行
```
:%s/,/\r,/g
```


## 跨文件跳转到定义
```
:tag <varname>

或者 Ctrl+] （写到这里突然想到了Vim的帮助文档的tags就是这么跳转的）

甚至 Ctrl+鼠标左键

来跳转到定义了。具体做法如下：

按　Ctrl+t　从一个tag返回到原来的位置。或者　Ctrl+o ，用Vim本身的上一个位置返回（如果移动了很多次，需要按好多次才能返回到原来位置）。

首先系统需要安装ctags，这个通过软件源或者 ctags官方网站 都可以安装。

在工程目录下生成tags文件：

ctags -R # 遍历所有目录，默认输出文件是 tags
ctags -e -R # 同上，但是生成的TAGS是给Emacs用的
在 ~/.vimrc 中添加

set tags=./tags;/


Ctrl+] - go to definition
Ctrl+T - Jump back from the definition.
Ctrl+W Ctrl+] - Open the definition in a horizontal split

Add these lines in vimrc
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

Ctrl+\ - Open the definition in a new tab
Alt+] - Open the definition in a vertical split

After the tags are generated. You can use the following keys to tag into and tag out of functions:

Ctrl+Left MouseClick - Go to definition
Ctrl+Right MouseClick - Jump back from definition

 ctrl+]    - 找到光标所在位置的标签定义的地方
 ctrl+t    - 回到跳转之前的标签处

 <c-w> + ] - 分屏跳转到定义

 <c-w> + } - 预览窗口跳转到定义
 <c-w> + z - 关闭预览窗口
```

### 折叠
```
set foldmethod=indent "set default foldmethod
"zi 打开关闭折叠
"zv 查看此行
zm 关闭折叠
zM 关闭所有
zr 打开
zR 打开所有
zc 折叠当前行
zo 打开当前折叠
zd 删除折叠
zD 删除所有折叠

可用选项 'foldmethod' 来设定折叠方式：set fdm=*****。
有 6 种方法来选定折叠：
manual           手工定义折叠
indent             更多的缩进表示更高级别的折叠
expr                用表达式来定义折叠
syntax             用语法高亮来定义折叠
diff                  对没有更改的文本进行折叠
marker            对文中的标志折叠
注意，每一种折叠方式不兼容，如不能即用expr又用marker方式，我主要轮流使用indent和marker方式进行折叠。

使用时，用：set fdm=marker 命令来设置成marker折叠方式（fdm是foldmethod的缩写）。
要使每次打开vim时折叠都生效，则在.vimrc文件中添加设置，如添加：set fdm=syntax，就像添加其它的初始化设置一样。

选取了折叠方式后，我们就可以对某些代码实施我们需要的折叠了，由于我使用indent和marker稍微多一些，故以它们的使用为例：
如果使用了indent方式，vim会自动的对大括号的中间部分进行折叠，我们可以直接使用这些现成的折叠成果。
在可折叠处（大括号中间）：
zc      折叠
zC     对所在范围内所有嵌套的折叠点进行折叠
zo      展开折叠
zO     对所在范围内所有嵌套的折叠点展开
[z       到当前打开的折叠的开始处。
]z       到当前打开的折叠的末尾处。
zj       向下移动。到达下一个折叠的开始处。关闭的折叠也被计入。
zk      向上移动到前一折叠的结束处。关闭的折叠也被计入。

```