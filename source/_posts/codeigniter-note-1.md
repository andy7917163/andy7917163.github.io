---
title: PHP Codeigniter CSRF-token
tags:
 - php
 - codeigniter
categories: php
---
Codeigniter 有內建csrf的功能，紀錄一下使用過程。

## Enable CSRF protection

修改 application/config/config.php

``` bash
$config['csrf_protection'] = TRUE;
```

## Use in form

如果使用 form helper ，form_open() 會自動生成 hidden 的 input。

如果要自行加入，可以使用 get_csrf_token_name() 和 get_csrf_hash()。

``` bash
<input type="hidden" name="<?=$get_csrf_token_name['name'];?>" value="<?=$get_csrf_hash['hash'];?>" />
```

<!-- more -->

## Use in ajax

一樣透過 get_csrf_token_name() 和 get_csrf_hash()，得到 token 並加入 data

``` bash
$.ajax({
    type:'POST',
    url:'/ajax', //ajax接收的server端
    data:{"<?=$get_csrf_token_name['name'];?>":"<?=$get_csrf_hash['hash'];?>"},
    success:function(data){
        alert(data.msg);
    },
    dataType:'json'
});
```

## Exclude Uris

可將希望跳過 csrf protection 的 uri 加入此參數

``` bash
$config['csrf_exclude_uris'] = array('api/person/add');
```
可用正則表達式

``` bash
$config['csrf_exclude_uris'] = array(
    'api/record/[0-9]+',
    'api/title/[a-z]+'
);
```

## Tips

由於 csrf 功能是使用 cookie 來記錄 token，所以在本機測試環境中，要注意是否有設定 cookie 的 secure 限制。

``` bash
$config['cookie_secure'] = TRUE;
```

設為 TRUE 表示 cookie 需使用在有 ssl 的環境下，否則 FALSE。

---

> [官方 Document](https://www.codeigniter.com/user_guide/libraries/security.html#cross-site-request-forgery-csrf)