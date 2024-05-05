# 1. Manage customer hierarchical

## 1.1 segmentation

### 1.1.1 import and check data
```
> # 1. anage customer hierarchical
> 
> ## 1.1 segmentation
> seg.df <- read.csv("1_demographics.csv", stringsAsFactors = TRUE)

> head(seg.df, n = 5)
  Consumer_id Age_Group Gender Salary Education Employment Location_by_region Choco_Consumption Sustainability_Score
1         352         1      2      1         2          3                  4                 0             -1.15059
2       103         3      2      3         1          1                  1                 1              0.50287
3          17         1      1      1         1          4                  1                 1             -1.14517
4          66         1      1      1         1          3                  1                 1             -0.46688
5         329         2      1      1         1          8                  1                 1             -2.08817

> summary(seg.df, digits = 2)
  Consumer_id    Age_Group       Gender        Salary      Education     Employment   Location_by_region Choco_Consumption Sustainability_Score
 Min.   :  1   Min.   :1.0   Min.   :1.0   Min.   :0.0   Min.   :1.0   Min.   : 1.0   Min.   :1.0        Min.   :0         Min.   :-3.26       
 1st Qu.: 95   1st Qu.:1.0   1st Qu.:1.0   1st Qu.:1.0   1st Qu.:2.0   1st Qu.: 1.0   1st Qu.:1.0        1st Qu.:2         1st Qu.:-0.61       
 Median :190   Median :2.0   Median :2.0   Median :2.0   Median :2.0   Median : 2.0   Median :1.0        Median :3         Median : 0.14       
 Mean   :190   Mean   :2.2   Mean   :1.7   Mean   :2.3   Mean   :2.3   Mean   : 2.4   Mean   :1.3        Mean   :3         Mean   : 0.00       
 3rd Qu.:284   3rd Qu.:3.0   3rd Qu.:2.0   3rd Qu.:3.0   3rd Qu.:3.0   3rd Qu.: 3.0   3rd Qu.:1.0        3rd Qu.:4         3rd Qu.: 0.68       
 Max.   :378   Max.   :4.0   Max.   :2.0   Max.   :7.0   Max.   :4.0   Max.   :10.0   Max.   :8.0        Max.   :5         Max.   : 2.04       

> ### 1.1.1 remove consumer_id in data set, and set consumer_id as row name
> rownames(seg.df) <- seg.df[, 1]

> seg.df <- seg.df[, -1]

> head(seg.df, n = 5)
    Age_Group Gender Salary Education Employment Location_by_region Choco_Consumption Sustainability_Score
352         1      2      1         2          3                  4                 0             -1.15059
103         3      2      3         1          1                  1                 1              0.50287
17          1      1      1         1          4                  1                 1             -1.14517
66          1      1      1         1          3                  1                 1             -0.46688
329         2      1      1         1          8                  1                 1             -2.08817

```

### 1.1.2 hclust()

```
> ### 1.1.2 Hierarchical clustering: hclust()
> seg.dist <- dist(seg.df)

> as.matrix(seg.dist)[1:7, 1:7]
         352      103       17       66      329      241       34
352 0.000000 5.072862 3.605555 3.530929 6.235307 5.839662 4.157900
103 5.072862 0.000000 4.551487 3.733687 7.855793 2.624867 1.801936
17  3.605555 4.551487 0.000000 1.208337 4.229568 5.206260 3.504617
66  3.530929 3.733687 1.208337 0.000000 5.350568 4.796362 2.649828
329 6.235307 7.855793 4.229568 5.350568 0.000000 7.898282 7.292032
241 5.839662 2.624867 5.206260 4.796362 7.898282 0.000000 3.119626
34  4.157900 1.801936 3.504617 2.649828 7.292032 3.119626 0.000000

> seg.hc <- hclust(seg.dist, method="complete")

> plot(seg.hc)
```

{% asset_image 1_hierarchical_segmetation_clust_complete.png %}

```
> plot(cut(as.dendrogram(seg.hc), h = 4)$lower[[1]])
```

{% asset_image 1_hierarchical_segmetation_clust_cut.png %}

```
> plot(seg.hc)

> rect.hclust(seg.hc, k=4, border = "red")
```

{% asset_image 1_hierarchical_segmetation_clust_rect_k_plot.png %}

```
> seg.hc.segment <- cutree(seg.hc, k=4) #membership vector for 4 groups 

> table(seg.hc.segment) #counts
seg.hc.segment
  1   2   3   4 
  8 199 153  18 

> clusplot(seg.df, seg.hc.segment,
         color = TRUE, #color the groups
         shade = TRUE, #shade the ellipses for group membership
         labels = 4, #label only the groups, not the individual points 
         lines = 0, #omit distance lines between groups
         main = "Hierarchical cluster plot" # figure title
)
```

{% asset_image 1_hierarchical_segmetation_clust_k_4_plot.png %}

```
> aggregate(seg.df, list(seg.hc.segment), mean)
  Group.1 Age_Group   Gender    Salary Education Employment Location_by_region Choco_Consumption Sustainability_Score
1       1  1.250000 1.500000 0.6250000  1.750000   3.375000           5.750000          2.250000          -0.60516875
2       2  2.708543 1.713568 3.4422111  2.718593   1.462312           1.025126          3.155779           0.11486553
3       3  1.496732 1.660131 0.9869281  1.823529   2.784314           1.444444          2.797386          -0.11049758
4       4  2.055556 1.611111 1.2777778  2.055556   8.277778           1.277778          2.944444          -0.06170389
```

```
> boxplot(seg.df$Salary ~ seg.hc.segment, ylab = "Salary", xlab = "Cluster")
```

{% asset_image 1_hierarchical_segmetation_clust_boxplot_salary.png %}

```
> boxplot(seg.df$Employment ~ seg.hc.segment, ylab = "Employment", xlab = "Cluster")
```

{% asset_image 1_hierarchical_segmetation_clust_boxplot_emplyment.png %}

- group 2 is well-differentiated: higher salary and full time employed.

### 1.1.3 kmeans()
```
> ### 1.1.3 Mean-based clustering: kmeans()
> 
> set.seed(96743)

> seg.k <- kmeans(seg.df, centers = 4) #use standardized variables

> table(seg.k$cluster)
  1   2   3   4 
122  21  86 149

> aggregate(seg.df, list(seg.k$cluster), mean)
  Group.1 Age_Group   Gender    Salary Education Employment Location_by_region Choco_Consumption Sustainability_Score
1       1  2.024590 1.713115 3.1885246  2.204918   1.114754           1.032787          3.163934          -0.20348352
2       2  2.095238 1.571429 1.4761905  2.047619   8.142857           1.476190          3.047619          -0.11730857
3       3  3.686047 1.790698 3.4767442  3.523256   1.720930           1.034884          3.139535           0.48794314
4       4  1.389262 1.610738 0.9731544  1.718121   2.939597           1.664430          2.731544          -0.09848691

> boxplot(seg.df$Employment ~ seg.k$cluster, ylab = "Employment", xlab = "Cluster")
```

{% asset_image 1_hierarchical_segmetation_kmeans_boxplot_emplyment.png %}

```
> boxplot(seg.df$Education ~ seg.k$cluster, ylab = "Education", xlab = "Cluster")
```

{% asset_image 1_hierarchical_segmetation_kmeans_boxplot_education.png %}

```
> clusplot(seg.df, seg.k$cluster,
         color = TRUE,
         shade = TRUE,
         labels = 4,
         lines = 0,
         main = "K_means cluster plot",
)
```

{% asset_image 1_hierarchical_segmetation_kmeans_clusplot.png %}

### 1.1.4 Model-based clustering: Mclust()

```
> ### 1.1.4 Model-based clustering: Mclust()
> seg.mc <- Mclust(seg.df) 
fitting ...
  |=============================================================================================================================| 100%

> summary(seg.mc)
---------------------------------------------------- 
Gaussian finite mixture model fitted by EM algorithm 
---------------------------------------------------- 

Mclust EEV (ellipsoidal, equal volume and shape) model with 8 components: 

 log-likelihood   n  df       BIC       ICL
      -2250.878 378 303 -6300.029 -6313.406

Clustering table:
 1  2  3  4  5  6  7  8 
17 77 54 22 45 37 56 70 

> seg.mc6 <- Mclust(seg.df, G=6) 
fitting ...
  |=============================================================================================================================| 100%

> summary(seg.mc6)
---------------------------------------------------- 
Gaussian finite mixture model fitted by EM algorithm 
---------------------------------------------------- 

Mclust EEV (ellipsoidal, equal volume and shape) model with 6 components: 

 log-likelihood   n  df       BIC       ICL
      -2725.733 378 229 -6810.557 -6814.644

Clustering table:
  1   2   3   4   5   6 
 17  58  56  51 123  73 

> BIC(seg.mc, seg.mc6)
         df      BIC
seg.mc  303 6300.029
seg.mc6 229 6810.557

> seg.mc4 <- Mclust(seg.df, G=4) 
fitting ...
  |=============================================================================================================================| 100%

> summary(seg.mc4)
---------------------------------------------------- 
Gaussian finite mixture model fitted by EM algorithm 
---------------------------------------------------- 

Mclust VII (spherical, varying volume) model with 4 components: 

 log-likelihood   n df      BIC      ICL
      -4145.259 378 39 -8521.98 -8557.61

Clustering table:
  1   2   3   4 
 38  61  76 203 

> BIC(seg.mc, seg.mc4)
         df      BIC
seg.mc  303 6300.029
seg.mc4  39 8521.980

> aggregate(seg.df, list(seg.mc$classification), mean)
  Group.1 Age_Group   Gender    Salary Education Employment Location_by_region Choco_Consumption Sustainability_Score
1       1  2.529412 1.117647 2.1764706  1.882353   6.176471           2.000000          3.294118         -0.215700588
2       2  2.207792 2.000000 2.4415584  1.909091   2.844156           1.051948          3.272727          0.216034675
3       3  1.259259 1.000000 0.8888889  1.537037   3.074074           1.814815          2.425926         -0.223684259
4       4  3.136364 1.727273 3.2727273  2.045455   1.363636           1.000000          3.545455         -1.943705000
5       5  2.511111 1.000000 3.6444444  2.000000   1.022222           1.022222          2.888889          0.224026222
6       6  1.000000 2.000000 2.3783784  2.918919   2.000000           1.297297          3.000000          0.193086216
7       7  1.375000 2.000000 0.8571429  1.535714   2.803571           1.642857          2.714286         -0.002380714
8       8  3.400000 2.000000 3.1285714  4.000000   1.371429           1.042857          3.100000          0.354010571

> clusplot(seg.df, seg.mc$classification, color = TRUE, shade = TRUE,
+          labels = 4, lines = 0, main = "Model-based cluster plot")
```

{% asset_image 1_hierarchical_segmetation_mclust_clusplot.png %}

```
boxplot(seg.df$Education ~ seg.mc$classification, ylab = "Education", xlab = "Cluster")
```

{% asset_image 1_hierarchical_segmetation_mclust_boxplot_education.png %}

```
boxplot(seg.df$Employment ~ seg.mc$classification, ylab = "Employment", xlab = "Cluster")
```

{% asset_image 1_hierarchical_segmetation_mclust_boxplot_employment.png %}

- Too many segmentations, `Education` and `Employment` maybe well-differentiated.
