title: R[week1] Getting start 
date: 2024-03-12
tags: [R-Language]
categories: R-Language
toc: true
---

> R: 4.3.2 (2023-10-31)  
> R studio: 2023.12.1+402 (2023.12.1+402)

# 一、Basic objects

## 1. vectors

一维数据集，常用于number, boolean, string, etc.
```
# define some variables
> x <- c(2, 4, 6, 8)
> xNum <- c(1, 3.14159, 5, 7)
> xLog <- c(TRUE, FALSE, TRUE, TRUE) 
> xChar <- c("foo", "bar", "boo", "far") 
> xMix <- c(1, TRUE, 3, "Hello, world!") 

# print variable
> xNum

# result
[1] 1.00000 3.14159 5.00000 7.00000
```

```
# 可以使用vector作为新verctor创建的初始值
> x2 <- c(xNum, xMix)

# print
> x2 

# result
[1] "1"             "3.14159"       "5"             "7"             "1"             "TRUE"         
[7] "3"             "Hello, world!"
```

```
# 下标与计算，需要注意R语言中下标从1开始
> xNum[2]
[1] 3.14159

# 计算时，不指明元素的话，会将vec中所有元素各执行一遍计算
> x2 <- c(x, x) 
> x2 + 1
[1] 3 5 7 9 3 5 7 9

> x2 * pi
[1]  6.283185 12.566371 18.849556 25.132741  6.283185 12.566371 18.849556 25.132741

> (x+cos(0.5)) * x2
[1]  5.755165 19.510330 41.265495 71.020660  5.755165 19.510330 41.265495 71.020660
```

> 注⚠️：由此可以看出R的一个特点，如果两个vec计算，元素数量不相同时，会反复使用元素少的vec。   
> 比如上面的x只有4个元素，而x2有8个元素，所以x的元素使用了两次。    
    
> 注⚠️：除了cos外，常用的数学函数还有：  
  
> 指数函数：  
> exp(x): 计算e的x次幂。   

> 对数函数：  
> log(x): 计算x的自然对数。   
> log10(x): 计算x的以10为底的对数。  
> log2(x): 计算x的以2为底的对数。  

> 幂函数：   
> sqrt(x): 计算x的平方根。   
> ^ 或 **: 进行幂运算，例如x^2 或 x**2 表示x的平方。   

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

## 2. More on Vectors and Indexing

### 2.1 子集
```
# 定义一个数字序列
> xSeq <- 1:10 # use 1:10 instead of typing 1,2,3,4 ...10.

# 获取子集
> xNum
[1] 1.00000 3.14159 5.00000 7.00000

# 第2到第4个元素
> xNum[2:4]
[1] 3.14159 5.00000 7.00000

# 第2-3个元素
> myStart <- 2 
> xNum[myStart:sqrt(myStart+7)]
[1] 3.14159 5.00000

> xSeq
[1]  1  2  3  4  5  6  7  8  9 10

# 负数代表排除掉第n个元素
> xSeq[-5:-7]
[1]  1  2  3  4  8  9 10

# 用vec计算得出另一个vec
> xSub <- xNum[2:4]
[1] 3.14159 5.00000 7.00000

# 可以用boolean来筛选元素
> xNum[c(FALSE, TRUE, TRUE, TRUE)]
[1] 3.14159 5.00000 7.00000

# 因此可以用表达式来获取logic value
> xNum[xNum > 3]
[1] 3.14159 5.00000 7.00000

```

## 3. Missing and interesting values - NA

### 3.1 重要的NA

```
> my.test.scores <- c(91, NA, NA)
NA

> mean(my.test.scores)
NA

> max(my.test.scores)
NA

# 筛选掉NA
## 方法1: na.rm=TRUE
> mean(my.test.scores, na.rm=TRUE)
91

> max(my.test.scores, na.rm=TRUE)
91

## 方法2：na.omit
> mean(na.omit(my.test.scores))
91

## 方法3: !is.na(x)
> is.na(my.test.scores)
[1] FALSE  TRUE  TRUE

> my.test.scores[!is.na(my.test.scores)]
91

```

## 4. Lists
**多维**的数据集合
```
> str(xChar)
chr [1:4] "foo" "bar" "boo" "far"

# 从vec合并为list
> xList <- list(xNum, xChar) 
> xList
[[1]]
[1] 1.00000 3.14159 5.00000 7.00000

[[2]]
[1] "foo" "bar" "boo" "far"

> str(xList)
List of 2
 $ : num [1:4] 1 3.14 5 7
 $ : chr [1:4] "foo" "bar" "boo" "far"

> summary(xList[[1]])
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  1.000   2.606   4.071   4.035   5.500   7.000

# 分配名字
## 方式1
> names(xList) <- c("itemnum", "itemchar")
## 方式2
xList <- list(itemnum=xNum, itemchar=xChar)
> xList
$itemnum
[1] 1.00000 3.14159 5.00000 7.00000

$itemchar
[1] "foo" "bar" "boo" "far"

# 分配名字后，可以用名字来替代索引，获得元素
> xList$itemnum # method 2: $name reference
[1] 1.00000 3.14159 5.00000 7.00000

> xList[["itemnum"]] # method 3: quoted name
[1] 1.00000 3.14159 5.00000 7.00000

```

## 5. Data frame
即为**矩阵**
```
# 创建一个date frame, 使用多个vec作为数据源
> x.df <- data.frame(xNum, xLog, xChar)

> x.df
     xNum  xLog xChar
1 1.00000  TRUE   foo
2 3.14159 FALSE   bar
3 5.00000  TRUE   boo
4 7.00000  TRUE   far

# 使用index获取特定元素
> x.df[2,1]
[1] 3.14159

> x.df1 <- data.frame(xNum, xLog, xChar, stringsAsFactors=TRUE) 
> x.df1
     xNum  xLog xChar
1 1.00000  TRUE   foo
2 3.14159 FALSE   bar
3 5.00000  TRUE   boo
4 7.00000  TRUE   far

> str(x.df1)
'data.frame':	4 obs. of  3 variables:
 $ xNum : num  1 3.14 5 7
 $ xLog : logi  TRUE FALSE TRUE TRUE
 $ xChar: Factor w/ 4 levels "bar","boo","far",..: 4 1 2 3
```

> 注⚠️：何为factor？  
> 个人理解类似于“枚举”，有限集合。

```
# 一些 'sub' data frame 方法
> x.df[2, ] # 第2行 all of row 2 
     xNum  xLog xChar
2 3.14159 FALSE   bar

> x.df[ ,3] # 第3列 all of column 3
[1] "foo" "bar" "boo" "far"

> x.df[2:3, ] # 第2-3行
     xNum  xLog xChar
2 3.14159 FALSE   bar
3 5.00000  TRUE   boo

> x.df[ ,1:2] # two columns # 第1-2列
     xNum  xLog
1 1.00000  TRUE
2 3.14159 FALSE
3 5.00000  TRUE
4 7.00000  TRUE

> x.df[-3, ] # omit the third observation # 排除掉第3行
     xNum  xLog xChar
1 1.00000  TRUE   foo
2 3.14159 FALSE   bar
4 7.00000  TRUE   far

> x.df[, -2] # omit the second column # 排除掉第2列
     xNum xChar
1 1.00000   foo
2 3.14159   bar
3 5.00000   boo
4 7.00000   far
```

> 注⚠️：从data frame中筛选数据，如果是单个元素，返回值类型为元素数量为1的vec；如果是一行或者一列，则为vec；如果是多行或者多列，则为一个新的data frame。

```
# 清理掉上述内容
> rm(list=ls()) # caution, deletes all objects!

# 新建一个data frame，填充元素
> store.num <- factor(c(3, 14, 21, 32, 54)) # store id
> store.rev <- c(543, 654, 345, 678, 234) # store revenue, $1000 
> store.visits <- c(45, 78, 32, 56, 34) # visits, 1000s 
> store.manager <- c("Annie", "Bert", "Carla", "Dave", "Ella") 
> (store.df <- data.frame(store.num, store.rev, store.visits,store.manager)) # 加括号，直接打印内容

  store.num store.rev store.visits store.manager
1         3       543           45         Annie
2        14       654           78          Bert
3        21       345           32         Carla
4        32       678           56          Dave
5        54       234           34          Ella

> store.df$store.manager # 查询manager
[1] "Annie" "Bert"  "Carla" "Dave"  "Ella" 

> mean(store.df$store.rev) # 查询revenue 平均值
[1] 490.8

> cor(store.df$store.rev, store.df$store.visits) # caculate correlation
[1] 0.8291032

> summary(store.df) # summary
 store.num   store.rev      store.visits store.manager     
 3 :1      Min.   :234.0   Min.   :32    Length:5          
 14:1      1st Qu.:345.0   1st Qu.:34    Class :character  
 21:1      Median :543.0   Median :45    Mode  :character  
 32:1      Mean   :490.8   Mean   :49                      
 54:1      3rd Qu.:654.0   3rd Qu.:56                      
           Max.   :678.0   Max.   :78                      
```

> cor()函数  
> 

## 6. Saving, loading, and importing data

### 6.1 save and reload
```
# 保存data frame到文件
> save(store.df, file="store-df-backup.RData")

# 删掉内存中的data frame
> rm(store.df) # caution, only if save() gave no error 

# 重新从文件中加载
> load("store-df-backup.RData")
``` 

```
> save.image() # saves file ".RData" 

> save.image("mywork.RData")

> load("mywork.RData")
```

> 注⚠️： save()和save.image()都是保存到文件；save()只保存指定的元素；save.image()保存所有的对象和数据。
> load()加载.RData时，会把文件中保存的内存对象，**覆盖**掉当前内存中的

### 6.2 import  
#### 6.2.1 excel  
```
# 安装并引用excel处理的依赖包
> install.packages ("readxl")
> library(readxl)

> deospray.data <- read_excel(path = "deospray sales.xls", sheet = "deospray") # filename, sheet name

> str(deospray.data)
tibble [620 × 22] (S3: tbl_df/tbl/data.frame)
 $ chain         : num [1:620] 1 1 1 1 1 1 1 1 1 1 ...
 $ week          : chr [1:620] "W16046" "W16047" "W16048" "W16049" ...
 $ sales_brand1  : num [1:620] 24 28.1 25.8 24.6 23 ...
 $ sales_brand2  : num [1:620] 31.3 39.6 102.2 68.4 37.8 ...
 $ sales_brand3  : num [1:620] 21.1 24 26.8 22.7 20.6 ...
 $ sales_brand4  : num [1:620] 48.4 52.1 53 43 53.9 ...
 $ sales_brand5  : num [1:620] 65 64.6 64.7 64.2 52.7 ...
 $ price_brand1  : num [1:620] 1.09 1.08 1.08 1.08 1.08 ...
 $ price_brand2  : num [1:620] 0.688 0.642 0.478 0.569 0.576 ...
 $ price_brand3  : num [1:620] 1.05 1.05 1.05 1.04 1.06 ...
 $ price_brand4  : num [1:620] 1.12 1.12 1.12 1.12 1.12 ...
 $ price_brand5  : num [1:620] 1.32 1.32 1.32 1.32 1.32 ...
 $ display_brand1: num [1:620] 0.02 0.02 0.19 0.18 0.05 0.05 0.08 0.03 0.05 0.04 ...
 $ display_brand2: num [1:620] 0 0 0 0 0 0 0 0 0 0 ...
 $ display_brand3: num [1:620] 0 0 0 0 0 0 0 0 0 0 ...
 $ display_brand4: num [1:620] 0.01 0 0 0 0 0 0 0 0 0 ...
 $ display_brand5: num [1:620] 0 0 0 0 0 0 0 0 0 0 ...
 $ feature_brand1: num [1:620] 0 0 0 0 0 0 0 0 0 0 ...
 $ feature_brand2: num [1:620] 0 0 0 0 0 0 0 0 0 0 ...
 $ feature_brand3: num [1:620] 0 0 0 0 0 0 0 0 0 0 ...
 $ feature_brand4: num [1:620] 0 0 0 0 0 0 0 0 0 0 ...
 $ feature_brand5: num [1:620] 0 0 0 0 0 0 0 0 0 0 ...

# 查看数据
> View(deospray.data)
```

#### 6.2.2 csv
```
> store.df <- read.csv("Data_descriptive.csv") 
> store.df$storeNum <- factor(store.df$storeNum)
```

## 7. function
```
# 一个简单的function se
> se <- function(x){sd(x) / sqrt(length(x))}

> se(store.df$store.visits)
[1] 8.42615 # 为什么PDF里面结果是NA????

> se <- function(x){
>   # computes standard error of the mean
>   tmp.sd <- sd(x) # standard deviation
>   tmp.N <- length(x) # sample size
>   tmp.se <- tmp.sd / sqrt(tmp.N) #std error of the mean return(tmp.se)
> }
```
> 注⚠️：其他的一些数学函数    
> 均值和中位数：    
> mean(): 计算向量或数据框列的均值。    
> median(): 计算向量或数据框列的中位数。     
       
> 极值：   
> min(): 计算向量或数据框列的最小值。    
> max(): 计算向量或数据框列的最大值。    

> 四分位数：     
> quantile(): 计算向量或数据框列的四分位数。   

> 变异系数：     
> cv() 或 coefficient_of_variation(): 计算向量或数据框列的变异系数。    
> sd(): 计算向量或数据框列的标准差。     
  
> 方差：    
> var(): 计算向量或数据框列的方差。    

> 标准误差：   
> stderr(): 计算向量或数据框列的标准误差。   

> 累计和和累计积：   
> cumsum(): 计算向量中元素的累计和。    
> cumprod(): 计算向量中元素的累计积。    

> 排序和排名：    
> sort(): 对向量或数据框列进行排序。     
> rank(): 计算向量或数据框列中元素的排名。     

> 其他统计函数：   
> sum(): 计算向量或数据框列的总和。   
> prod(): 计算向量或数据框列的乘积。    
> cor()、cov(): 分别计算相关系数和协方差矩阵。   
> scale(): 对向量或数据框列进行标准化。     

## 8. clean up
```
rm(list=ls()) # delete all visible objects in memory.
```

# 二、week1 code
```
# 获取当前已加载文件的目录
file_dir <- dirname(parent.frame(2)$ofile)
print(file_dir)
# 将工作目录设置为当前已加载文件的目录
setwd(file_dir)

# define some variables
x <- c(2, 4, 6, 8)
xNum <- c(1, 3.14159, 5, 7)
xLog <- c(TRUE, FALSE, TRUE, TRUE)
xChar <- c("foo", "bar", "boo", "far")
xMix <- c(1, TRUE, 3, "Hello, world!")

xNum

x2 <- c(xNum, xMix) 
x2

xNum[2]


x2 <- c(x, x) 
x2+1

x2 * pi

(x+cos(0.5)) * x2

xSeq <- 1:10 # use 1:10 instead of typing 1,2,3,4 ...10.

xNum

xNum[2:4]

myStart <- 2
xNum[myStart:sqrt(myStart+7)]

xSeq

xSeq[-5:-7]

xSub <- xNum[2:4] 
xSub

xNum[c(FALSE, TRUE, TRUE, TRUE)]

xNum[xNum > 3]

my.test.scores <- c(91, NA, NA)

mean(my.test.scores)

max(my.test.scores)

mean(my.test.scores, na.rm=TRUE)

max(my.test.scores, na.rm=TRUE)

mean(na.omit(my.test.scores))

is.na(my.test.scores)

my.test.scores[!is.na(my.test.scores)]

str(xChar)

xList <- list(xNum, xChar) 
xList

str(xList)

summary(xList[[1]])

xList <- list(xNum, xChar) # method 1: create, then name 
names(xList) <- c("itemnum", "itemchar")
xList

xList <- list(itemnum=xNum, itemchar=xChar)
names(xList)
xList

xList$itemnum # method 2: $name reference

x.df <- data.frame(xNum, xLog, xChar)
x.df

x.df[2,1]

x.df1 <- data.frame(xNum, xLog, xChar, stringsAsFactors=TRUE) 
x.df1
str(x.df1)

x.df[2, ] # all of row 2 
x.df[ ,3] # all of column 3

x.df[2:3, ]
x.df[ ,1:2] # two columns
x.df[-3, ] # omit the third observation
x.df[, -2] # omit the second column

rm(list=ls()) # caution, deletes all objects!
store.num <- factor(c(3, 14, 21, 32, 54)) # store id
store.rev <- c(543, 654, 345, 678, 234) # store revenue, $1000 
store.visits <- c(45, 78, 32, 56, 34) # visits, 1000s 
store.manager <- c("Annie", "Bert", "Carla", "Dave", "Ella") 
(store.df <- data.frame(store.num, store.rev, store.visits,store.manager))

store.df$store.manager

mean(store.df$store.rev)

cor(store.df$store.rev, store.df$store.visits)

summary(store.df)

save(store.df, file="store-df-backup.RData")

rm(store.df) # caution, only if save() gave no error 
load("store-df-backup.RData")

save.image() # saves file ".RData" 
save.image("mywork_week1.RData")

load("mywork_week1.RData")

# install.packages ("readxl")
# library(readxl)

deospray.data <- read_excel(path = "deospray sales.xls", sheet = "deospray") # filename, sheet name

str(deospray.data)

# View(deospray.data)

se <- function(x){sd(x) / sqrt(length(x))}

se(store.df$store.visits)

```
