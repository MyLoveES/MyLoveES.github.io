title: R[week7] Managing Sustainable Competitive Advantage lecture II
date: 2024-03-29
tags: [R-Language]
categories: R-Language
math: true
toc: true
---

> R: 4.3.2 (2023-10-31)
> R studio: 2023.12.1+402 (2023.12.1+402)

# 一、Market Basket Analysis  
市场购物篮分析   

```
在市场营销领域常用的数据分析技术，也被称为关联规则分析或者关联分析。它的主要目标是发现产品或服务之间的相关性，即顾客在购买某一项产品或服务的同时，往往也会购买另一项产品或服务。通过分析这些购买行为，市场营销人员可以更好地了解顾客的购买偏好和行为模式，从而制定更加精准的营销策略。

市场购物篮分析的基本原理是利用关联规则来描述不同产品或服务之间的关系。关联规则通常采用“如果...那么...”的形式，其中一个项目集合（或称为项集）的出现被认为是另一个项目集合的充分条件。例如，“如果顾客购买了洗发水，那么他们也有可能购买护发素”。

在R语言中，你可以使用一些包如"arules"来进行市场购物篮分析。这些包提供了一系列函数来发现频繁项集（即经常同时出现的产品组合）以及关联规则。通过分析这些规则，你可以洞察顾客的购买行为模式，并据此进行更有针对性的营销活动。
```

• 市场购物篮分析，又称亲和性分析，根据它们在数据集中的共同出现，揭示不同实体之间的有意义的相关性。
• 它生成满足预定义标准的关联规则，以识别频繁项目集中最重要的关系，并帮助揭示大数据中的隐藏模式。

## 1.1 Benefits of Market Basket Analysis

• When you understand product relationships and purchase sequences, you can identify and track
customers who have bought a given product and deliver tailored messages to them.
• With personalization, you’re also able to create more effective marketing campaigns.

```
当您了解产品关系和购买顺序时，您可以识别和跟踪购买特定产品的客户，并向他们发送定制的消息。
通过个性化，您还能够创建更有效的营销活动。
```

• Market basket analysis might tell a retailer that customers often purchase shampoo and conditioner together, so putting both items on promotion at the same time would not create a significant increase in revenue, while a promotion involving just one of the items would likely drive sales of the other.

```
市场购物篮分析可能告诉零售商，顾客经常一起购买洗发水和护发素，因此同时促销这两种商品不会显著增加收入，而仅促销其中一种商品可能会推动另一种商品的销售。
```

• Inventory management
```
库存管理, 存储适量的相关产品
```

• Refine marketing
```
优化营销，根据客户间的亲和关系来定位市场细分
```

# 二、Key terms


一个项目集是由形成关联规则的所有项目的列表表示。  
一个关联规则，{面包，鸡蛋} => {牛奶}，或更普遍的 {X} => {Y}，表明如果顾客一起购买面包和鸡蛋，他们很可能也会购买牛奶。

• Support is a measure of absolute frequency.  
```
25% 的支持度表示在所有交易中，面包、鸡蛋和牛奶一起购买的频率为 25%。
```
• Confidence is a measure of correlative frequency.
```
60% 的置信度表示购买了面包和鸡蛋的人中，有 60% 也购买了牛奶。
```
• Lift is a measure of the strength of association between the products on the left and right hand
side of the rule.
```
提升度是左侧和右侧规则中产品之间关联强度的度量。

规则中所有项目一起出现的概率除以左侧和右侧项目单独出现的概率的乘积，就得到了提升度。
例如，如果面包、鸡蛋和牛奶一起出现在所有交易的 2.5% 中，面包和鸡蛋一起出现在 10% 的交易中，牛奶在 8% 的交易中出现，那么提升度将为：0.025/(0.1*0.08) = 3.125。
提升度越大，两个产品之间的联系越紧密。提升度大于1表示面包和鸡蛋的存在增加了牛奶也出现在交易中的概率。
```

• Association Rule: {X → Y} is a representation of finding Y on the basket which has X on it  
• Itemset: {X,Y} is a representation of the list of all items which form the association rule  
• Support: Fraction of transactions containing the itemset  
• Confidence: Probability of occurrence of {Y} given {X} is present  
• Lift: Ratio of confidence to baseline probability of occurrence of {Y}  

```
• 关联规则：{X → Y} 表示在包含 X 的购物篮中找到 Y 的表示。
• 项目集：{X,Y} 是形成关联规则的所有项目的列表表示。
• 支持度：包含该项目集的交易的比例。
• 置信度：在 {X} 存在的情况下 {Y} 发生的概率。
• 提升度：置信度与 {Y} 基线发生概率的比值。
```

{% asset_image R_week7_schemas.png %}

