---
layout:     post
title:      "Hi, Linux commands"
subtitle:   " \"Hi, Linux commands\""
date:       2021-02-21 17:00:00
author:     "ruili"
header-img: "img/post-bg-2015.jpg"
catalog: true
categories: Linux
tags:
    - Linux
---

## 常用 Shell 命令

### 1. 文本检索 wc

|wc      |                                        |
|--------|----------------------------------------|
|-c      |the byte counts|
|-m      |the character counts|
|-l      |the newline counts|
|-L      |the maximum display width|
|-w      |the word counts|


### 2. 重定向

在shell脚本中，默认情况下，总是有三个文件处于打开状态：  
标准输入(键盘输入)、标准输出（输出到屏幕）、标准错误（也是输出到屏幕），它们分别对应的文件描述符是0，1，2 

\> 默认为标准输出重定向，与 1> 相同  
2>&1  意思是把 标准错误输出 重定向到 标准输出.  
&>file  意思是把标准输出 和 标准错误输出 都重定向到文件file中

/dev/null是一个文件，这个文件比较特殊，所有传给它的东西它都丢弃掉

### 3. 运算符

|   |                                        |
|--------|----------------------------------------|
|=~      |其中 ~ 其实是对后面的正则表达式表示匹配的意思，如果匹配就输出1，不匹配就输出0.|
|==      |是否相等|

例子：
[[ $test =~ ^[0-9]+ ]] && echo 1 || echo 0

### 4. awk
- -F fs or --field-separator fs  
指定输入文件折分隔符，fs是一个字符串或者是一个正则表达式，如-F:。 
- -v var=value or --asign var=value 
赋值一个用户定义变量。
- -f scripfile or --file scriptfile  
从脚本文件中读取awk命令。  
- -mf nnn and -mr nnn  
对nnn值设置内在限制，-mf选项限制分配给nnn的最大块数目；-mr选项限制记录的最大数目。这两个功能是Bell实验室版awk的扩展功能，在标准awk中不适用。
- -W compact or --compat, -W traditional or --traditional
在兼容模式下运行awk。所以gawk的行为和标准的awk完全一样，所有的awk扩展都被忽略。
- -W copyleft or --copyleft, -W copyright or --copyright
打印简短的版权信息。
- -W help or --help, -W usage or --usage
打印全部awk选项和每个选项的简短说明。
- -W lint or --lint
打印不能向传统unix平台移植的结构的警告。
- -W lint-old or --lint-old
打印关于不能向传统unix平台移植的结构的警告。
- -W posix
打开兼容模式。但有以下限制，不识别：/x、函数关键字、func、换码序列以及当fs是一个空格时，将新行作为一个域分隔符；操作符**和**=不能代替^和^=；fflush无效。
- -W re-interval or --re-inerval
允许间隔正则表达式的使用，参考(grep中的Posix字符类)，如括号表达式[[:alpha:]]。
- -W source program-text or --source program-text
使用program-text作为源代码，可与-f命令混用。
- -W version or --version
打印bug报告信息的版本。

**用法**

```
2 this is a test  
3 Are you like awk  
This's a test  
10 There are orange,apple,mongo  

1. awk '{[pattern] action}' {filenames}   # 行匹配语句 awk '' 只能用单引号  
 $ awk '{print $1,$4}' log.txt
 ---------------------------------------------
 2 a
 3 like
 This's
 10 orange,apple,mongo

 # 格式化输出
 $ awk '{printf "%-8s %-10s\n",$1,$4}' log.txt
 ---------------------------------------------
 2        a
 3        like
 This's
 10       orange,apple,mongo


2. awk -F  #-F相当于内置变量FS, 指定分割字符

 # 使用","分割
 $  awk -F, '{print $1,$2}'   log.txt
 ---------------------------------------------
 2 this is a test
 3 Are you like awk
 This's a test
 10 There are orange apple

 # 或者使用内建变量
 $ awk 'BEGIN{FS=","} {print $1,$2}'     log.txt
 ---------------------------------------------
 2 this is a test
 3 Are you like awk
 This's a test
 10 There are orange apple

 # 使用多个分隔符.先使用空格分割，然后对分割结果再使用","分割
 $ awk -F '[ ,]'  '{print $1,$2,$5}'   log.txt
 ---------------------------------------------
 2 this test
 3 Are awk
 This's a
 10 There apple

3. awk -v  # 设置变量

 $ awk -va=1 '{print $1,$1+a}' log.txt
 ---------------------------------------------
 2 3
 3 4
 This's 1
 10 11

 $ awk -va=1 -vb=s '{print $1,$1+a,$1b}' log.txt
 ---------------------------------------------
 2 3 2s
 3 4 3s
 This's 1 This'ss
 10 11 10s

4. awk -f {awk脚本} {文件名}

 awk -f cal.awk log.txt

5. 过滤第一列大于2并且第二列等于'Are'的行
 $ awk '$1>2 && $2=="Are" {print $1,$2,$3}' log.txt    #命令
 #输出
 3 Are you

6. 计算大小
 
 awk '{sum+=$5} END {print sum}'

7. 从文件中找出长度大于 80 的行：
 awk 'length>80' log.txt
```

### nc 

```
通过 nc 传输文件和目录
目录：
接收端：nc  -l 7777 | tar xf -
发送端：tar cf - ${dir_name} | nc 192.168.1.1 7777


文件：
往10.105.135.50 上传输文件：
接收端：nc -l 9999 > 123 
发送端：nc 10.105.135.50 9999 < 123
```
