---
title: Tampermonkey增加去除简书的推荐阅读脚本
description: Tampermonkey增加去除简书的推荐阅读脚本
date: 2020-05-21 23:05:44
categories:
- Tampermonkey
tags:
- Tampermonkey
---
```JavaScript
// ==UserScript==
// @name         去除简书掘金的多余信息
// @description  去除简书掘金的多余信息，比如推荐阅读，一言难尽, 并不想看到
// @namespace    http://tampermonkey.net/
// @version      0.1
// @author       zjc
// @match        *://www.jianshu.com/p/*
// @match        *://juejin.im/post/*
// @require      https://code.jquery.com/jquery-2.2.4.min.js
// @grant        none
// ==/UserScript==

(function() {
    // 等待 1s 后执行
    // var timer = setTimeout(function(){},1000);

    // 每 0.1s 执行
    var interval = setInterval(function(){
        // 简书
        // 去除两个推荐阅读 (._3Z3nHf)
        if($("._3Z3nHf").length === 2){
            $("._3Z3nHf").remove();
            clearInterval(interval);
        }
        $("._gp-ck section").last().hide();
        $("._gp-ck .QxT4hD").hide();

        // 掘金
        $(".main-area.recommended-area.shadow").hide();
        $(".sidebar-block.related-entry-sidebar-block.shadow").hide();
        $(".index-book-collect").hide();
        $(".tag-list-box").hide();
        $(".article-banner").hide();
        $(".sidebar-block.author-block.shadow").hide();
    },100);
})();
```
