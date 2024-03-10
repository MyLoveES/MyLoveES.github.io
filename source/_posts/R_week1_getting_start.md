title: R[week1] Getting start 
date: 2024-03-12
tags: [Business]
categories: Business
toc: true
---

> R: 4.3.2 (2023-10-31)  
> R studio: 2023.12.1+402 (2023.12.1+402)

后面根据PDF顺序操作一遍

# 一、Basic objects

## 1. vectors

一维数据集，常用于number, boolean, string, etc.
```
# define some variables
x <- c(2, 4, 6, 8)
xNum <- c(1, 3.14159, 5, 7)
xLog <- c(TRUE, FALSE, TRUE, TRUE) 
xChar <- c("foo", "bar", "boo", "far") 
xMix <- c(1, TRUE, 3, "Hello, world!") 

# print variable
xNum

# result
> [1] 1.00000 3.14159 5.00000 7.00000
```

```
# 可以使用vector作为新verctor创建的初始值
x2 <- c(xNum, xMix)

# print
x2 

# result
> [1] "1"             "3.14159"       "5"             "7"             "1"             "TRUE"         
> [7] "3"             "Hello, world!"
```

```
# 下标与计算，需要注意R语言中下标从1开始
xNum[2]
> [1] 3.14159

# 计算时，不指明元素的话，会将vec中所有元素各执行一遍计算
x2 <- c(x, x) 
x2 + 1
> [1] 3 5 7 9 3 5 7 9

x2 * pi
> [1]  6.283185 12.566371 18.849556 25.132741  6.283185 12.566371 18.849556 25.132741

(x+cos(0.5)) * x2
> [1]  5.755165 19.510330 41.265495 71.020660  5.755165 19.510330 41.265495 71.020660
```

> 注⚠️：由此可以看出R的一个特点，如果两个vec计算，元素数量不相同时，会反复使用元素少的vec。  
> 比如上面的x只有4个元素，而x2有8个元素，所以x的元素使用了两次。  
    
> 除了cos外，常用的数学函数还有：  
> 指数函数：  
> exp(x): 计算e的x次幂。   

> 对数函数：  
> log(x): 计算x的自然对数。   
> log10(x): 计算x的以10为底的对数。  
> log2(x): 计算x的以2为底的对数。  

> 幂函数：   
> sqrt(x): 计算x的平方根。   
> ^ 或 **: 进行幂运算，例如x^2 或 x**2 表示x的平方。   
> 
> 三角函数：  
> sin(x): 计算x的正弦值。  
> cos(x): 计算x的余弦值。  
> tan(x): 计算x的正切值。  
> asin(x): 计算x的反正弦值。  
> acos(x): 计算x的反余弦值。  
> atan(x): 计算x的反正切值。  

> 双曲函数：  
> sinh(x): 计算x的双曲正弦值。  
> cosh(x): 计算x的双曲余弦值。  
> tanh(x): 计算x的双曲正切值。  

> 向上取整和向下取整：  
> ceiling(x): 对x进行向上取整。  
> floor(x): 对x进行向下取整。  

> 绝对值：  
> abs(x): 计算x的绝对值。  

> 阶乘：  
> factorial(x): 计算x的阶乘。  

> 取余：  
> %%：计算x除以y的余数，例如5 %% 2等于1。  
