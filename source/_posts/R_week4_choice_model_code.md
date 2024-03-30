title: R[week4] Choice model
date: 2024-03-24
tags: [R-Language]
categories: R-Language
math: true
toc: true
---

> R: 4.3.2 (2023-10-31)
> R studio: 2023.12.1+402 (2023.12.1+402)

Marketers often observe yes/no outcomes:  
• Did a customer purchase a product?  
• Did a customer take a test drive?  
• Did a customer sign up for a credit card, renew her subscription, or respond to a promotion?  
All of these kinds of outcomes are binary because they have only two possible overserved states: yes or no. A logistic model is used to fit such outcomes.  

** 这些类型的结果都是二元的，因为它们只有两种可能的观察状态：是或否。 logistic模型被用来拟合这样的结果。**

# 1. Basics of logistic regression

The core feature of a logistic model is that it relates the probability of an outcome to an exponential function of a predictor variable.  
By modelling the probability of an outcome, a logistic model accomplishes two things:  
• First, it more directly models what we are interested in, which is a probability or proportion, such as the likelihood of a given customer to purchase a product or the expected proportion of a segment who will respond to a promotion.  
• Second, it limits the model to the appropriate range for a proportion, which is [0, 1]. A basic linear model, as generated with lm(), does not have such a limit. The equation for the logistic function is:  

$$
p(y) = \frac{e^{v_x}}{e^{v_x} + 1}
$$


Logistic模型的核心特征是它将结果的概率与预测变量的指数函数相关联。  
通过对结果的概率建模，logistic模型实现了两个目标。  
• 首先，它更直接地对我们感兴趣的内容进行建模，即概率或比例，例如给定客户购买产品的可能性或将对促销活动做出回应的细分预期比例。  
• 其次，它将模型限制在比例的适当范围内，即[0,1]。基本的线性模型，如lm()生成的模型，没有这样的限制。  

In this equation, the outcome of interest is y, and we compute its likelihood p(y) as a function of vx. We typically estimate vx as a function of the features (x) of a product, such as price. vx can take any real value, so we are able to treat it as a continuous function in a linear model. In that case, vx is composed of one or more coefficients of the model and indicates the importance of the corresponding features of the product.   

在这个方程中，我们感兴趣的结果是y，我们计算其概率p(y)作为vx的函数。我们通常将vx估计为产品特征（x）的函数，例如价格。vx可以取任何实数值，因此我们可以将其视为线性模型中的连续函数。在这种情况下，vx由模型的一个或多个系数组成，并指示产品相应特征的重要性。  

The formula gives a value between [0, 1]. The likelihood of y is less than 50% when vx is negative, is 50% when vx = 0 and is above 50% when vx is positive. We compute this first by hand and then switch to the equivalent plogis() function:  

这个公式给出了一个在[0, 1]之间的值。当vx为负时，y的概率小于50％，当vx = 0时，概率为50％，当vx为正时，概率大于50％。我们首先手工计算这个值，然后切换到等效的plogis()函数：  

```
> exp(0) / exp(0)+1 # computing logistic by hand, or using plogis()
\[ P(Purchase_i) = \frac{exp(\beta_0 + \beta_1 \text{Recency}_i + \beta_2 \text{Frequency}_i + \beta_3 \text{Monetary}_i)}{exp(\beta_0 + \beta_1 \text{Recency}_i + \beta_2 \text{Frequency}_i + \beta_3 \text{Monetary}_i) + 1} \]
[1] 2

# plogis参数其实就是p(y)

> plogis(-Inf) #infinitely low = likelihood 0
[1] 0

> plogis(2) #moderate probability = 88% chance of outcome
[1] 0.8807971

> plogis(-0.2) # weak likelihood
[1] 0.450166
```
Such a model is known as a logit model, which determines the value of vx from the logarithm of the relative probability of occurence of y:  

$$
v_x = \log \left( \frac{p(y)}{1 - p(y)} \right)
$$

```
> log(0.88 / (1-0.88)) # moderate high likelihood
[1] 1.99243

> qlogis(0.88) # equivalent to hand computation
[1] 1.99243
```

# 2. Generalised linear model (GLM)

A logistic regression model in R is fitted as a generalised linear model (GLM) using a process similar to linear regression with lm(), but with the difference that a GLM can handle dependent variables that are not normally distributed. Thus, GLM can be used to model data counts (such as the number of purchases), time intervals (such as time spent on a website), or binary variables (e.g., did/didn’t purchase). The common feature of all GLM models is that they relate normally distributed predictors to a non-normal outcome using a function known as a link. This means that they are able to fit models for many different distributions using a single, consistent framework.  

在R中，逻辑回归模型是作为广义线性模型（GLM）进行拟合的，使用的过程类似于使用lm()进行线性回归，但不同之处在于GLM可以处理不符合正态分布的因变量。因此，GLM可用于对数据计数（例如购买次数）、时间间隔（例如在网站上的停留时间）或二元变量（例如是否购买）建模。所有GLM模型的共同特点是它们将正态分布的预测变量与一个非正态的结果相关联，使用的函数称为链接函数。这意味着它们能够使用单一、一致的框架拟合许多不同分布的模型。  

<div style="background-color:#f0f0f0; padding:10px;">
广义线性模型（Generalized Linear Model，GLM）是一种广泛应用于统计分析中的模型，它将线性模型扩展到了更广泛的数据类型和分布。GLM可以处理不同类型的响应变量，包括二项分布、泊松分布、正态分布等，并且可以处理不同的链接函数，如恒等函数、对数函数、逻辑斯蒂函数等。  

GLM的基本形式如下：  

1. 线性部分：$$ \eta = \beta_0 + \beta_1 x_1 + \beta_2 x_2 + \ldots + \beta_p x_p $$

   这部分与多元线性回归模型相似，其中 $$ \eta $$ 是线性预测值，$$ \beta_0, \beta_1, \ldots, \beta_p $$ 是系数，$$ x_1, x_2, \ldots, x_p $$ 是预测变量。

2. 链接函数：$$ g(\mu) = \eta $$

   这里的 $$ g(\cdot) $$ 是链接函数，它定义了预测变量 $$ \eta $$ 与响应变量 $$ \mu $$ 之间的关系。链接函数通常根据响应变量的类型选择，如对数链接函数用于处理泊松分布的响应变量，逻辑斯蒂链接函数用于处理二项分布的响应变量等。

3. 分布族：$$ Y \sim \text{Dist}(\mu) $$

   这里的 $$ \text{Dist}(\mu) $$ 表示响应变量 $$ Y $$ 的分布族，$$ \mu $$ 是响应变量的均值。

GLM的优势在于它的灵活性和适用性，可以适应不同类型和分布的数据，同时保持了对参数的解释性。它在许多领域都得到了广泛应用，包括生物统计学、医学、社会科学等。

</div>

# 3. RFM (recency, frequency, monetary)

RFM is a method used for analyzing customer value. RFM stands for the three dimensions: Recency: How recently did the customer purchase? Frequency: How often do they purchase? Monetary Value: How much do they spend?  

RFM是用于分析客户价值的一种方法。RFM代表三个维度：Recency（最近购买时间）：客户最近一次购买是在多久之前？Frequency（购买频率）：他们购买的频率如何？Monetary Value（购买金额）：他们的消费金额是多少？  

## 3.1 The Logit Model
The logit model restricts the output values to lie in [0, 1] intervals.  
Specifically, it expresses the probability of purchase by customer i as a function of coefficients β0:3 and variables in the following manner:  

逻辑斯蒂模型将输出值限制在[0, 1]的区间内。
具体而言，它将客户i的购买概率表达为系数β0:3和以下变量的函数：  

$$
P(Purchase_i) = \frac{exp(\beta_0 + \beta_1 \text{Recency}_i + \beta_2 \text{Frequency}_i + \beta_3 \text{Monetary}_i)}{exp(\beta_0 + \beta_1 \text{Recency}_i + \beta_2 \text{Frequency}_i + \beta_3 \text{Monetary}_i) + 1}
$$

<div style="background-color:#f0f0f0; padding:10px;">
这个公式是一个逻辑回归模型中用于计算购买概率的方程。在这个方程中：

- $$ P(Purchase_i) $$ 表示第 $$ i $$ 个个体购买的概率。
- $$ \beta_0, \beta_1, \beta_2, \beta_3 $$ 是模型的参数，分别表示截距和与每个预测变量（Recency、Frequency、Monetary）相关的系数。
- $$ \text{Recency}_i, \text{Frequency}_i, \text{Monetary}_i $$ 是第 $$ i $$ 个个体的预测变量值，分别表示最近一次购买距离、购买频率和购买金额。

公式的分子部分表示了一个线性组合（$$ \beta_0 + \beta_1 \text{Recency}_i + \beta_2 \text{Frequency}_i + \beta_3 \text{Monetary}_i $$）的指数形式，即指数函数 $$ \text{exp}(\ldots) $$ ，代表了购买的可能性。

分母部分是分子部分加上1，这是由于逻辑回归模型的形式，保证了概率值在0和1之间。整个方程实际上是逻辑回归模型的逻辑函数（logistic function），它将线性预测值转换为0到1之间的概率值，这表示个体购买的概率。

</div>

Intuitively, the utility of choosing to buy is:  

$$ V_{bi} = \beta_0 + \beta_1 \text{Recency}_i + \beta_2 \text{Frequency}_i + \beta_3 \text{Monetary}_i $$

<div style="background-color:#f0f0f0; padding:10px;">

这个公式表示了一个线性模型，用于预测个体 $ i $ 的 $ V $ 值。在这个公式中：

- $$ V_{bi} $$ 表示个体 $$ i $$ 的 $$ V $$ 值。
- $$ \beta_0, \beta_1, \beta_2, \beta_3 $$ 是模型的参数，分别表示截距和与每个预测变量（Recency、Frequency、Monetary）相关的系数。
- $$ \text{Recency}_i, \text{Frequency}_i, \text{Monetary}_i $$ 是第 $$ i $$ 个个体的预测变量值，分别表示最近一次购买距离、购买频率和购买金额。

这个模型的目的是通过个体的购买行为的相关特征（Recency、Frequency、Monetary）来预测他们的 $$ V $$ 值。这个 $$ V $$ 值可能表示个体的潜在价值或其他相关的指标。  

whereas utility of choosing not to buy is normalized to zero $$ V_ni = 0 $$, so $$ exp(V_n) = exp(0) = 1 $$ in the fraction above.  
With the given formulation, we can estimate values $$ \beta_0:3 $$ that fit the data best. We use glm() of family=“binomial”.  

选择不购买的效用被归一化为零，即 Vni = 0，因此在上述分数中 exp(Vn) = exp(0) = 1。  
通过给定的公式，我们可以估计最适合数据的 β0:3 值。我们使用 glm() 中的 family="binomial"。  



</div>

```
> RFMdata <- read.csv(file = "RFMData.csv",row.names=1) 

> head(RFMdata,5)
  Recency Frequency Monetary Purchase
1     120         7    41.66        0
2      90         9    46.71        0
3     120         6   103.99        1
4     270        17    37.13        1
5      60         5    88.92        0

> model <- glm(Purchase~Recency+Frequency+Monetary, data=RFMdata, family = "binomial") 

> output <- cbind(coef(summary(model))[, 1:4],exp(coef(model)))

> colnames(output) <- c("beta","SE","z val.","Pr(>|z|)",'exp(beta)') 

> kable(output,caption = "Logistic regression estimates")


Table: Logistic regression estimates

|            |        beta|        SE|    z val.| Pr(>&#124;z&#124;)| exp(beta)|
|:-----------|-----------:|---------:|---------:|------------------:|---------:|
|(Intercept) | -30.2976692| 8.5522913| -3.542638|          0.0003961|  0.000000|
|Recency     |   0.1114175| 0.0309797|  3.596464|          0.0003226|  1.117862|
|Frequency   |   0.5941268| 0.2429393|  2.445577|          0.0144620|  1.811448|
|Monetary    |   0.1677054| 0.0465645|  3.601572|          0.0003163|  1.182588|
```


