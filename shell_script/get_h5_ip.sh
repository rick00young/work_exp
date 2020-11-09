#!/bin/sh


logs_path='/Users/rick/work_space/sy_data/h5log/test_dir/'
awk_script='/Users/rick/work_space/sy_data/h5log/h5log_demo.awk'
for i in `ls $logs_path`
    do
        file_path=${logs_path}${i}
        echo $file_path
        awk -f $awk_script $file_path
    done
