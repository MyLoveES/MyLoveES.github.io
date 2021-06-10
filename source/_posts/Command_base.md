---
layout:     post
title:      "Hi, Linux commands"
subtitle:   " \"Hi, Linux commands\""
date:       2021-02-21 17:00:00
author:     "ruili"
header-img: "img/post-bg-2015.jpg"
catalog: true
tags:
    - Linux
---

## 常用 Shell 命令

#### 1. 文本检索 wc

|wc      |                                        |
|--------|----------------------------------------|
|-c      |the byte counts|
|-m      |the character counts|
|-l      |the newline counts|
|-L      |the maximum display width|
|-w      |the word counts|


#### 2. 重定向

在shell脚本中，默认情况下，总是有三个文件处于打开状态：  
标准输入(键盘输入)、标准输出（输出到屏幕）、标准错误（也是输出到屏幕），它们分别对应的文件描述符是0，1，2 

\> 默认为标准输出重定向，与 1> 相同  
2>&1  意思是把 标准错误输出 重定向到 标准输出.  
&>file  意思是把标准输出 和 标准错误输出 都重定向到文件file中

/dev/null是一个文件，这个文件比较特殊，所有传给它的东西它都丢弃掉

#### 3. 运算符

|   |                                        |
|--------|----------------------------------------|
|=~      |其中 ~ 其实是对后面的正则表达式表示匹配的意思，如果匹配就输出1，不匹配就输出0.|
|==      |是否相等|

例子：
[[ $test =~ ^[0-9]+ ]] && echo 1 || echo 0