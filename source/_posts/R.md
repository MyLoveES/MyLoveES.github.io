title: R Getting Start
date: 2024-02-12
tags: [Business]
categories: Business
toc: true
---

# 一、主要概念

### 1. 变量（variables）
#### 1.1 创造一个变量
```
# 使用等号 = 号赋值
> var1 = c(0,1,2,3)          
> print(var1)
[1] 0 1 2 3

# 使用左箭头 <- 赋值
> var2 <- c("learn","R")  
> print(var2)
[1] "learn" "R"
   
# 使用右箭头 -> 赋值
> c(TRUE,1) -> var3
> print(var3)
[1] 1 1          
```
#### 1.2 打印一下变量
```
# 打印现在已经定义了的变量
# 使用 ls() 命令, ls 其实就是 list 的缩写
```
{% asset_img R-ls.png %}

# 打印变量里的值
```
# 可以直接输入变量
xNum
```
{% asset_img R-va.png %}

```
# 也可以用print()
print(xNum)
```
{% asset_img R-print.png %}

```
# 或者用str()
[展示时可能会发生变化哦，比如小数点位数默认保留两位]
str(xNum)
```
{% asset_img R-str.png %}

### 2. 向量（vector）
#### 2.1 啥是向量
一组**相同类型**的元素的列表，比如都是数字，或者都是字符串
是**一维**的
{% asset_img R-vector.png %}
#### 2.2 创造一个向量
```
# 使用c()命令
x <- c(2, 4, 6, 8) # create a vector x using combine function c()
```
{% asset_img R-create-vector.png %}

#### 2.3 下标（index）
既然是列表，那么其中的每个元素自然是要有序号的，但是和常见的其他编程语言不同，**元素序号是从1开始的！**
```
> x <- c(2, 4, 6, 8) # create a vector x using combine function c()
> x
[1] 2 4 6 8
> x[1]
[1] 2
> x[4]
[1] 8
```
#### 2.4 NA（暂时不知道具体有啥用）
```
# 使用c()命令，可以用NA作为一个占位符，其实际值为空
x <- c(2, 4, NA, NA) 
```

### 3. 列表（list）
#### 3.1 和向量有什么不同？
向量：一组**一维**的**相同类型**的元素的列表，比如都是数字，或者都是字符串
数组：一组元素，可以包含**不同类型**的元素，比如数字、字符串以及矩阵的混合。除了一维外，也可以是**多维**的数组
{% asset_img R-vector.png %}
```
# 变量赋值
> my_list <- list(matrix(c(1, 2, 3, 4), nrow = 2), c(5, 6, 7))

# 打印变量
> my_list 
[[1]]
     [,1] [,2]
[1,]    1    3
[2,]    2    4

[[2]]
[1] 5 6 7
```

### 4. 数据框 （Data frame）
- 也有叫数据帧、数据表格的，感觉框表达的更形象

### 5. 依赖库（package）

### 6. 函数（function）

# 二、数据处理
