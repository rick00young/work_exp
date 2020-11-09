## Nginx通过CORS实现跨域
2016-09-01 10:33 阅读 12.7k 评论 0
社区广播：运维派（Yunweipai.com）是国内最早成立的IT运维社区，欢迎大家投稿，让运维人不再孤寂的成长！

###什么是CORS
> CORS是一个W3C标准，全称是跨域资源共享(Cross-origin resource sharing)。它允许浏览器向跨源服务器，发出XMLHttpRequest请求，从而克服了AJAX只能同源使用的限制。

当前几乎所有的浏览器(Internet Explorer 8+， Firefox 3.5+， Safari 4+和 Chrome 3+)都可通过名为跨域资源共享(Cross-Origin Resource Sharing)的协议支持AJAX跨域调用。

Chrome,Firefox,Opera,Safari都使用的是XMLHttpRequest2对象，IE使用XDomainRequest。

简单来说就是跨域的目标服务器要返回一系列的Headers，通过这些Headers来控制是否同意跨域。跨域资源共享(CORS)也是未来的跨域问题的标准解决方案。

CORS提供如下Headers，Request包和Response包中都有一部分。

```
HTTP Response Header

Access-Control-Allow-Origin
Access-Control-Allow-Credentials
Access-Control-Allow-Methods
Access-Control-Allow-Headers
Access-Control-Expose-Headers
Access-Control-Max-Age
HTTP Request Header

Access-Control-Request-Method
Access-Control-Request-Headers
其中最敏感的就是Access-Control-Allow-Origin这个Header, 它是W3C标准里用来检查该跨域请求是否可以被通过。(Access Control Check)。如果需要跨域，解决方法就是在资源的头中加入Access-Control-Allow-Origin 指定你授权的域。
```
### 启用CORS请求
假设您的应用已经在example.com上了，而您想要从www.example2.com提取数据。一般情况下，如果您尝试进行这种类型的AJAX调用，请求将会失败，而浏览器将会出现源不匹配的错误。利用CORS后只需www.example2.com 服务端添加一个HTTP Response头，就可以允许来自example.com的请求。

将Access-Control-Allow-Origin添加到某网站下或整个域中的单个资源

```
Access-Control-Allow-Origin: http://example.com
Access-Control-Allow-Credentials: true (可选)
将允许任何域向您提交请求

Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true (可选)
提交跨域请求
```
如果服务器端已启用了CORS，那么提交跨域请求就和普通的XMLHttpRequest请求没什么区别。例如现在example.com可以向www.example2.com提交请求。

var xhr = new XMLHttpRequest();
// xhr.withCredentials = true; //如果需要Cookie等
xhr.open('GET', 'http://www.example2.com/hello.json');
xhr.onload = function(e) {
  var data = JSON.parse(this.response);
  ...
}
xhr.send();
服务端Nginx配置
要实现CORS跨域，服务端需要下图中这样一个流程

### Nginx通过CORS实现跨域

对于简单请求，如GET，只需要在HTTP Response后添加Access-Control-Allow-Origin。
对于非简单请求，比如POST、PUT、DELETE等，浏览器会分两次应答。第一次preflight（method: OPTIONS），主要验证来源是否合法，并返回允许的Header等。第二次才是真正的HTTP应答。所以服务器必须处理OPTIONS应答。
流程如下

首先查看http头部有无origin字段；
如果没有，或者不允许，直接当成普通请求处理，结束；
如果有并且是允许的，那么再看是否是preflight(method=OPTIONS)；
如果是preflight，就返回Allow-Headers、Allow-Methods等，内容为空；
如果不是preflight，就返回Allow-Origin、Allow-Credentials等，并返回正常内容。
用伪代码表示

```
location /pub/(.+) {
    if ($http_origin ~ <允许的域（正则匹配）>) {
        add_header 'Access-Control-Allow-Origin' "$http_origin";
        add_header 'Access-Control-Allow-Credentials' "true";
        if ($request_method = "OPTIONS") {
            add_header 'Access-Control-Max-Age' 86400;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, DELETE';
            add_header 'Access-Control-Allow-Headers' 'reqid, nid, host, x-real-ip, x-forwarded-ip, event-type, event-id, accept, content-type';
            add_header 'Content-Length' 0;
            add_header 'Content-Type' 'text/plain, charset=utf-8';
            return 204;
        }
    }
    # 正常nginx配置
    ......
}
```

### Nginx配置实例
实例一：允许example.com的应用在www.example2.com上跨域提取数据

在nginx.conf里找到server项,并在里面添加如下配置

```
location /{

add_header 'Access-Control-Allow-Origin' 'http://example.com';
add_header 'Access-Control-Allow-Credentials' 'true';
add_header 'Access-Control-Allow-Headers' 'Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,X-Requested-With';
add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS';
...
}
```
如果需要允许来自任何域的访问，可以这样配置

add_header Access-Control-Allow-Origin *;
注释如下

第一条指令：授权从example.com的请求(必需)
第二条指令：当该标志为真时，响应于该请求是否可以被暴露(可选)
第三条指令：允许脚本访问的返回头(可选)
第四条指令：指定请求的方法，可以是GET, POST, OPTIONS, PUT, DELETE等(可选)

重启Nginx

```
$ service nginx reload
测试跨域请求

$ curl -I -X OPTIONS -H "Origin: http://example.com" http://www.example2.com
成功时，响应头是如下所示

HTTP/1.1 200 OK
Server: nginx
Access-Control-Allow-Origin: example.com
```
实例二：Nginx允许多个域名跨域访问

由于Access-Control-Allow-Origin参数只允许配置单个域名或者*，当我们需要允许多个域名跨域访问时可以用以下几种方法来实现。

方法一
如需要允许用户请求来自www.example.com、m.example.com、wap.example.com访问www.example2.com域名时，返回头Access-Control-Allow-Origin，具体配置如下

在nginx.conf里面,找到server项,并在里面添加如下配置

```
map $http_origin $corsHost {
    default 0;
    "~http://www.example.com" http://www.example.com;
    "~http://m.example.com" http://m.example.com;
    "~http://wap.example.com" http://wap.example.com;
}

server
{
    listen 80;
    server_name www.example2.com;
    root /usr/share/nginx/html;
    location /
    {
        add_header Access-Control-Allow-Origin $corsHost;
    }
}
```
方法二
如需要允许用户请求来自localhost、www.example.com或m.example.com的请求访问xxx.example2.com域名时，返回头Access-Control-Allow-Origin，具体配置如下

在Nginx配置文件中xxx.example2.com域名的location /下配置以下内容
```
set $cors '';
if ($http_origin ~* 'https?://(localhost|www\.example\.com|m\.example\.com)') {
        set $cors 'true';
}

if ($cors = 'true') {
        add_header 'Access-Control-Allow-Origin' "$http_origin";
        add_header 'Access-Control-Allow-Credentials' 'true';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Mx-ReqToken,X-Requested-With';
}

if ($request_method = 'OPTIONS') {
        return 204;
}
```
方法三
如需要允许用户请求来自*.example.com访问xxx.example2.com域名时，返回头Access-Control-Allow-Origin，具体配置如下

在Nginx配置文件中xxx.example2.com域名的location /下配置以下内容

```
if ( $http_origin ~ http://(.*).example.com){
         set $allow_url $http_origin;
    }
    #CORS(Cross Orign Resource-Sharing)跨域控制配置
    #是否允许请求带有验证信息
    add_header Access-Control-Allow-Credentials true;
    #允许跨域访问的域名,可以是一个域的列表，也可以是通配符*
    add_header Access-Control-Allow-Origin $allow_url;
    #允许脚本访问的返回头
    add_header Access-Control-Allow-Headers 'x-requested-with,content-type,Cache-Control,Pragma,Date,x-timestamp';
    #允许使用的请求方法，以逗号隔开
    add_header Access-Control-Allow-Methods 'POST,GET,OPTIONS,PUT,DELETE';
    #允许自定义的头部，以逗号隔开,大小写不敏感
    add_header Access-Control-Expose-Headers 'WWW-Authenticate,Server-Authorization';
    #P3P支持跨域cookie操作
    add_header P3P 'policyref="/w3c/p3p.xml", CP="NOI DSP PSAa OUR BUS IND ONL UNI COM NAV INT LOC"';
```

方法四
如需要允许用户请求来自xxx1.example.com或xxx1.example1.com访问xxx.example2.com域名时，返回头Access-Control-Allow-Origin，具体配置如下

在Nginx配置文件中xxx.example2.com域名的location /下配置以下内容
```
location / {

    if ( $http_origin ~ .*.(example|example1).com ) {
    add_header Access-Control-Allow-Origin $http_origin;
    }
}
```

实例三：Nginx跨域配置并支持DELETE,PUT请求

默认Access-Control-Allow-Origin开启跨域请求只支持GET、HEAD、POST、OPTIONS请求，使用DELETE发起跨域请求时，浏览器出于安全考虑会先发起OPTIONS请求，服务器端接收到的请求方式就变成了OPTIONS，所以引起了服务器的405 Method Not Allowed。

解决方法

首先要对OPTIONS请求进行处理

```
if ($request_method = 'OPTIONS') { 
    add_header Access-Control-Allow-Origin *; 
    add_header Access-Control-Allow-Methods GET,POST,PUT,DELETE,OPTIONS;
    #其他头部信息配置，省略...
    return 204; 
}
```
当请求方式为OPTIONS时设置Allow的响应头，重新处理这次请求。这样发出请求时第一次是OPTIONS请求，第二次才是DELETE请求。

### 完整配置参考
### 将配置文件的放到对应的server {}里

```
add_header Access-Control-Allow-Origin *;

location / {
    if ($request_method = 'OPTIONS') { 
        add_header Access-Control-Allow-Origin *; 
        add_header Access-Control-Allow-Methods GET,POST,PUT,DELETE,OPTIONS;
        return 204; 
    }
    index index.php;
    try_files $uri @rewriteapp;
}
```
实例四：更多配置示例

示例一

```
The following Nginx configuration enables CORS, with support for preflight requests.

#
# Wide-open CORS config for nginx
#
location / {
     if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        #
        # Custom headers and headers various browsers *should* be OK with but aren't
        #
        add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
        #
        # Tell client that this pre-flight info is valid for 20 days
        #
        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'text/plain charset=UTF-8';
        add_header 'Content-Length' 0;
        return 204;
     }
     if ($request_method = 'POST') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
     }
     if ($request_method = 'GET') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
     }
}
```
示例二

```
if ($request_method = 'OPTIONS') {  
    add_header 'Access-Control-Allow-Origin' 'https://docs.domain.com';  
    add_header 'Access-Control-Allow-Credentials' 'true';  
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, PATCH, OPTIONS';  
    add_header 'Access-Control-Allow-Headers' 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization,token';  
    return 204;
}
if ($request_method = 'POST') {  
    add_header 'Access-Control-Allow-Origin' 'https://docs.domain.com';  
    add_header 'Access-Control-Allow-Credentials' 'true';  
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, PATCH, OPTIONS';  
    add_header 'Access-Control-Allow-Headers' 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization,token';  
}  
if ($request_method = 'GET') {  
    add_header 'Access-Control-Allow-Origin' 'https://docs.domain.com';  
    add_header 'Access-Control-Allow-Credentials' 'true';  
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, PATCH, OPTIONS';  
    add_header 'Access-Control-Allow-Headers' 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization,token';  
}
```
其它技巧
Apache中启用CORS

在httpd配置或.htaccess文件中添加如下语句

```
SetEnvIf Origin "^(.*\.example\.com)$" ORIGIN_SUB_DOMAIN=$1  
Header set Access-Control-Allow-Origin "%{ORIGIN_SUB_DOMAIN}e" env=ORIGIN_SUB_DOMAIN
PHP中启用CORS

``

通过在服务端设置Access-Control-Allow-Origin响应头

允许所有来源访问

```
<?php
header("Access-Control-Allow-Origin: *");
?>
``
允许来自特定源的访问

```
<?php
header('Access-Control-Allow-Origin: '.$_SERVER['HTTP_ORIGIN']);
?>
```
配置多个访问源
由于浏览器实现只支持了单个origin、*、null，如果要配置多个访问源，可以在代码中处理如下

```
<?php
$allowed_origins   = array(  
                            "http://www.example.com"   ,  
                            "http://app.example.com"  ,  
                            "http://cms.example.com"  ,  
                          );  
if (in_array($_SERVER['HTTP_ORIGIN'], $allowed_origins)){    
    @header("Access-Control-Allow-Origin: " . $_SERVER['HTTP_ORIGIN']);  
}
?>

HTML中启用CORS
<meta http-equiv="Access-Control-Allow-Origin" content="*">
```

### 参考文档

* http://www.google.com

* http://t.cn/RZEYPmD

* http://t.cn/RhcAN2d

* http://to-u.xyz/2016/06/30/nginx-cors/
* http://coderq.github.io/2016/05/13/cross-domain/

