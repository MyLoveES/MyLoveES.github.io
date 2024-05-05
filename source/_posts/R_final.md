title: R[final] Final
date: 2024-04-05
tags: [R-Language]
categories: R-Language
math: true
toc: true
---

> R: 4.3.2 (2023-10-31)  
> R studio: 2023.12.1+402 (2023.12.1+402)

# 1. Manage customer hierarchical

## 1.1 segmentation



### 1.1.1 import and check data
```
> seg.df <- read.csv("1_demographics.csv", stringsAsFactors = TRUE)
> head(seg.df, n = 5)
  Consumer_id Age_Group Gender Salary Education Employment Location_by_region Choco_Consumption
1         352         1      2      1         2          3                  4                 0
2         103         3      2      3         1          1                  1                 1
3          17         1      1      1         1          4                  1                 1
4          66         1      1      1         1          3                  1                 1
5         329         2      1      1         1          8                  1                 1
  Sustainability_Score
1             -1.15059
2              0.50287
3             -1.14517
4             -0.46688
5             -2.08817
> summary(seg.df, digits = 2)
  Consumer_id    Age_Group       Gender        Salary      Education     Employment   Location_by_region
 Min.   :  1   Min.   :1.0   Min.   :1.0   Min.   :0.0   Min.   :1.0   Min.   : 1.0   Min.   :1.0       
 1st Qu.: 95   1st Qu.:1.0   1st Qu.:1.0   1st Qu.:1.0   1st Qu.:2.0   1st Qu.: 1.0   1st Qu.:1.0       
 Median :190   Median :2.0   Median :2.0   Median :2.0   Median :2.0   Median : 2.0   Median :1.0       
 Mean   :190   Mean   :2.2   Mean   :1.7   Mean   :2.3   Mean   :2.3   Mean   : 2.4   Mean   :1.3       
 3rd Qu.:284   3rd Qu.:3.0   3rd Qu.:2.0   3rd Qu.:3.0   3rd Qu.:3.0   3rd Qu.: 3.0   3rd Qu.:1.0       
 Max.   :378   Max.   :4.0   Max.   :2.0   Max.   :7.0   Max.   :4.0   Max.   :10.0   Max.   :8.0       
 Choco_Consumption Sustainability_Score
 Min.   :0         Min.   :-3.26       
 1st Qu.:2         1st Qu.:-0.61       
 Median :3         Median : 0.14       
 Mean   :3         Mean   : 0.00       
 3rd Qu.:4         3rd Qu.: 0.68       
 Max.   :5         Max.   : 2.04       
> 
> ### 1.1.1 remove consumer_id in data set, and set consumer_id as row name
> rownames(seg.df) <- seg.df[, 1]
> seg.df <- seg.df[, -1]
> #### remove salary = 7, invalid data
> seg.df <- seg.df[seg.df$Salary != 7, ]
> #### remove Employment, which related to Salary
> seg.df <- subset(seg.df, select = -Employment)
> #### just split region to 3 groups
> seg.df$Location_by_region[seg.df$Location_by_region > 2] <- 3
```
    
```
hist(seg.df$Sustainability_Score,
     main = "All customers", 
     xlab = "Sustainability_Score",
     ylab = "Count",
     col = "lightblue" # colore the bars
)
```
{% asset_image final_1.png %}

```
hist(seg.df$Choco_Consumption,
     main = "All customers", 
     xlab = "Choco_Consumption",
     ylab = "Count",
     col = "lightblue" # colore the bars
)
```
{% asset_image final_2.png %}

```
> head(seg.df, n = 5)
    Age_Group Gender Salary Education Location_by_region Choco_Consumption Sustainability_Score
352         1      2      1         2                  3                 0             -1.15059
103         3      2      3         1                  1                 1              0.50287
17          1      1      1         1                  1                 1             -1.14517
66          1      1      1         1                  1                 1             -0.46688
329         2      1      1         1                  1                 1             -2.08817
> summary(seg.df, digits = 2)
   Age_Group       Gender        Salary      Education   Location_by_region Choco_Consumption
 Min.   :1.0   Min.   :1.0   Min.   :0.0   Min.   :1.0   Min.   :1.0        Min.   :0        
 1st Qu.:1.0   1st Qu.:1.0   1st Qu.:1.0   1st Qu.:2.0   1st Qu.:1.0        1st Qu.:2        
 Median :2.0   Median :2.0   Median :2.0   Median :2.0   Median :1.0        Median :3        
 Mean   :2.1   Mean   :1.7   Mean   :2.2   Mean   :2.3   Mean   :1.2        Mean   :3        
 3rd Qu.:3.0   3rd Qu.:2.0   3rd Qu.:3.0   3rd Qu.:3.0   3rd Qu.:1.0        3rd Qu.:4        
 Max.   :4.0   Max.   :2.0   Max.   :6.0   Max.   :4.0   Max.   :3.0        Max.   :5        
 Sustainability_Score
 Min.   :-3.3e+00    
 1st Qu.:-6.1e-01    
 Median : 1.4e-01    
 Mean   :-9.6e-05    
 3rd Qu.: 6.8e-01    
 Max.   : 2.0e+00    
> str(seg.df)
'data.frame':	373 obs. of  7 variables:
 $ Age_Group           : int  1 3 1 1 2 4 2 1 1 1 ...
 $ Gender              : int  2 2 1 1 1 1 2 2 1 1 ...
 $ Salary              : int  1 3 1 1 1 4 2 3 3 3 ...
 $ Education           : int  2 1 1 1 1 1 1 2 2 2 ...
 $ Location_by_region  : num  3 1 1 1 1 1 1 1 1 1 ...
 $ Choco_Consumption   : int  0 1 1 1 1 1 1 1 1 1 ...
 $ Sustainability_Score: num  -1.151 0.503 -1.145 -0.467 -2.088 ...

> seg.df.sc <- seg.df
> #### just scale continous variables
> seg.df.sc[, c(6,7)] <- scale(seg.df[ , c(6,7)])
> #### factor ordered ordinals
> seg.df.sc$Age_Group <- factor(seg.df.sc$Age_Group, ordered = TRUE)
> seg.df.sc$Salary <- factor(seg.df.sc$Salary, ordered = TRUE)
> seg.df.sc$Education <- factor(seg.df.sc$Education, ordered = TRUE)
> seg.df.sc$Gender <- factor(seg.df.sc$Gender, ordered = FALSE)
> seg.df.sc$Location_by_region <- factor(seg.df.sc$Location_by_region, ordered = FALSE)
> head(seg.df.sc, n = 5)
    Age_Group Gender Salary Education Location_by_region Choco_Consumption Sustainability_Score
352         1      2      1         2                  3         -2.449983           -1.1457402
103         3      2      3         1                  1         -1.627442            0.5008876
17          1      1      1         1                  1         -1.627442           -1.1403426
66          1      1      1         1                  1         -1.627442           -0.4648553
329         2      1      1         1                  1         -1.627442           -2.0794461
> summary(seg.df.sc, digits = 2)
 Age_Group Gender  Salary  Education Location_by_region Choco_Consumption Sustainability_Score
 1:140     1:119   0: 34   1: 76     1:299              Min.   :-2.450    Min.   :-3.25       
 2:120     2:254   1:116   2:183     2: 58              1st Qu.:-0.805    1st Qu.:-0.61       
 3: 35             2: 40   3: 43     3: 16              Median : 0.018    Median : 0.14       
 4: 78             3:123   4: 71                        Mean   : 0.000    Mean   : 0.00       
                   4: 41                                3rd Qu.: 0.840    3rd Qu.: 0.68       
                   5: 14                                Max.   : 1.663    Max.   : 2.03       
                   6:  5                                                                      
> str(seg.df.sc)
'data.frame':	373 obs. of  7 variables:
 $ Age_Group           : Ord.factor w/ 4 levels "1"<"2"<"3"<"4": 1 3 1 1 2 4 2 1 1 1 ...
 $ Gender              : Factor w/ 2 levels "1","2": 2 2 1 1 1 1 2 2 1 1 ...
 $ Salary              : Ord.factor w/ 7 levels "0"<"1"<"2"<"3"<..: 2 4 2 2 2 5 3 4 4 4 ...
 $ Education           : Ord.factor w/ 4 levels "1"<"2"<"3"<"4": 2 1 1 1 1 1 1 2 2 2 ...
 $ Location_by_region  : Factor w/ 3 levels "1","2","3": 3 1 1 1 1 1 1 1 1 1 ...
 $ Choco_Consumption   : num  -2.45 -1.63 -1.63 -1.63 -1.63 ...
 $ Sustainability_Score: num  -1.146 0.501 -1.14 -0.465 -2.079 ...
```

### 1.1.2 hclust()
> Considering data contains ordinal varibles and continous variables, use hclust().
```
> ### 1.1.2 Hierarchical clustering: hclust()
> seg.dist <- dist(seg.df.sc)
> # seg.dist <- daisy(seg.df.sc, metric = "gower")
> as.matrix(seg.dist)[1:7, 1:7]
         352      103        17        66      329      241       34
352 0.000000 4.048204 2.5839125 2.6721113 2.923762 4.977689 2.821760
103 4.048204 0.000000 3.4195960 3.1516122 3.557825 2.618749 1.799080
17  2.583913 3.419596 0.0000000 0.6754873 1.371829 4.254911 1.811081
66  2.672111 3.151612 0.6754873 0.0000000 1.899185 4.358532 1.738220
329 2.923762 3.557825 1.3718292 1.8991849 0.000000 3.657826 2.038581
241 4.977689 2.618749 4.2549114 4.3585316 3.657826 0.000000 3.118659
34  2.821760 1.799080 1.8110812 1.7382205 2.038581 3.118659 0.000000
> seg.hc <- hclust(seg.dist, method="complete")
> plot(seg.hc)
```
{% asset_image final_3.png %}
```
> rect.hclust(seg.hc, k=4, border = "red")
```
{% asset_image final_4.png %}
```
> seg.hc.segment <- cutree(seg.hc, k=4) #membership vector for 4 groups 
> table(seg.hc.segment) #counts
seg.hc.segment
  1   2   3   4 
 78 172  88  35 
```
> data size of groups
```
> clusplot(seg.df, seg.hc.segment,
+          color = TRUE, #color the groups
+          shade = TRUE, #shade the ellipses for group membership
+          labels = 4, #label only the groups, not the individual points 
+          lines = 0, #omit distance lines between groups
+          main = "Hierarchical cluster plot" # figure title
+ )
```
{% asset_image final_5.png %}
> Graph split to 4 groups
```
> aggregate(seg.df, list(seg.hc.segment), mean)
  Group.1 Age_Group   Gender   Salary Education Location_by_region Choco_Consumption Sustainability_Score
1       1  1.692308 1.602564 1.756410  2.000000           1.282051          3.333333           -1.1191478
2       2  1.441860 1.686047 1.616279  1.819767           1.377907          2.668605            0.3161955
3       3  3.272727 1.659091 3.818182  2.977273           1.011364          3.397727            0.1015306
4       4  3.685714 1.885714 2.228571  3.542857           1.057143          2.657143            0.6839269
```
> Well-differentiated: Salary(Group3)、Education(Group4)、Choco_Consumption(Group1、Group3)
```
> boxplot(seg.df$Salary ~ seg.hc.segment, ylab = "Salary", xlab = "Cluster")
```
{% asset_image final_6.png %}
> Well-differentiated: Salary(Group3)
```
> boxplot(seg.df$Education ~ seg.hc.segment, ylab = "Education", xlab = "Cluster")
```
{% asset_image final_7.png %}
> Well-differentiated: Education(Group4)
```
> boxplot(seg.df$Choco_Consumption ~ seg.hc.segment, ylab = "Choco_Consumption", xlab = "Cluster")
```
{% asset_image final_8.png %}

> Differentiated not welled, ignore

### 1.1.3 Conclusion

| Group. | Age_Group | Gender   | Salary  | Education | Location_by_region | Choco_Consumption | Sustainability_Score |
| ------ | --------- | -------- | ------- | --------- | ------------------ | ----------------- | -------------------- |
| 1      | 1.692308  | 1.602564 | 1.75641 | 2.000000  | 1.282051           | 3.333333          | -1.1191478           |
| 2      | 1.441860  | 1.686047 | 1.61628 | 1.819767  | 1.377907           | 2.668605          | 0.3161955            |
| 3      | 3.272727  | 1.659091 | 3.81818 | 2.977273  | 1.011364           | 3.397727          | 0.1015306            |
| 4      | 3.685714  | 1.885714 | 2.22857 | 3.542857  | 1.057143           | 2.657143          | 0.6839269            |


Graph split to 4 groups(Only explained 50.93% of the data), we see that group3 is modestly well-differentiated. 88 customers with higher salary, means more potential to pay at a higher price. Second target is group1, high consumption of choco, means greater potential market demand.