---
title: Customized Java Exception
date: 2022-02-23 17:52:13
tags: [Java]
categories: Java
toc: true
---

## 自定义异常

- 简化 / 自定义打印结果
```java
@Override
public synchronized Throwable fillInStackTrace() {
    return this;
}

com.demo.test.xxxx.custom.exception.SimpleException: 自定义异常
```
