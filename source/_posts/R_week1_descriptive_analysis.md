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
|Describe                       |Function                   |Meaning|Value                                      |
|-------------------------------|---------------------------|-------|-------------------------------------------|
|Extremes[极值]                 |min(x)                     ||Min                                        |
|                               |max(x)                     ||Max                                        |
|Central trendency[中心趋势]    |mean(x)                    ||Arithmetic mean                            |
|                               |median(x)                  ||Mid                                        |
|Dispersion[离散度]             |var(x)                     |方差，描述数据分布离散程度的一种统计量。它衡量了数据集中每个数据点与数据集平均值之间的差异程度|Variance around the mean                   |
|                               |sd(x)                      |标准差，方差的平方根|Standard deviaion(sqrt(var(x)))            |
|                               |IQR(x)                     ||Interquartile range, 75th-25th percentile  |
|                               |mad(x)                     ||Median absolute deviation                  |
|Points[观察值/数据点]          |quantile(x, probs=c(...))  ||Percentiles                                |

> 方差 var(x)     
> 描述数据分布离散程度的一种统计量。它衡量了数据集中每个数据点与数据集平均值之间的差异程度   

> 标准差 sd(x)    
> 方差的平方根   

> IQR(x)   
> 是统计学中用于度量数据分布的差异性的一种方法。它是第三四分位数（Q3）与第一四分位数（Q1）之间的距离，通常用来描述数据的离散程度。与方差和标准差不同，IQR不受极端值（离群值）的影响，因此在某些情况下，IQR更适合用来度量数据的离散程度。     
> IQR的优势在于它提供了一个对数据集的中间50%数据的度量，而不受极端值的影响。这使得它在处理偏斜或包含极端值的数据集时更为稳健。在描述偏态分布或存在离群值的数据时，IQR通常比标准差更具有代表性。    
> 在统计学和数据分析中，通常会将IQR与箱线图结合使用。箱线图显示了数据的四分位数范围以及任何离群值的存在，这使得可以直观地了解数据的分布情况，并且可以通过比较不同组的箱线图来识别任何差异。      

> mad(x)    
> 同IQR，简单比较一下这两者：  
<div style="background-color:#f0f0f0; padding:10px;">
### IQR（Interquartile Range）：

> **定义**：IQR是数据集中第三四分位数（Q3）和第一四分位数（Q1）之间的距离。            
> **计算方法**：IQR = Q3 - Q1，其中Q3是数据集中75th百分位数，Q1是数据集中25th百分位数。   
> **用途**：IQR通常用于识别数据中的离群值，因为它提供了数据中间50%的范围，并且对于偏斜分布的数据比标准差更鲁棒。   

### MAD（Median Absolute Deviation）：

> **定义**：MAD是数据点与数据集中位数的绝对偏差的中位数。    
> **计算方法**：首先计算每个数据点与数据集中位数的绝对偏差，然后取这些绝对偏差的中位数。   
> **用途**：MAD也用于度量数据的离散程度，并且在处理离群值时更具有鲁棒性，因为它不受极端值的影响，类似于IQR。    

### IQR 和 MAD 相比：

1. **计算方法**：IQR是基于四分位数计算的，而MAD是基于中位数计算的。
2. **鲁棒性**：IQR和MAD都是鲁棒的统计量，对异常值的影响较小，但在某些情况下，MAD可能更为鲁棒，特别是当数据集包含大量离群值时。
3. **解释**：IQR更容易解释，因为它代表了数据集中间50%的范围，而MAD则表示数据点与中位数的典型偏差。
4. **常见用途**：IQR和MAD在异常值检测和数据分析中都很常见，但在不同的背景下可能有不同的应用场景。
</div>

> quantile(x, probs=c(...))     
> 通常用于计算数据集 x 的分位数。其中 probs 参数是一个包含所需分位数的百分比的向量。   

> x：包含数据的向量或数据框。   
> probs：一个包含所需分位数的百分比的向量，例如，probs = c(0.25, 0.5, 0.75) 表示计算第一四分位数（25th百分位数）、中位数（50th百分位数）、第三四分位数（75th百分位数）。    

> 返回值：返回一个包含计算得到的分位数的向量，其顺序与 probs 中指定的顺序相对应。    
```
# 创建一个示例数据集
> data <- c(10, 15, 20, 25, 30, 35, 40, 45, 50)

# 计算第一四分位数、中位数、第三四分位数
> quantiles <- quantile(data, probs = c(0.25, 0.5, 0.75))

# 打印结果
> print(quantiles)
25% 50% 75% 
 20  30  40
```
题外话结束。
```
> min(store.df$p1sales)
[1] 73

> max(store.df$p1sales)
[1] 263

> mean(store.df$p1prom)
[1] 0.1

> median(store.df$p2sales)
[1] 96

> var(store.df$p1sales)
[1] 805.0044

> sd(store.df$p1sales)
[1] 28.3726

> IQR(store.df$p1sales)
[1] 37

> mad(store.df$p1sales)
[1] 26.6868

> quantile(store.df$p1sales, probs = c(0.25, 0.5, 0.75))
25% 50% 75% 
113 129 150 
```

> For skewed and asymmetric distributions that are common in marketing, such as unit sales or household income, the arithmetic mean() and standard deviation sd() may be misleading; in those cases, the median() and the interquartile range IQR() (the range of the middle 50% of data) are often used to summarize a distribution.    
> 对于市场营销中常见的倾斜和不对称分布，例如单位销售或家庭收入，算术平均值()和标准差sd()可能会产生误导;在这些情况下，中位数()和四分位数间距IQR()(中间50%数据的范围)通常用于总结分布。    

> 因为在偏斜和不对称分布的情况下，数据中可能存在极端值（离群值），这些值对于算术平均值和标准差的影响较大，导致这两个统计量可能不太准确地反映整体数据的特征。   

> 1. 算术平均值的问题： 偏斜分布中的极端值会对平均值产生较大的影响，使其偏离数据集的中心趋势。这导致平均值可能不再是数据的典型中心度量。   

> 2. 标准差的问题： 标准差对极端值非常敏感，因为它是基于平方差的，这会放大离群值的影响。这样，标准差可能高估了数据的真实分散程度。   

> 相比之下，中位数是数据集中的中间值，不受极端值的影响，因此更能反映数据的中心趋势。四分位数间距（IQR）是数据中间50%的范围，它也对离群值具有一定的鲁棒性，因此更适合在偏斜分布中度量数据的分散程度。   

> 综合起来，为了更准确地摘要和理解偏斜分布的数据特征，使用中位数和四分位数间距通常是更合适的选择。这样的度量方法更具有鲁棒性，能够提供更稳健、不受极端值干扰的数据摘要。   
```
> quantile(store.df$p1sales, probs = c(0.05, 0.95)) # central 90% data
 5% 95% 
 93 184 

> quantile(store.df$p1sales, probs = 0:10/10)
   0%   10%   20%   30%   40%   50%   60%   70%   80%   90%  100% 
 73.0 100.0 109.0 117.0 122.6 129.0 136.0 145.0 156.0 171.0 263.0o

> quantile(store.df$p1sales, probs = seq(from=0, to=1, by=0.1))
   0%   10%   20%   30%   40%   50%   60%   70%   80%   90%  100% 
 73.0 100.0 109.0 117.0 122.6 129.0 136.0 145.0 156.0 171.0 263.0
```

> Suppose we wanted a summary of the sales for product 1 and product 2 based on their median and interquartile range. We might assemble these summary statistics into a data frame that is easier to read than the one-line- at-a-time output above. We create a data frame to hold our summary statistics. We name the columns and rows and fill in the cells with function values:    
> 假设我们想根据产品1和产品2的中位数和四分位数范围汇总它们的销售额。我们可以将这些汇总统计信息组合成一个数据帧，这样比上面的一行一行的输出更容易阅读。我们创建一个数据框架来保存汇总统计数据。我们为列和行命名，并用函数值填充单元格:   
```
mysummary.df <- data.frame(matrix(NA, nrow=2, ncol=2)) # 2 by 2 empty matrix 
names(mysummary.df) <- c("Median Sales", "IQR") # name columns 
rownames(mysummary.df) <- c("Product 1", "Product 2") # name rows 
mysummary.df["Product 1", "Median Sales"] <- median(store.df$p1sales) 
mysummary.df["Product 2", "Median Sales"] <- median(store.df$p2sales) 
mysummary.df["Product 1", "IQR"] <- IQR(store.df$p1sales) 
mysummary.df["Product 2", "IQR"] <- IQR(store.df$p2sales)
mysummary.df
```
