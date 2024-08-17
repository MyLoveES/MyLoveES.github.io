library("readxl")
library("psych")
library("car")
library("gpairs")
library("grid")
library("lattice")
library("corrplot")
library("gplots")
library("mclust")
library("cluster")
library("corrplot")
library("gplots")
library("nFactors")
library("ggplot2") # very popular plotting library ggplot2 
library("ggthemes") # themes for ggplot2
library("xtable") # processing of regression output 
library("knitr") # used for report compilation and table display 
library("caret") # confusion matrix
library("pROC") # confusion matrix
library("readxl") # used for report compilation and table display 
library("ggplot2") # confusion matrix
library("dplyr") # confusion matrix
library("xtable") # processing of regression output 
library("knitr") # used for report compilation and table display 
library("ggplot2") # very popular plotting library ggplot2 
library("mlogit") # multinomial logit
library("caret") # ConfusionMatrix
library("arules") # processing of regression output 
library("arulesViz") # used for report compilation and table display 
library("grid") # very popular plotting library ggplot2 
library("car") # multinomial logit
library("plotly") # ConfusionMatrix
library('readxl') 
library('dplyr')
library('fastDummies')
library('clustMixType')

# set cur dir as workdir
file_dir <- dirname(parent.frame(2)$ofile)
print(file_dir)
setwd(file_dir)

# 1. manage customer hierarchical

## 1.1 segmentation
seg.df <- read.csv("1_demographics.csv", stringsAsFactors = TRUE)
head(seg.df, n = 5)
summary(seg.df, digits = 2)

### 1.1.1 remove consumer_id in data set, and set consumer_id as row name
rownames(seg.df) <- seg.df[, 1]
seg.df <- seg.df[, -1]
#### remove salary = 7, invalid data
seg.df <- seg.df[seg.df$Salary != 7, ]

#### remove Employment, which related to Salary
# seg.df <- subset(seg.df, select = -Employment)
#### just split region to 3 groups
seg.df$Location_by_region[seg.df$Location_by_region > 2] <- 2
seg.df$Employment[seg.df$Employment <= 2] <- 1
seg.df$Employment[seg.df$Employment > 2] <- 2

hist(seg.df$Location_by_region,
     main = "All customers", 
     xlab = "Location_by_region",
     ylab = "Count",
     col = "lightblue" # colore the bars
)

hist(seg.df$Employment,
     main = "All customers", 
     xlab = "Employment",
     ylab = "Count",
     col = "lightblue" # colore the bars
)

hist(seg.df$Salary,
     main = "All customers", 
     xlab = "Salary",
     ylab = "Count",
     col = "lightblue" # colore the bars
)

hist(seg.df$Sustainability_Score,
     main = "All customers", 
     xlab = "Sustainability_Score",
     ylab = "Count",
     col = "lightblue" # colore the bars
)

hist(seg.df$Choco_Consumption,
     main = "All customers", 
     xlab = "Choco_Consumption",
     ylab = "Count",
     col = "lightblue" # colore the bars
)

head(seg.df, n = 5)
summary(seg.df, digits = 2)
str(seg.df)

#### factor ordered ordinals
seg.df.sc <- seg.df
# Q1 <- quantile(seg.df.sc$Sustainability_Score, 0.25)
# Q3 <- quantile(seg.df.sc$Sustainability_Score, 0.75)
# IQR <- Q3 - Q1
# lower <- Q1 - 1.5 * IQR
# upper <- Q3 + 1.5 * IQR

# seg.df.sc <- seg.df.sc[seg.df.sc$Sustainability_Score >= lower & seg.df.sc$Sustainability_Score <= upper, ]
#### just scale continous variables
# seg.df.sc[, c(6,7)] <- scale(seg.df[ , c(6,7)])
# seg.df.sc[, c(7,8)] <- scale(seg.df[ , c(7,8)])
seg.df.sc[, c(1,3,4,7,8)] <- scale(seg.df[ , c(1,3,4,7,8)])
# seg.df.sc[, 7] <- as.numeric(scale(seg.df[, 7]))

# seg.df.sc$Age_Group <- as.numeric(factor(seg.df$Age_Group, ordered = TRUE))
# seg.df.sc$Salary <- as.numeric(factor(seg.df$Salary, ordered = TRUE))
# seg.df.sc$Education <- as.numeric(factor(seg.df$Education, ordered = TRUE))
# seg.df.sc$Choco_Consumption <- as.numeric(factor(seg.df$Choco_Consumption, ordered = TRUE))
# seg.df.sc$Gender <- as.numeric(factor(seg.df$Gender, ordered = FALSE))
# seg.df.sc$Employment <- as.numeric(factor(seg.df$Employment, ordered = FALSE))
# seg.df.sc$Location_by_region <- as.numeric(factor(seg.df$Location_by_region, ordered = FALSE))

#### set factors
seg.df.sc$Age_Group <- factor(seg.df.sc$Age_Group, ordered = TRUE)
seg.df.sc$Salary <- factor(seg.df.sc$Salary, ordered = TRUE)
seg.df.sc$Education <- factor(seg.df.sc$Education, ordered = TRUE)
# seg.df.sc$Choco_Consumption <- factor(seg.df.sc$Choco_Consumption, ordered = TRUE)
seg.df.sc$Gender <- factor(seg.df.sc$Gender, ordered = FALSE)
seg.df.sc$Employment <- factor(seg.df.sc$Employment, ordered = FALSE)
seg.df.sc$Location_by_region <- factor(seg.df.sc$Location_by_region, ordered = FALSE)

head(seg.df.sc, n = 5)
summary(seg.df.sc, digits = 2)
str(seg.df.sc)

# seg.df <- model.matrix(~ Gender + Location_by_region + Employment + 0, data = seg.df)
# head(seg.df, n = 5)
# summary(seg.df, digits = 2)
# str(seg.df)

# seg.df.sc <- seg.df
# seg.df.sc[, c(1,3,4)] <- scale(seg.df[, c(1,3,4)])
# head(seg.df.sc, n = 5)
# summary(seg.df.sc, digits = 2)
# str(seg.df.sc)

### 1.1.2 Hierarchical clustering: hclust()
seg.dist <- dist(seg.df.sc)
# seg.dist <- daisy(seg.df.sc, metric = "gower")
# as.matrix(seg.dist)[1:7, 1:7]
as.matrix(seg.dist)[1:8, 1:8]
seg.hc <- hclust(seg.dist, method="complete")
plot(seg.hc)
plot(cut(as.dendrogram(seg.hc), h = 4)$lower[[1]])
plot(seg.hc)
rect.hclust(seg.hc, k=4, border = "red")
seg.hc.segment <- cutree(seg.hc, k=4) #membership vector for 4 groups 
table(seg.hc.segment) #counts
clusplot(seg.df, seg.hc.segment,
         color = TRUE, #color the groups
         shade = TRUE, #shade the ellipses for group membership
         labels = 4, #label only the groups, not the individual points 
         lines = 0, #omit distance lines between groups
         main = "Hierarchical cluster plot" # figure title
)
aggregate(seg.df, list(seg.hc.segment), mean)
boxplot(seg.df$Age_Group ~ seg.hc.segment, ylab = "Age_Group", xlab = "Cluster")
boxplot(seg.df$Salary ~ seg.hc.segment, ylab = "Salary", xlab = "Cluster")
boxplot(seg.df$Education ~ seg.hc.segment, ylab = "Education", xlab = "Cluster")
boxplot(seg.df$Choco_Consumption ~ seg.hc.segment, ylab = "Choco_Consumption", xlab = "Cluster")
boxplot(seg.df$Sustainability_Score ~ seg.hc.segment, ylab = "Sustainability_Score", xlab = "Cluster")

# 计算轮廓系数  
sil <- silhouette(seg.hc.segment, seg.dist)  

# 查看轮廓系数的平均值和各个样本点的轮廓系数  
mean(sil[,3])  # 平均值  
# sil[,3]        # 各个样本点的轮廓系数

### 1.1.3 Mean-based clustering: kmeans()

set.seed(12580)
seg.k <- kmeans(seg.df.sc, centers = 4) #use standardized variables
table(seg.k$cluster)
aggregate(seg.df, list(seg.k$cluster), mean)
clusplot(seg.df, seg.k$cluster,
         color = TRUE,
         shade = TRUE,
         labels = 4,
         lines = 0,
         main = "K_means cluster plot",
)
boxplot(seg.df$Age_Group ~ seg.k$cluster, ylab = "Age_Group", xlab = "Cluster")
boxplot(seg.df$Salary ~ seg.k$cluster, ylab = "Salary", xlab = "Cluster")
boxplot(seg.df$Education ~ seg.k$cluster, ylab = "Education", xlab = "Cluster")
boxplot(seg.df$Choco_Consumption ~ seg.k$cluster, ylab = "Choco_Consumption", xlab = "Cluster")
boxplot(seg.df$Sustainability_Score ~ seg.k$cluster, ylab = "Sustainability_Score", xlab = "Cluster")

### 1.1.4 Model-based clustering: Mclust()
seg.mc <- Mclust(seg.df.sc) 
summary(seg.mc)
seg.mc6 <- Mclust(seg.df.sc, G=6) 
summary(seg.mc6)
BIC(seg.mc, seg.mc6)
seg.mc4 <- Mclust(seg.df.sc, G=4) 
summary(seg.mc4)
BIC(seg.mc, seg.mc4)
table(seg.mc$classification)
aggregate(seg.df, list(seg.mc$classification), mean)
clusplot(seg.df, seg.mc$classification, color = TRUE, shade = TRUE,
         labels = 4, lines = 0, main = "Model-based cluster plot")

boxplot(seg.df$Age_Group ~ seg.mc$classification, ylab = "Age_Group", xlab = "Cluster")
boxplot(seg.df$Education ~ seg.mc$classification, ylab = "Education", xlab = "Cluster")
boxplot(seg.df$Salary ~ seg.mc$classification, ylab = "Salary", xlab = "Cluster")
boxplot(seg.df$Choco_Consumption ~ seg.mc$classification, ylab = "Choco_Consumption", xlab = "Cluster")
boxplot(seg.df$Sustainability_Score ~ seg.mc$classification, ylab = "Sustainability_Score", xlab = "Cluster")

### 1.1.5 kproto
set.seed(12580)
seg.kp <- kproto(seg.df.sc, k = 4) #use standardized variables
summary(seg.kp)
table(seg.kp$cluster)
aggregate(seg.df, list(seg.kp$cluster), mean)
clusplot(seg.df, seg.kp$cluster,
         color = TRUE,
         shade = TRUE,
         labels = 4,
         lines = 0,
         main = "K_means cluster plot",
)
boxplot(seg.df$Age_Group ~ seg.kp$cluster, ylab = "Age_Group", xlab = "Cluster")
boxplot(seg.df$Salary ~ seg.kp$cluster, ylab = "Salary", xlab = "Cluster")
boxplot(seg.df$Education ~ seg.kp$cluster, ylab = "Education", xlab = "Cluster")
boxplot(seg.df$Choco_Consumption ~ seg.kp$cluster, ylab = "Choco_Consumption", xlab = "Cluster")
boxplot(seg.df$Sustainability_Score ~ seg.kp$cluster, ylab = "Sustainability_Score", xlab = "Cluster")

