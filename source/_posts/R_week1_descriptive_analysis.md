title: R[week1] Desciptive Analysis
date: 2024-03-13
tags: [R-Language]
categories: R-Language
toc: true
---

> R: 4.3.2 (2023-10-31)  
> R studio: 2023.12.1+402 (2023.12.1+402)

> install and import libraries
```
# install.packages ("readxl")
# install.packages ("psych")
# install.packages ("car")
# install.packages ("gpairs")
# install.packages ("grid")
# install.packages ("lattice")
# install.packages ("corrplot")
# install.packages ("gplots")

library("readxl")
library("psych")
library("car")
library("gpairs")
library("grid")
library("lattice")
library("corrplot")
library("gplots")
```

# 一、Data

## 1. vectors

```
# 导入数据
> store.df <- read.csv("Data_Descriptive.csv", stringsAsFactors=TRUE) 
> str(store.df)
'data.frame':	2080 obs. of  10 variables:
 $ storeNum: int  101 101 101 101 101 101 101 101 101 101 ...
 $ Year    : int  1 1 1 1 1 1 1 1 1 1 ...
 $ Week    : int  1 2 3 4 5 6 7 8 9 10 ...
 $ p1sales : int  127 137 156 117 138 115 116 106 116 145 ...
 $ p2sales : int  106 105 97 106 100 127 90 126 94 91 ...
 $ p1price : num  2.29 2.49 2.99 2.99 2.49 2.79 2.99 2.99 2.29 2.49 ...
 $ p2price : num  2.29 2.49 2.99 3.19 2.59 2.49 3.19 2.29 2.29 2.99 ...
 $ p1prom  : int  0 0 1 0 0 0 0 0 0 0 ...
 $ p2prom  : int  0 0 0 0 1 0 0 0 0 0 ...
 $ country : Factor w/ 7 levels "AU","BR","CN",..: 7 7 7 7 7 7 7 7 7 7 ...

# 从上面结果可以看出，csv中一共有2080个观察值（行），10个变量（列）。
# 其中country是factor类型的，一共有7个level。
```

## 2. Summarize a single variable
### 2.1 Discrete variables
```
> table(store.df$p1price)
2.19 2.29 2.49 2.79 2.99 
 395  444  423  443  375
```
> 注⚠️：table() 函数    
> 用来创建频数表（Frequency Table）的函数。它可以用于统计一组数据中各个值出现的次数，并将结果以表格的形式呈现。    
> 它也可以提供多维的结果，比如：
```
> df <- data.frame(
+   gender = c("Male", "Female", "Female", "Male", "Male", "Female", "Male", "Female", "Female", "Male"),
+   age_group = c("Young", "Young", "Old", "Young", "Old", "Young", "Old", "Old", "Young", "Young")
+ )

# 创建多维频数表
> table(df$gender, df$age_group)

       Young Old
Female     3   2
Male       4   1
```
> 除table()外，还有其他类似的函数以及功能：
> prop.table()：
> prop.table() 函数用于计算表格中每个单元格的比例。它接受一个表格作为参数，并可以指定计算比例的维度。

> xtabs()：
> xtabs() 函数也可以用来创建频数表，类似于 table() 函数。它可以处理复杂的多维数据，并且支持使用公式语法。

> addmargins()：
> addmargins() 函数用于向表格中添加边际总计。它可以接受一个表格作为参数，并可以指定添加总计的维度。

> ftable()：
> ftable() 函数用于创建“扁平”（flattened）的表格，其中行和列都展开成一维，更容易查看和理解。

> summary()：
> summary() 函数通常用于摘要统计，对于因子变量，它会显示每个水平的数量。对于数值型变量，它会显示最小值、最大值、中位数等摘要统计量。

> dplyr::count()：
> dplyr 包中的 count() 函数用于计算数据框中每个类别的频数，并返回一个包含频数的数据框。

> psych::describe()：
> psych 包中的 describe() 函数可以生成一个包含多个统计指标的摘要统计信息，包括均值、标准差、最小值、最大值等。


题外话结束，继续前面的数据分析
```
> p1.table <- table(store.df$p1price) 

> p1.table

2.19 2.29 2.49 2.79 2.99 
 395  444  423  443  375

# talbe()返回的是一个table类型的结果
> str(p1.table)
 'table' int [1:5(1d)] 395 444 423 443 375
 - attr(*, "dimnames")=List of 1
  ..$ : chr [1:5] "2.19" "2.29" "2.49" "2.79" ...

# 转为图
> plot(p1.table)
```

{% asset_image plot1.png %}

> 注⚠️：plot()函数    
> 用于创建各种类型的图形的基本函数之一。它可以用于绘制散点图、线图、柱状图、箱线图等等。后面会有更多的用法，就不在此处列举了。    
> plot()会自适应地采用一种图表来展示数据，但我们同样可以根据需要调整。
```
# 二维table，获取每个价位上的促销频数
> table(store.df$p1price, store.df$p1prom)
      
         0   1
  2.19 354  41
  2.29 398  46
  2.49 381  42
  2.79 396  47
  2.99 343  32

# 计算product 1在每个price上的促销比例[prod1/(prod1+prod2)]
> p1.table2 <- table(store.df$p1price, store.df$p1prom) 

# 
> p1.table2[ ,2] / (p1.table2[ ,1] + p1.table2[ ,2])
      2.19       2.29       2.49       2.79       2.99 
0.10379747 0.10360360 0.09929078 0.10609481 0.08533333
```

### 2.2 Continuous variables

> 注⚠️：Continuous variables VS Discrete variable    

> 连续变量，指的是可以在一个范围内取任意值的变量，而不是一组离散的值。这种变量可以在某个范围内连续地取值，可以是任何数值。   
> 比如一个人的身高、体重、年龄等就是连续变量。因为身高、体重、年龄都可以在一个范围内取任何实数值，而不仅仅是某些特定的离散数值。另外，温度、时间等也是连续变量，因为它们可以在一个连续的范围内取任何值。    

> 离散变量，是指只能取有限个数值的变量。    
> 比如一个班级中学生的人数、一个箱子中的球的个数等都是离散变量，因为它们只能取整数值，而不能取连续的任意数值。

对于连续变量，根据其分布来总结数据更有帮助。最常见的方法是使用数学函数来描述数据的范围、中心、集中或分散的程度，以及可能感兴趣的具体点(如第90百分位):
|Describe                       |Function                   |Value                                      |
|-------------------------------|---------------------------|-------------------------------------------|
|Extremes[极值]                 |min(x)                     |Min                                        |
|                               |max(x)                     |Max                                        |
|Central trendency[中心趋势]    |mean(x)                    |Arithmetic mean                            |
|                               |median(x)                  |Mid                                        |
|Dispersion[离散度]             |var(x)                     |Variance around the mean                   |
|                               |sd(x)                      |Standard deviaion(sqrt(var(x)))            |
|                               |IQR(x)                     |Interquartile range, 75th-25th percentile  |
|                               |mad(x)                     |Median absolute deviation                  |
|Points[观察值/数据点]          |quantile(x, probs=c(...))  |Percentiles                                |
