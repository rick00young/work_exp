#! /bin/sh -  
  
name=`basename $0 .sh` 

if [ x$1 != x ]
	then
    echo 'start...'
else
    echo "Usage: $name [reset_config|restart_log|start_log|stop_log|clean_log_db]"  
    exit 1  
fi


func_reset_config(){
        echo '-----reset_config  start------'
        for host in `cat $1`;do
                echo $host;
                #rm config
                ssh root@$host "cd /service/elk/logstash-1.5.3/conf; rm -rf *"
                #logstash conf
                rsync -azv $op_dir_from --exclude-from=$exclude_file $host:$op_dir/
                #ssh root@$host "ps axu |grep java|grep 'logstash-1.5.3' | grep -v 'grep' | awk '{print \$2}' | xargs kill"
                #ssh root@$host "source /etc/profile ; /service/elk/logstash-1.5.3/bin/logstash -f /service/elk/logstash-1.5.3/conf/ > /dev/null 2>&1  &"
                #ssh root@$host "ps axu |grep java|grep 'logstash-1.5.3'"
                #ssh root@$host "rm -fr /service/elk/logstash-1.5.3/conf/logstash_indexer.conf"
        done; 
        echo '-----reset_config  end------' 
}

func_start_log(){
        echo '-----restart_log  start------'
        for host in `cat $1`;do
                echo $host;
                #ssh root@$host "ps axu |grep java|grep 'logstash-1.5.3' | grep -v 'grep' | awk '{print \$2}' | xargs kill"
                ssh root@$host "source /etc/profile ; /service/elk/logstash-1.5.3/bin/logstash -f /service/elk/logstash-1.5.3/conf/ >> /data/logs/logstash/logstash.log 2>&1  &"
                ssh root@$host "ps axu |grep java|grep 'logstash-1.5.3'"
        done;  
        echo '-----restart_log  end------'
}

func_stop_log(){
        echo '-----restart_log  start------'
        for host in `cat $1`;do
                echo $host;
                ssh root@$host "ps axu |grep java|grep 'logstash-1.5.3' | grep -v 'grep' | awk '{print \$2}' | xargs kill"
                #ssh root@$host "source /etc/profile ; /service/elk/logstash-1.5.3/bin/logstash -f /service/elk/logstash-1.5.3/conf/ > /dev/null 2>&1  &"
                ssh root@$host "ps axu |grep java|grep 'logstash-1.5.3'"
        done;  
        echo '-----restart_log  end------'
}

func_clean_log_db(){
        echo '-----clean_log_db  start------'
        for host in `cat $1`;do
                echo $host;
                #logstash conf
                #谨慎操作
                ssh root@$host "> /service/elk/sincedb_path/access_progress"
        done;  
        echo '-----clean_log_db  end------'
}

func_create_logstash_output(){
        echo '-----create_logstash_output  start------'
        for host in `cat $1`;do
                echo $host;
                ssh root@$host "mkdir -p /data/logs/logstash; touch /data/logs/logstash/logstash.log"
        done;  
        echo '-----create_logstash_output  end------'
}

case $1 in  
 reset_config)  
        func_reset_config $devops_conf_dir/host_list_devops
        ;;  
 restart_log)  
        func_stop_log $devops_conf_dir/host_list_devops
        func_start_log $devops_conf_dir/host_list_devops
        ;;  
 start_log)  
        func_start_log $devops_conf_dir/host_list_devops
        ;;     
 stop_log)  
        func_stop_log $devops_conf_dir/host_list_devops
        ;;      
 clean_log_db)  
        func_clean_log_db $devops_conf_dir/host_list_devops
        ;; 
 create_output)
        func_create_logstash_output $devops_conf_dir/host_list_devops
        ;;
 *)  
        echo "Usage: $name [reset_config|restart_log|start_log|stop_log|clean_log_db]" 
        exit 1  
        ;;  
esac  
exit 0 