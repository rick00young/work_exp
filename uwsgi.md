
```
uwsgi5000.ini

[uwsgi]
socket = 0.0.0.0:5000
home = /home/work/poppy/python3_env
master = true
base = /home/work/poppy/sy_poppy
wsgi-file = manage.py
chdir = %(base)
callable = app
no-stie = true
workers = 4
reload-mercy = 10
vacuum = true
max-requests = 1000
#limit-as = 1024
buffer-size = 90000
stats = 127.0.0.1:9191
pidfile = /opt/logs/var/run/uwsgi5000.pid
daemonize = /opt/logs/poppy/uwsgi5000.log

```