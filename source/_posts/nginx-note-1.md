---
title: Nginx 設置 PHP-FPM
tags:
 - nginx
categories: devops
---
這篇是我在使用docker-compose建立nginx + php-fpm環境中，配置root的過程，遇到的小問題，以此紀錄。

## 建立環境

### work tree

在project目錄下建立docker-compose.yml，nginx.conf 以及要掛載進nginx的app目錄

``` bash
project
 ┣ app
 ┃ ┣ index.html
 ┃ ┣ index.php
 ┣ nginx.conf
 ┗ docker-compose.yml
 ```

<!-- more -->

### docker-compose.yml

``` bash
version: '3.0'

services:
    nginx:
        image: "nginx:latest"
        container_name: nginx
        ports:
            - "80:80"
        volumes:
            - ./app:/app
            - ./nginx.conf:/etc/nginx/conf.d/nginx.conf
        networks:
            - web
    php-fpm:
        build: "bitnami/nginx:latest"
        container_name: php-fpm
        volumes:
            - ./app:/app
        networks:
            - web
networks:
    web:
        driver: bridge
```

``` bash
docker-compose up -d
```


### nginx.conf

``` bash
server {
    listen       80;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm index.php;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass   php-fpm:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        include        fastcgi_params;
    }
}
```

把nginx run起來後，訪問 [http://localhost](http://localhost) 得到nginx預設的html page

預設的root目錄是在/usr/share/nginx/html

## 設定根目錄 /app

### 修改 nginx.conf

現在要讓網站的根目錄指向到/app

``` bash
location / {
        root   /app;
        index  index.html index.htm index.php;
    }
```

一樣訪問 http://localhost

得到index.html的內容，似乎是成功

接著訪問 http://localhost/index.php

出現404 Not Found

看到 404 直覺認為 index.php 不存在

先檢查掛載的 /app 目錄是否有 index.php

``` bash
$ docker-compose exec nginx ls /app
index.php index.html
```

確定有index.php 那為何會有 404 ?

### location

原因是出在 location 在匹配時沒有指定 root 為 /app

但是不是已經在這裡加過了嗎 ?

``` bash
location / {
        root   /app;
        index  index.html index.htm index.php;
    }
```

沒錯 ! 但是這裡還有

``` bash
location ~ \.php$ {
    try_files $uri =404;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass   php-fpm:9000;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
    fastcgi_param PATH_INFO $fastcgi_path_info;
    include        fastcgi_params;
}
```

雖然在匹配到 / 時已指定了 root 的位置，但是我們訪問的 http://localhost/index.php 是匹配到這裡

所以修改為

``` bash
location ~ \.php$ {
    root /app;
    try_files $uri =404;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass   php-fpm:9000;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
    fastcgi_param PATH_INFO $fastcgi_path_info;
    include        fastcgi_params;
}
```

再次訪問 http://localhost/index.php 就可以看到內容了

## 結論

嘗試過直接把 root 的指向寫在 server 層，是可以 work 的，因為在匹配到 php 的 location 設定中，沒有指定 root 就會往外層找

我認為2種方式都可以，但只針對沒有太多複雜邏輯的情況下，如果還有其他的導向或是多個工作目錄的話，使用 location 的方式應該會比較好

對於 nginx 的設定還需深究