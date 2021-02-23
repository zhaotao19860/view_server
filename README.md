## 综述

一个基于python的httpserver，通过cgi调用shell脚本，提供ip视图查询功能；

### 主要功能：

1. ip2view : 将ip地址转换为视图名称;
2. view2ip: 输出指定视图对应的IP地址段;

## 安装

```bash
# 1. git clone https://github.com/zhaotao19860/view_server.git
# 2. cd view_server && sh ./install.sh
# 3. systemctl start/stop view_server -- 服务启停
```

## 使用

```
http://10.226.133.67:8000/
```

http

## 反向代理

| cat /etc/nginx/nginx.conf                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| user nginx;<br/>worker_processes auto;<br/>error_log /var/log/nginx/error.log;<br/>pid /run/nginx.pid;<br/><br/>events {<br/>    worker_connections 1024;<br/>}<br/><br/>http {<br/>    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '<br/>                      '$status $body_bytes_sent "$http_referer" '<br/>                      '"$http_user_agent" "$http_x_forwarded_for"';<br/><br/>    access_log  /var/log/nginx/access.log  main;<br/><br/>    sendfile            on;<br/>    tcp_nopush          on;<br/>    tcp_nodelay         on;<br/>    keepalive_timeout   65;<br/>    types_hash_max_size 2048;<br/><br/>    include             /etc/nginx/mime.types;<br/>    default_type        application/octet-stream;<br/><br/>       upstream my_server {<br/>        server 10.226.133.67:8000;<br/>        keepalive 2000;<br/>    }<br/><br/>    server {<br/>        listen       80 default_server;<br/>        listen       [::]:80 default_server;<br/>        server_name  _;<br/>        root         /usr/share/nginx/html;<br/><br/>        location / {<br/>            proxy_pass http://my_server/;<br/>        }<br/><br/>        error_page 404 /404.html;<br/>            location = /40x.html {<br/>        }<br/><br/>        error_page 500 502 503 504 /50x.html;<br/>            location = /50x.html {<br/>        }<br/>    }<br/><br/>} |