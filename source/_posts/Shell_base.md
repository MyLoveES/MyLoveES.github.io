---
layout:     post
title:      "Hi, Linux shell"
subtitle:   " \"Hi, Linux shell\""
date:       2021-02-20 12:00:00
author:     "ruili"
header-img: "img/post-bg-2015.jpg"
categories: Linux
catalog: true
tags:
    - Linux
---

## Shell 基础

### variables

|variable|meaning                                 |
|--------|----------------------------------------|
|$$      |Shell本身的PID（ProcessID）|
|$!      |Shell最后运行的后台Process的PID|
|$?      |最后运行的命令的结束代码（返回值）,上一个命令执行后的返回结果。是显示最后命令的退出状态，0表示没有错误，其他表示有错误|
|$-      |使用Set命令设定的Flag一览|
|$*      |所有参数列表。是以一个单字符串显示所有向脚本传递的参数，与位置变量不同，参数可超过9个.如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。|
|$@      |所有参数列表。如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。|
|$#      |添加到Shell的参数个数|
|$0      |Shell本身的文件名|
|$1～$n  |添加到Shell的各参数值。$1是第1参数、$2是第2参数…。|

|symnbols|meaning                                 |
|--------|----------------------------------------|
|-eq     |等于 equal|
|-ne     |不等于 not equal|
|-gt     |大于 greater|
|-lt     |小于 less|
|-ge     |大于等于 greater or equal|
|-le     |小于等于 less or equal|
