#!/bin/sh


apply_link_process=$(ps uax | grep 'user_apply_link.script.py' | grep -v 'grep' | wc -l)

if [ 1 -eq $apply_link_process ]
then
    echo "apply_link_process is running..."
else
    /opt/www/python_env/bin/python /opt/www/sc_poppy/python/scripts/user_apply_link.script.py  > /dev/null 2>&1 &
    echo "apply_link_process is restarted!"
fi

