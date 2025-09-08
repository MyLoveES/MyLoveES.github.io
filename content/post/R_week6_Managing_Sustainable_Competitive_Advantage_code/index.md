---
title: R[week6] Managing Sustainable Competitive Advantage code
date: 2024-03-29
categories:
- "教程"
tags:
- "R语言"
- "数据分析"
- "竞争优势"
math: true
toc: true
---

> R: 4.3.2 (2023-10-31)
> R studio: 2023.12.1+402 (2023.12.1+402)

假设一家公司正在开发一款新系列的平板电脑，并试图确定平板电脑的尺寸应该有多大，以及应该具有何种类型的存储和内存。
为了支持这个决定，了解客户对这些不同特征的价值会很有帮助。
- 客户喜欢还是不喜欢大屏幕尺寸？
- 如果他们喜欢，他们愿意为更大尺寸的屏幕支付多少更多的费用？ 
- 是否有一些客户群体比其他客户更喜欢大屏幕？ 

## Choice-Based Conjoint Analysis Data

```
> cbc.df<-read.csv("Data_Conjoint_Choice.csv", stringsAsFactors = TRUE) 

> str(cbc.df)
'data.frame':	6165 obs. of  10 variables:
 $ ConsumerId        : int  1 1 1 1 1 1 1 1 1 1 ...
 $ ChoiceSetId       : int  1 1 1 2 2 2 3 3 3 4 ...
 $ AlternativeIdInSet: int  1 2 3 1 2 3 1 2 3 1 ...
 $ Choice            : int  1 0 0 1 0 0 0 0 1 1 ...
 $ Brand             : Factor w/ 5 levels "Galaxy","iPad",..: 2 5 3 2 5 4 5 3 1 2 ...
 $ Size              : Factor w/ 4 levels "sz10inch","sz7inch",..: 2 1 4 3 1 2 3 4 1 4 ...
 $ Storage           : Factor w/ 4 levels "st128gb","st16gb",..: 3 4 2 3 1 4 4 2 1 2 ...
 $ Ram               : Factor w/ 3 levels "r1gb","r2gb",..: 3 2 2 1 3 1 1 3 2 3 ...
 $ Battery           : Factor w/ 3 levels "b7h","b8h","b9h": 1 3 2 2 1 3 1 3 3 1 ...
 $ Price             : int  499 399 499 399 299 199 199 399 499 299 ...

> head(cbc.df)
  ConsumerId ChoiceSetId AlternativeIdInSet Choice   Brand     Size Storage  Ram Battery Price
1          1           1                  1      1    iPad  sz7inch  st32gb r4gb     b7h   499
2          1           1                  2      0 Surface sz10inch  st64gb r2gb     b9h   399
3          1           1                  3      0  Kindle  sz9inch  st16gb r2gb     b8h   499
4          1           2                  1      1    iPad  sz8inch  st32gb r1gb     b8h   399
5          1           2                  2      0 Surface sz10inch st128gb r4gb     b7h   299
6          1           2                  3      0   Nexus  sz7inch  st64gb r1gb     b9h   199
```

- cbc.df 中的前三行描述了对受访者1提出的第一个问题。选择列显示该受访者选择了第一个备选方案。
- ConsumerId 表示回答这个问题的受访者。
- ChoiceSetId 表示这前三行是第一个问题的配置文件。ChoiceSetId 编号 1:15 是为受访者1，然后 15:30 是为受访者2，依此类推。
- AlternativeIdInSet 表示第一行是备选方案1，第二行是备选方案2，第三行是备选方案3。
- Choice 表示受访者选择了哪个备选方案；对于每个选择问题中被指定为首选备选方案的配置文件，它的值为1。

现在重要的是估计一个完整的选择模型。任何建模的第一步是使用基本描述性统计了解数据。我们从摘要开始:

```
> summary(cbc.df)
   ConsumerId   ChoiceSetId   AlternativeIdInSet     Choice           Brand            Size         Storage       Ram       Battery        Price      
 Min.   :  1   Min.   :   1   Min.   :1          Min.   :0.0000   Galaxy :1263   sz10inch:1371   st128gb:1376   r1gb:2192   b7h:1918   Min.   :169.0  
 1st Qu.: 35   1st Qu.: 514   1st Qu.:1          1st Qu.:0.0000   iPad   :1538   sz7inch :1767   st16gb :1370   r2gb:2055   b8h:2055   1st Qu.:199.0  
 Median : 69   Median :1028   Median :2          Median :0.0000   Kindle :1119   sz8inch :1520   st32gb :1774   r4gb:1918   b9h:2192   Median :299.0  
 Mean   : 69   Mean   :1028   Mean   :2          Mean   :0.3333   Nexus  :1104   sz9inch :1507   st64gb :1645                          Mean   :307.5  
 3rd Qu.:103   3rd Qu.:1542   3rd Qu.:3          3rd Qu.:1.0000   Surface:1141                                                         3rd Qu.:399.0  
 Max.   :137   Max.   :2055   Max.   :3          Max.   :1.0000                                                                        Max.   :499.0 
```

我们看到每个属性水平在问题中出现了多少次。总结选择数据的一个更具信息量的方式是计算选择计数，这是受访者在每个特征水平上选择备选方案的次数的交叉表。我们可以使用 xtabs() 轻松地完成这个任务。

```
> xtabs(Choice~Price, data=cbc.df)
Price
169 199 299 399 499 
688 472 329 365 201
```
- 表格的行表示选择（Choice），在这个例子中，选择是一个二元变量（1 或 0）。
- 表格的列表示价格（Price），列中的数值表示该价格下被选择的次数。
具体到结果的解释如下：  
  
在价格为 169 的情况下，被选择了 688 次。  
在价格为 199 的情况下，被选择了 472 次。  
在价格为 299 的情况下，被选择了 329 次。   
在价格为 399 的情况下，被选择了 365 次。   
在价格为 499 的情况下，被选择了 201 次。   

受访者更经常选择售价为 £169 的平板电脑，而不是售价为 £299 或 £499 的平板电脑。  
如果我们计算尺寸属性的计数，我们会发现选择在 7 英寸、8 英寸和 10 英寸之间更加平衡，而在 9 英寸上选择更多。  

> xtabs()

用于创建交叉表（Contingency Table）的函数。交叉表是一种用于展示两个或多个分类变量之间关系的表格，通常显示了每个组合的频数或频率。

```
> xtabs(Choice~Size, data=cbc.df)
Size
sz10inch  sz7inch  sz8inch  sz9inch 
     475      535      472      573 
```

在估计选择模型之前，始终鼓励为每个属性计算选择计数。 

## Prepare the data

我们现在可以估计我们的第一个选择模型了。通过拟合选择模型，我们可以精确地测量每个属性与受访者选择的关联程度。
我们使用 mlogit 包，你可能需要使用 install.packages() 安装。mlogit 估计最基本和常用的选择模型，即多项逻辑回归模型。

### Define reference levels - used when estimating model
```
cbc.df$Brand <- relevel(cbc.df$Brand, ref = "Nexus") 
cbc.df$Size <- relevel(cbc.df$Size, ref = "sz7inch") 
cbc.df$Storage <- relevel(cbc.df$Storage, ref = "st16gb") 
cbc.df$Ram <- relevel(cbc.df$Ram, ref = "r1gb") 
cbc.df$Battery <- relevel(cbc.df$Battery, ref = "b7h")
```
### Define data format
mlogit 要求选择数据具有特定的数据格式。我们使用 dfidx 包中的 dfidx 函数来整理格式。
- choice 参数指示包含响应数据的列。在我们的案例中，choice = “Choice”。
- idx 参数指示备选方案的结构。列表中的第一个索引表示选择集和消费者的列，第二个索引表示每个选择集中备选方案的列。

```
cbc.mlogit <- dfidx(cbc.df, choice="Choice", idx=list(c("ChoiceSetId", "ConsumerId"), "AlternativeIdInSet"))
```

## Multinomial conjoint model estimation with mlogit()

当我们运行模型时，它会选择每个离散属性的参考水平。参考水平的效用被归一化为零。我们在数据加载阶段为每个离散属性指定了一个参考水平。这些参考水平是 Nexus、7 英寸屏幕、16GB 硬盘、1GB 内存、7 小时电池。我们将价格视为连续变量，因此不需要指定参考水平。  
该模型假定没有误差项的备选方案 j 的效用如下所示。

$$
V_j = \beta_{11}[ \text{Brand} = \text{Galaxy}] + \beta_{12}[ \text{Brand} = \text{iPad}] + \beta_{13}[ \text{Brand} = \text{Kindle}] + \beta_{14}[ \text{Brand} = \text{Surface}] + \beta_{21}[ \text{Screen} = \text{10inch}] + \beta_{22}[ \text{Screen} = \text{9inch}] + \beta_{23}[ \text{Screen} = \text{8inch}] + \beta_{31}[ \text{Storage} = \text{128gb}] + \beta_{32}[ \text{Storage} = \text{64gb}] + \beta_{33}[ \text{Storage} = \text{32gb}] + \beta_{41}[ \text{RAM} = \text{4gb}] + \beta_{42}[ \text{RAM} = \text{2gb}] + \beta_{51}[ \text{Battery} = \text{9h}] + \beta_{52}[ \text{Battery} = \text{8h}] + \beta_6 \text{Price}
$$

其中，$ U_j = V_j + error $ 。也就是说，有 15 个参数 $ \beta $ 需要估计。  

假设独立的极值误差分布，消费者以概率从三个备选方案中选择备选方案 j。  
$$
p_j = \frac{\exp(V_j)}{\sum_{k=1}^{3} \exp(V_k)}, \quad \text{for } j \in \{1,2,3\}
$$

显然，$ p_1 + p_2 + p_3 = 1 $
我们实际估计模型。  
```
> model<-mlogit(Choice ~ 0+Brand+Size+Storage+Ram+Battery+Price, data=cbc.mlogit) 

> kable(summary(model)$CoefTable)


|               |   Estimate| Std. Error|    z-value| Pr(>&#124;z&#124;)|
|:--------------|----------:|----------:|----------:|------------------:|
|BrandGalaxy    |  0.3378857|  0.0925056|   3.652596|          0.0002596|
|BrandiPad      |  0.9780287|  0.0937336|  10.434136|          0.0000000|
|BrandKindle    |  0.2630105|  0.0996254|   2.639995|          0.0082907|
|BrandSurface   |  0.1450365|  0.0938521|   1.545373|          0.1222560|
|Sizesz10inch   |  0.3240632|  0.0841953|   3.848949|          0.0001186|
|Sizesz8inch    |  0.1890775|  0.0829232|   2.280151|          0.0225987|
|Sizesz9inch    |  0.4355415|  0.0808408|   5.387644|          0.0000001|
|Storagest128gb |  0.5897703|  0.0870533|   6.774822|          0.0000000|
|Storagest32gb  |  0.2168719|  0.0829213|   2.615395|          0.0089124|
|Storagest64gb  |  0.5782183|  0.0808259|   7.153877|          0.0000000|
|Ramr2gb        |  0.3189348|  0.0672579|   4.741970|          0.0000021|
|Ramr4gb        |  0.6357438|  0.0645225|   9.853053|          0.0000000|
|Batteryb8h     |  0.1299599|  0.0651501|   1.994777|          0.0460672|
|Batteryb9h     |  0.1253824|  0.0650588|   1.927216|          0.0539528|
|Price          | -0.0050888|  0.0002752| -18.488626|          0.0000000|
```

### Meaning of parameters

在估计后，我们得到了每个离散属性的每个水平（除了参考水平）的系数估计。这样的系数捕获了与参考相比属性水平的相对效用或部分价值。例如，在品牌属性的情况下，品牌iPad系数给出了iPad相对于Nexus（参考品牌）的品牌相对效用的估计。  

正号告诉我们，平均而言，客户更喜欢iPad而不是Nexus，因为较大的估计表示更强的偏好，所以我们可以看到客户非常喜欢64GB存储（相对于基本水平，即16GB）。这些参数估计值是在logit刻度上的。  

在连续价格的情况下，我们得到一个单一的系数，它捕捉到当价格增加一单位（$1）时备选方案的效用如何变化，同时保持备选方案的所有其他特征不变。 

### Model fit 

有人可能会想知道偏好是否仅受品牌效应驱动。我们可以估计一个只有品牌作为预测变量的模型。
```
> model.constraint <-mlogit(Choice ~ 0+Brand, data = cbc.mlogit)
```

> mlogit()
用于拟合多项 Logit 模型。多项 Logit 模型是一种用于处理多分类问题的统计模型，通常用于解释和预测个体选择不同类别的概率。  
然后我们可以使用 lrtest 来比较这两个模型。
```
> lrtest(model, model.constraint)
Likelihood ratio test

Model 1: Choice ~ 0 + Brand + Size + Storage + Ram + Battery + Price
Model 2: Choice ~ 0 + Brand
  #Df  LogLik  Df  Chisq Pr(>Chisq)    
1  15 -1938.9                          
2   4 -2218.0 -11 558.29  < 2.2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

> lrtest()
用于进行两个线性回归模型之间的 Likelihood Ratio Test（似然比检验）。Likelihood Ratio Test 用于比较两个具有不同复杂度的模型是否在解释数据方面有显著的差异。

## Interpreting Conjoint Analysis Findings

通常很难直接解释选择模型的部分效用估计。系数处于一个不熟悉的尺度上（即log），它们衡量了各个水平的相对偏好，这使得它们很难理解。因此，大多数选择模型偏好专注于使用模型进行选择份额预测或计算每个属性的支付意愿，而不是呈现系数。

### Predicted Market Share
我们还可以使用估计的参数来预测数据中不同备选方案的选择概率。在这里，我们打印出数据中前六个选择集的预测。
```
> kable(head(predict(model,cbc.mlogit)))

|         1|         2|         3|
|---------:|---------:|---------:|
| 0.3717263| 0.4405521| 0.1877216|
| 0.2367797| 0.4718620| 0.2913583|
| 0.4760867| 0.2974319| 0.2264814|
| 0.3730366| 0.4456505| 0.1813129|
| 0.3984632| 0.1618560| 0.4396807|
| 0.3791075| 0.2506170| 0.3702755|
```

现在，我们可以测量整个数据集中预测的准确性。

```
> predicted_alternative <- apply(predict(model,cbc.mlogit),1,which.max) 

> selected_alternative <- cbc.mlogit$AlternativeIdInSet[cbc.mlogit$Choice>0] 

> confusionMatrix(table(predicted_alternative,selected_alternative),positive = "1")
Confusion Matrix and Statistics

                     selected_alternative
predicted_alternative   1   2   3
                    1 362 158 130
                    2 164 449 149
                    3 136 160 347

Overall Statistics
                                          
               Accuracy : 0.5635          
                 95% CI : (0.5417, 0.5851)
    No Information Rate : 0.3732          
    P-Value [Acc > NIR] : <2e-16          
                                          
                  Kappa : 0.343           
                                          
 Mcnemar's Test P-Value : 0.8875          

Statistics by Class:

                     Class: 1 Class: 2 Class: 3
Sensitivity            0.5468   0.5854   0.5543
Specificity            0.7933   0.7570   0.7929
Pos Pred Value         0.5569   0.5892   0.5397
Neg Pred Value         0.7865   0.7541   0.8024
Prevalence             0.3221   0.3732   0.3046
Detection Rate         0.1762   0.2185   0.1689
Detection Prevalence   0.3163   0.3708   0.3129
Balanced Accuracy      0.6700   0.6712   0.6736
```

请注意，如果预测是随机的，准确率将为33.3%（对于三个备选方案）。我们的简单模型比这要好得多，尽管它并不完美。

### Conjoint simulator 

现在，让我们看看如何使用模型参数场景来预测在假设市场条件下任意一组产品的市场份额。

```
> predict.share <- function(model, d) {
+   temp <- model.matrix(update(model$formula, 0 ~ .), data = d)[,-1] # generate dummy matri 
+   u <- temp%*% .... [TRUNCATED] 

> # hypothetical base market structure with 4 alternatives in the market
> d.base <- cbc.df[c(44,34,33,40),c("Brand","Size","Storage","Ram", "Battery" .... [TRUNCATED] 

> d.base <- cbind(d.base,as.vector(predict.share(model,d.base)))

> colnames(d.base)[7] <- "Predicted.Share" 

> rownames(d.base) <- c()

> kable(d.base)


|Brand   |Size     |Storage |Ram  |Battery | Price| Predicted.Share|
|:-------|:--------|:-------|:----|:-------|-----:|---------------:|
|iPad    |sz7inch  |st64gb  |r2gb |b8h     |   399|       0.3423928|
|Galaxy  |sz10inch |st32gb  |r2gb |b7h     |   299|       0.2540301|
|Surface |sz10inch |st64gb  |r1gb |b7h     |   399|       0.1313854|
|Kindle  |sz7inch  |st32gb  |r1gb |b9h     |   169|       0.2721917|
```

```
> # hypothetical market structure after Galaxy gets a RAM upgrade
> d.new <- d.base

> d.new[2, 'Ram'] <- "r4gb"

> d.new$Predicted.Share <- as.vector(predict.share(model,d.new)) 

> kable(d.new)


|Brand   |Size     |Storage |Ram  |Battery | Price| Predicted.Share|
|:-------|:--------|:-------|:----|:-------|-----:|---------------:|
|iPad    |sz7inch  |st64gb  |r2gb |b8h     |   399|       0.3127768|
|Galaxy  |sz10inch |st32gb  |r4gb |b7h     |   299|       0.3185544|
|Surface |sz10inch |st64gb  |r1gb |b7h     |   399|       0.1200209|
|Kindle  |sz7inch  |st32gb  |r1gb |b9h     |   169|       0.2486479|
```

### Willingness to pay

非常重要的是，使用参数估计，我们通过除以该属性的系数来为所选属性水平估计，换句话说，我们估计价格的变化将导致由于问题属性水平变化而引起的效用变化的等价物。例如，我们发现，普通消费者在选择是否购买 Galaxy 和支付额外 $125.8 之间处于中立状态，或者购买 iPad。换句话说，普通消费者愿意支付高达 $125.8 来获取 iPad 而不是 Nexus，同时保持所有其他特征不变。

#### 4.3.1 What is the brand value of iPad relative to Galaxy?
品牌资产 - 从 Galaxy 升级到 iPad 的美元价值

```
> (coef(model)["BrandiPad"]-coef(model)["BrandGalaxy"]) / (-coef(model)["Price"])
BrandiPad 
 125.7944 
```

> coef()

提取模型系数的函数，可以用于提取线性回归、逻辑回归、多项式回归等模型的系数。

#### Willingness to Pay for an Attribute Upgrade
从 1GB 升级到 4GB RAM 的美元价值（1GB 是参考水平。因此其系数为0）。

```
> coef(model)["Sizesz9inch"] / (-coef(model)["Price"])
Sizesz9inch 
    85.5882
```

## Code

```
library("xtable") # processing of regression output 
library("knitr") # used for report compilation and table display 
library("ggplot2") # very popular plotting library ggplot2 
library("mlogit") # multinomial logit
library("caret") # ConfusionMatrix

## 获取当前已加载文件的目录
file_dir <- dirname(parent.frame(2)$ofile)
print(file_dir)
## 将工作目录设置为当前已加载文件的目录
setwd(file_dir)

cbc.df<-read.csv("Data_Conjoint_Choice.csv", stringsAsFactors = TRUE) 
str(cbc.df)
head(cbc.df)

summary(cbc.df)

xtabs(Choice~Price, data=cbc.df)

xtabs(Choice~Size, data=cbc.df)

cbc.df$Brand <- relevel(cbc.df$Brand, ref = "Nexus") 
cbc.df$Size <- relevel(cbc.df$Size, ref = "sz7inch") 
cbc.df$Storage <- relevel(cbc.df$Storage, ref = "st16gb") 
cbc.df$Ram <- relevel(cbc.df$Ram, ref = "r1gb") 
cbc.df$Battery <- relevel(cbc.df$Battery, ref = "b7h")

library(dfidx) #install if needed 
cbc.mlogit <- dfidx(cbc.df, choice="Choice", idx=list(c("ChoiceSetId", "ConsumerId"), "AlternativeIdInSet"))

model<-mlogit(Choice ~ 0+Brand+Size+Storage+Ram+Battery+Price, data=cbc.mlogit) 
kable(summary(model)$CoefTable)

model.constraint <-mlogit(Choice ~ 0+Brand, data = cbc.mlogit)

lrtest(model, model.constraint)

kable(head(predict(model,cbc.mlogit)))

predicted_alternative <- apply(predict(model,cbc.mlogit),1,which.max) 
selected_alternative <- cbc.mlogit$AlternativeIdInSet[cbc.mlogit$Choice>0] 
confusionMatrix(table(predicted_alternative,selected_alternative),positive = "1")

predict.share <- function(model, d) {
  temp <- model.matrix(update(model$formula, 0 ~ .), data = d)[,-1] # generate dummy matri 
  u <- temp%*%model$coef[colnames(temp)] # calculate utilities; %*% is matrix multiplicati 
  probs <- t(exp(u)/sum(exp(u))) # calculate probabilities
  colnames(probs) <- paste("alternative", colnames(probs))
  return(probs)
}
## hypothetical base market structure with 4 alternatives in the market
d.base <- cbc.df[c(44,34,33,40),c("Brand","Size","Storage","Ram", "Battery","Price")] 
d.base <- cbind(d.base,as.vector(predict.share(model,d.base)))
colnames(d.base)[7] <- "Predicted.Share" 
rownames(d.base) <- c()
kable(d.base)

## hypothetical market structure after Galaxy gets a RAM upgrade
d.new <- d.base
d.new[2, 'Ram'] <- "r4gb"
d.new$Predicted.Share <- as.vector(predict.share(model,d.new)) 
kable(d.new)

(coef(model)["BrandiPad"]-coef(model)["BrandGalaxy"]) / (-coef(model)["Price"])


coef(model)["Sizesz9inch"] / (-coef(model)["Price"])
```
