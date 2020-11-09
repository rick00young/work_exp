### Nginx study:
verynginx:
流量监控

https://github.com/alexazhou/VeryNginx

https://goaccess.io/


### 允许本地主机的80端口允许访问
```
iptables -A INPUT -i eth0 -p tcp --dport 80 -j ACCEPT
```


### nginx 负载均衡 php-fpm
```
upstream test{
    server 192.168.75.133:9000;
    server 192.168.75.134:9000;
    server 192.168.75.135:9000;
}
server {
    .
    .
    location ~ [^/].php(/|$) {
        fastcgi_pass test;
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;#客户端真实IP
        proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;#http请求端真实IP
        fastcgi_index index.php;
        include fastcgi.conf;
    }
    .
    .
}
```

### nginx反向代理
```
user  www www;

worker_processes 10;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;

#最大文件描述符
worker_rlimit_nofile 51200;

events 
{
      use epoll;

      worker_connections 51200;
}

http 
{
      include       conf/mime.types;
      default_type  application/octet-stream;

      keepalive_timeout 120;

      tcp_nodelay on;

      upstream  www.zyan.cc  {
              server   192.168.1.2:80;
              server   192.168.1.3:80;
              server   192.168.1.4:80;
              server   192.168.1.5:80;
      }

      upstream  blog.zyan.cc  {
              server   192.168.1.7:8080;
              server   192.168.1.7:8081;
              server   192.168.1.7:8082;
      }

      server
      {
              listen  80;
              server_name  www.zyan.cc;

              location / {
                       proxy_pass        http://www.zyan.cc;
                       proxy_set_header   Host             $host;
                       proxy_set_header   X-Real-IP        $remote_addr;
                       proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
              }

              log_format  www_s135_com  '$remote_addr - $remote_user [$time_local] $request '
                                '"$status" $body_bytes_sent "$http_referer" '
                                '"$http_user_agent" "$http_x_forwarded_for"';
              access_log  /data1/logs/www.log  www_s135_com;
      }

      server
      {
              listen  80;
              server_name  blog.zyan.cc;

              location / {
                       proxy_pass        http://blog.zyan.cc;
                       proxy_set_header   Host             $host;
                       proxy_set_header   X-Real-IP        $remote_addr;
                       proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
              }

              log_format  blog_s135_com  '$remote_addr - $remote_user [$time_local] $request '
                                '"$status" $body_bytes_sent "$http_referer" '
                                '"$http_user_agent" "$http_x_forwarded_for"';
              access_log  /data1/logs/blog.log  blog_s135_com;
      }
}
```


