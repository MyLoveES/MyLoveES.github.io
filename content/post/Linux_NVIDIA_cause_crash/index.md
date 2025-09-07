---
title: Linux - NVIDIA 造成 kernel crash
date: 2022-07-10
tags: [Linux]
categories: Linux
toc: true
---

(没有查到根本原因)  

# 背景  

服务运行中，发现服务器频繁不定时重启。发现是kernel crash造成的。  
查看 /var/crash/ 下的log，发现   
`BUG: unable to handle kernel paging request at xxxxxxx`

# 分析vmcore

## 环境
- crash工具
- 崩溃转储文件(vmcore)
- 发生崩溃的内核映像文件(vmlinux)，包含调试内核所需调试信息

需要安装：kernel-debuginfo kernel-debuginfo-common  
```
yum install crash
wget http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-common-x86_64-`uname -r`.rpm
wget http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-`uname -r`.rpm
rpm -ivh *.rpm
```

安装完成后，在/lib/debug/lib/modules找到vmlinux内核映像文件

## vmcore-dmesg.txt

![](vmcore-dmesg.png)

## vmcore

```
crash /lib/debug/lib/modules/3.10.0-957.el7.x86_64/vmlinux /var/crash/127.0.0.1-2020-04-04-14\:10\:45/vmcore
```

![](vmcore.png)

执行 bt  

![](crash-bt.png)

执行 sym  

![](crash-sym.png)

# nvidia-smi 查看显卡信息

nvidia-smi gpu fan 显示 error  

![](nvidia-smi-err.png)

nvidia-smi -q

![](nvidia-q.png)  
  
![](nvidia-q-2.png)
