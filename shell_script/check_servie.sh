#/usr/bin/bash

check_service=$(ps uax | grep 'service_works_artist_to_es_script.py' | grep -v 'grep' | wc -l)

time=`date +'%Y-%m-%d %H:%M:%S'`
if [ 1 -eq $check_service ]
then
        echo $time "service_works_artist_to_es_script.py is running..."
    else
            sourc /home/work/.bashrc
                nohup /home/work/poppy/bin/python3 service_works_artist_to_es_script.py &
                    echo $time "service_works_artist_to_es_script is restarted!"
                fi
