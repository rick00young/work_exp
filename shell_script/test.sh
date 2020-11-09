#!/usr/bin/env bash
# @describe:
# @author:   Jerry Yang(hy0kle@gmail.com)

#set -x

# vim:set ts=4 sw=4 et fdm=marker:

for arg in "$*"
do
    echo $arg
done

for arg in "$@"
do
    echo $arg
done
echo '-------------'
while getopts "a:bc" arg #选项后面的冒号表示该选项需要参数
do
    case $arg in
        a)
            echo "a's arg:$OPTARG" #参数存在$OPTARG中
            ;;
        b)
            echo "b"
            ;;
        c)
            echo "c"
            ;;
        ?)  #当有不认识的选项的时候arg为?
            echo "unkonw argument"
            exit 1
            ;;
    esac
done
