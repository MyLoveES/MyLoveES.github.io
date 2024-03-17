title: R[week2] Segmentation Code
date: 2024-03-15
tags: [R-Language]
categories: R-Language
math: true
toc: true
---

> R: 4.3.2 (2023-10-31)  
> R studio: 2023.12.1+402 (2023.12.1+402)

# 1. Segmentation data

• 年龄（age）  
• 性别（gender）  
• 收入（income）  
• 孩子数量（kids）  
• 是否拥有或租赁住房（ownHome）  
• 当前是否订阅所提供的会员服务（subscribe）  

```
> seg.df <- read.csv("Data_Segmentation.csv", stringsAsFactors = TRUE)

> head(seg.df, n=8)

> head(seg.df, n=8)
       age gender   income kids ownHome subscribe
1 47.31613   Male 49482.81    2   ownNo     subNo
2 31.38684   Male 35546.29    1  ownYes     subNo
3 43.20034   Male 44169.19    0  ownYes     subNo
4 37.31700 Female 81041.99    1   ownNo     subNo
5 40.95439 Female 79353.01    3  ownYes     subNo
6 43.03387   Male 58143.36    4  ownYes     subNo
7 37.55696   Male 19282.23    3   ownNo     subNo
8 28.45129   Male 47245.24    0   ownNo     subNo
```

## 1.1 Recode factor into numeric data

```
> seg.df$gender <- ifelse(seg.df$gender=="Male",0,1) 
> seg.df$ownHome <- ifelse(seg.df$ownHome == "ownNo", 0,1) 
> seg.df$subscribe <- ifelse(seg.df$subscribe == "subNo", 0,1)
> head(seg.df)

       age gender   income kids ownHome subscribe
1 47.31613      0 49482.81    2       0         0
2 31.38684      0 35546.29    1       1         0
3 43.20034      0 44169.19    0       1         0
4 37.31700      1 81041.99    1       0         0
5 40.95439      1 79353.01    3       1         0
6 43.03387      0 58143.36    4       1         0
```

## 1.2 Rescaling the data

```
> seg.df.sc <- seg.df

> seg.df.sc[, c(1,3,4)] <- scale(seg.df[, c(1,3,4)])

# We only need to standardize continuous variables.
> head(seg.df.sc)
          age gender     income       kids ownHome subscribe
1  0.48133138      0 -0.0721898  0.5183027       0         0
2 -0.77221071      0 -0.7642562 -0.1917010       1         0
3  0.15744276      0 -0.3360563 -0.9017048       1         0
4 -0.30554218      1  1.4949908 -0.1917010       0         0
5 -0.01930052      1  1.4111190  1.2283065       1         0
6  0.14434200      0  0.3578800  1.9383103       1         0

> summary(seg.df.sc, digits = 2)
      age            gender         income            kids          ownHome       subscribe   
 Min.   :-1.73   Min.   :0.00   Min.   :-2.787   Min.   :-0.90   Min.   :0.00   Min.   :0.00  
 1st Qu.:-0.64   1st Qu.:0.00   1st Qu.:-0.560   1st Qu.:-0.90   1st Qu.:0.00   1st Qu.:0.00  
 Median :-0.13   Median :1.00   Median : 0.054   Median :-0.19   Median :0.00   Median :0.00  
 Mean   : 0.00   Mean   :0.52   Mean   : 0.000   Mean   : 0.00   Mean   :0.47   Mean   :0.13  
 3rd Qu.: 0.53   3rd Qu.:1.00   3rd Qu.: 0.520   3rd Qu.: 0.52   3rd Qu.:1.00   3rd Qu.:0.00  
 Max.   : 3.09   Max.   :1.00   Max.   : 3.145   Max.   : 4.07   Max.   :1.00   Max.   :1.00
```

# 2. Hierarchical clustering: hclust()

## 2.1 Distance

```
> seg.dist <- dist(seg.df.sc) 

> as.matrix(seg.dist)[1:5, 1:5]
         1        2        3        4        5
1 0.000000 1.885319 1.786323 2.139937 2.225970
2 1.885319 0.000000 1.245679 2.705915 2.883670
3 1.786323 1.245679 0.000000 2.463979 2.936121
4 2.139937 2.705915 2.463979 0.000000 1.762212
5 2.225970 2.883670 2.936121 1.762212 0.000000
```

## 2.2 Clustering

```
> seg.hc <- hclust(seg.dist, method="complete") 
> plot(seg.hc)
```

{% asset_image R_week2_cluster_plot.png  %}

```
> plot(cut(as.dendrogram(seg.hc), h = 4)$lower[[1]])
```

{% asset_image R_week2_cluster_plot_2.png  %}

```
> seg.df[c(156, 152),] #similar
         age gender   income kids ownHome subscribe
156 66.89691      0 54060.59    0       1         0
152 64.45890      0 61052.08    0       1         0

> seg.df[c(156, 183),] #less similar
         age gender    income kids ownHome subscribe
156 66.89691      0  54060.59    0       1         0
183 57.79006      1 105537.82    0       1         0
```

## 2.3 Getting groups

```
> plot(seg.hc)

> rect.hclust(seg.hc, k=4, border = "red")
```

{% asset_image R_week2_getting_group_plot.png %}

```
> seg.hc.segment <- cutree(seg.hc, k=4) #membership vector for 4 groups 

> table(seg.hc.segment) #counts
seg.hc.segment
  1   2   3   4 
164  73  30  33
```

# 2.4 Describing clusters

```
library(cluster) 
clusplot(seg.df, seg.hc.segment,
         color = TRUE, #color the 
         lines = 0, #omit distance lines between groups
         main = "Hierarchical cluster plot", # figure title
         groupsshade = TRUE, #shade the ellipses for group membership 
         labels = 4, #label only the groups, not the individual points 
)
```

{% asset_image R_week2_describing_clusters_plot.png %}

```
> aggregate(seg.df, list(seg.hc.segment), mean)
  Group.1      age    gender   income     kids   ownHome  subscribe
1       1 35.70250 0.5121951 45474.72 0.847561 0.3292683 0.15243902
2       2 37.34969 0.5479452 54571.75 3.273973 0.4520548 0.08219178
3       3 57.61221 0.6333333 40589.64 0.100000 0.9333333 0.16666667
4       4 62.11487 0.4242424 79444.84 0.000000 0.7878788 0.12121212
```

```
boxplot(seg.df$income ~ seg.hc.segment, ylab = "Income", xlab = "Cluster")
```

{% asset_image R_week2_describing_clusters_plot_2.png %}


