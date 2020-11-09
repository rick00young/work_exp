## bashrc

```
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
#[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
#shopt -s checkwinsize

# set encode
export LANG=C
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

### alias ###
# svn
alias svn-st='svn st | grep ^M'
alias svn-log='svn log -v --limit 5'

# professional alias
os=$(uname)
if [[ "Darwin" == $os ]] || [[ "FreeBSD" == $os ]]
then
    alias ls='ls -G'
    alias myip="ifconfig | grep 'inet ' | awk '{print \$2}'"
else
    alias ls='ls --color'
    alias myip="ifconfig | grep 'inet ' | awk '{split(\$2, ip_cntr, \":\"); print ip_cntr[2];}'"
fi
alias ll='ls -l'
alias la='ls -Aalth'
alias l='ls -CF'
alias lt='ls -lth'
alias tf='tail -f'
alias grep='grep --color=always'
alias tree='tree -C'
alias cdiff='~/local/colordiff/colordiff.pl | less -R'
alias rscp='rsync -v -P -e ssh'
alias wget='wget -c'
#alias wget='curl -O'
alias sendmail='$HOME/local/sendEmail/sendEmail -f cli_mail@163.com -o message-content-type=auto -o message-charset=utf-8 -s smtp.163.com -xu cli_mail@163.com -xp Iwi11ct0'
alias mysql='mysql --auto-rehash'
alias ctagsp='ctags -R --langmap=PHP:.php.inc --php-types=c+f+d --exclude=.svn --exclude=svn --exclude=subversion --exclude=img  --exclude=swf --exclude=js --exclude=tpl --exclude=htdocs --exclude=html --exclude=sql --exclude=static --exclude=.git'
alias vi='vim'
# psql
alias psql='/Library/PostgreSQL/9.5/bin/psql'

# brew python3
alias bpy3='/Users/rick/local/Homebrew/Cellar/python3/3.6.0/bin/python3'
#brew python2
alias bpy2='/Users/rick/local/Homebrew/Cellar/python/2.7.13/bin/python'
#apy2
alias apy2='/Users/rick/local/anaconda2/bin/python'
#apy3
alias apy3='/Users/rick/local/anaconda3/bin/python'
#wpy3
alias wpy2='/Users/rick/work_space/python_2/bin/python'
#wpy2
alias wpy3='/Users/rick/work_space/python_3/bin/python'

#node_music_bi
alias sy_bi='psql -h 172.16.1.33 -U dev node_music_bi'
# alias for git
alias git-ci='git commit'
alias git-log='git log'
alias git-stat='git status'
alias git-diff='git diff'
alias git-co='git checkout'
alias git-pull='git pull'
alias git-push='git push'
alias git-clone='git clone'
alias git-gm="git status | grep modified"

# alias for gcc
alias gw='gcc -g -O2 -Wall -fno-strict-aliasing -Wno-deprecated-declarations -D_THREAD_SAFE'
alias gt='gcc -g -finline-functions -Wall -Winline -pipe'
alias gco='gcc -framework Foundation'

alias free='top -l 1 | head -n 10 | grep PhysMem'
#alias for php
alias php='/Users/rick/server/php/bin/php'
alias composer='/Users/rick/local/php_composer/composer'
#node
alias node='/Users/rick/local/node/node-v4.6.0-darwin-x64/bin/node'
alias npm='/Users/rick/local/node/node-v4.6.0-darwin-x64/bin/npm'
##alias cnpm="npm --registry=https://registry.npm.taobao.org \
#    --cache=$HOME/.npm/.cache/cnpm \
#    --disturl=https://npm.taobao.org/dist \
#    --userconfig=$HOME/.cnpmrc"



#nginx
alias nginx='/Users/rick/server/openresty/nginx/sbin/nginx'

#subl
alias subl='/Users/rick/local/sublime/subl'

#alias for python
#alias python='/Users/rick/work_space/python_2/bin/python'

#ssh root@123.57.209.237
alias agro='ssh root@123.57.209.237'

# cd ..
alias ..='cd ../'

#mvn
alias mvn='/Users/rick/local/apache-maven-3.5.0/bin/mvn'

#scrapy
#alias scrapy='/Users/rick/work_space/python/python2_venv/bin/scrapy'


#macdown
alias macdown='/Users/rick/Soft/MacDown.app/Contents/MacOS/MacDown'
#scrapy
alias scrapy='/Users/rick/local/anaconda3/bin/scrapy'


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# bash 升级到4.0后,安装 bash-completion,开启命令参数自动补全
if [ -f $HOME/local/bash/share/bash-completion/bash_completion ]; then
    . $HOME/local/bash/share/bash-completion/bash_completion
fi

# color man
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

PAGER='less -X -M'
export LESS=' -R '

export SVN_EDITOR=vim
export EDITOR=vim
HOMEBREW=/Users/rick/homebrew/bin
export PATH=$HOMEBREW:$HOME/local/bin:/usr/local/mysql/bin:$PATH

# 使用 HISTTIMEFORMAT 在历史中显示 TIMESTAMP
export HISTTIMEFORMAT='%F %T '

# 生成随机字符串
function _randpwd
{
    str=`date +%s | shasum | base64 | head -c 16`
    echo $str
}
alias randpwd=_randpwd

#$PYTHON_3: some function
function _memtop()
{
    num=$1
    if ((num > 0))
    then
        num=$num
    else
        num=30
    fi
    ps aux | sort -k4nr | head  -n $num
}
alias memtop=_memtop

# mac 不支持
function _straceall {
    strace $(pidof "${1}" | sed 's/\([0-9]*\)/-p \1/g')
}
alias straceall=_straceall

function _urlencode()
{
    argc=$#
    if ((argc > 0))
    then
        php $HOME/local/bin/url.php encode $*
    else
        echo "Need more arguments..."
    fi
}
alias urlencode=_urlencode

function _urldecode()
{
    argc=$#
    if ((argc > 0))
    then
        php $HOME/local/bin/url.php decode $*
    else
        echo "Need more arguments..."
    fi
}
alias urldecode=_urldecode

function _kgit()
{
    ps axu | grep git | grep -v grep | awk '{print $2}' | xargs kill -9
}
alias kgit=_kgit

## Parses out the branch name from .git/HEAD:
find_git_branch () {
    local dir=. head
    until [ "$dir" -ef / ]; do
        if [ -f "$dir/.git/HEAD" ]; then
            head=$(< "$dir/.git/HEAD")
            if [[ $head = ref:\ refs/heads/* ]]; then
                git_branch=" → ${head#*/*/}"
            elif [[ $head != '' ]]; then
                git_branch=" → (detached)"
            else
                git_branch=" → (unknow)"
            fi
            return
        fi
        dir="../$dir"
    done
    git_branch=''
}
PROMPT_COMMAND="find_git_branch; $PROMPT_COMMAND"

# Here is bash color codes you can use
  black=$'\[\e[1;30m\]'
    red=$'\[\e[1;31m\]'
  green=$'\[\e[1;32m\]'
 yellow=$'\[\e[1;33m\]'
   blue=$'\[\e[1;34m\]'
magenta=$'\[\e[1;35m\]'
   cyan=$'\[\e[1;36m\]'
  white=$'\[\e[1;37m\]'
 normal=$'\[\e[m\]'

# for gcc {
# 服务器端的覆盖技术,交叉编译时请将这些环境变量置空
LD_LIBRARY_PATH=$HOME/local/lib:/usr/local/lib:/usr/lib
export LD_LIBRARY_PATH

#PYTHON_3=/Users/rick/work_space/python_3/include
#PYTHON_2=/Users/rick/work_space/python_2/include

C_INCLUDE_PATH=$PYTHON_3:$HOME/local/include:/usr/local/include:/usr/include
export C_INCLUDE_PATH

LIBRARY_PATH=$HOME/local/lib:/usr/local/lib:/usr/lib
export LIBRARY_PATH

LD_RUN_PATH=$HOME/local/bin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin
export LD_RUN_PATH

# 在 mac 容易出问题，尤其在 jpeg/png 的多版本情况下
#DYLD_LIBRARY_PATH=$HOME/local/lib:/usr/local/mysql/lib
#export DYLD_LIBRARY_PATH

# 去掉一些旧的支持
#DYLD_FALLBACK_LIBRARY_PATH=/usr/lib
#export DYLD_FALLBACK_LIBRARY_PATH
# end for gcc }
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
[[ $PS1 && -f /usr/local/share/bash-completion/bash_completion.sh ]] && \
    source /usr/local/share/bash-completion/bash_completion.sh

prompt='\$'
if [ "root" = "$USER" ]
then
    prompt='#'
fi

PS1="${white}[${green}\u${red}@${cyan}\h${normal}:${magenta}\w${white}]$yellow\$git_branch$white$prompt $normal"

# 加入 git  自动补齐
if [[ -f "$HOME/profile/local/git-completion.bash" ]]; then
    source $HOME/profile/local/git-completion.bash
fi

# 设置文件系统掩码,某些系统初始化后掩码有问题,统一设置为合理值
umask 0022
#PYTHON_3=/Users/rick/work_space/python_3/bin
#PATH=$PYTHON_3:$PATH:/Users/rick/local/openssl_102/bin
export PATH
source ~/.git-completion.bash
#export PYTHONHOME=/Users/rick/local/python3
#export PYTHONPATH=$PYTHONHOME:$PYTHONHOME/lib/python3:$PYTHONHOME/lib:$PYTHONHOME/lib/python3/site-packages
#export PATH=$PATH:$PYTHONHOME:$PYTHONPATH
#export LIBRARY_PATH=/Library/PostgreSQL/9.5/lib:$LIBRARY_PATH
#export C_INCLUDE_PATH=/Library/PostgreSQL/9.5/include:$C_INCLUDE_PATH

#export PYTHONHOME=/Users/rick/work_space/python_2
#export PYTHONPATH=$PYTHONHOME:$PYTHONHOME/lib/python2.7:$PYTHONHOME/lib:$PYTHONHOME/lib/python2.7/site-packages
#export PATH=$PATH:$PYTHONHOME:$PYTHONPATH
#export LIBRARY_PATH=/Library/PostgreSQL/9.5/lib:$LIBRARY_PATH:/Users/rick/homebrew/lib


export DYLD_FALLBACK_LIBRARY_PATH=/Library/PostgreSQL/9.5/lib:$DYLD_LIBRARY_PATH
export FLASK_ENV='develop'


export DPYTHONDIR=/Users/rick/local/Homebrew/Cellar/python/2.7.13/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages



export HOMEBREW_GITHUB_API_TOKEN=61caf183d980a01e1253bdd88a2eaf08f3e29130



#login to server
alias search27='ssh work@172.16.1.27'
alias search28='ssh work@172.16.1.28'
alias search41='ssh work@172.16.1.41'
alias es29='ssh work@172.16.1.29'
alias splunk='ssh root@172.16.0.6'
alias test15='ssh root@172.18.1.15'



export PYSPARK_PYTHON=/Users/rick/local/anaconda3/bin/python
export PYSPARK_DRIVER_PYTHON=/Users/rick/local/anaconda3/bin/ipython
#export PYSPARK_DRIVER_PYTHON_OPTS="notebook --NotebookApp.open_browser=False --NotebookApp.ip='*' --NotebookApp.port=8880"
export PYSPARK_DRIVER_PYTHON_OPTS="notebook"
export SPARK_HOME='/Users/rick/local/spark/spark-2.0.0-bin-hadoop2.6'
# this is where you specify all the options you would normally add after bin/pyspark
#export PYSPARK_SUBMIT_ARGS='--master spark://127.0.0.1 --deploy-mode client'


alias syp='echo suiyueyule2016@pwd'

. /Users/rick/local/torch/install/bin/torch-activate

#mac 格式化时间
alias fdate='fdate() { date -r $1 "+%Y-%m-%d %H:%M:%S"; };fdate'

```