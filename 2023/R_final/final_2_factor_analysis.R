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

## 1.2 factor analysis

### 1.2.1 import and check data
brand.ratings <- read.csv("2_chocolate_rating.csv", stringsAsFactors = TRUE)

#### remove unnecessary columns
brand.ratings <- subset(brand.ratings, select = -c(product_id,company_location,review_date,country_of_bean_origin,first_taste,second_taste,third_taste))
head(brand.ratings)
summary(brand.ratings)
str(brand.ratings)
### 1.2.2 Rescaling the data
brand.sc <- brand.ratings
brand.sc[,2:10] <- scale (brand.ratings[,2:10])
head(brand.sc)
summary(brand.sc)
str(brand.sc)

cor(brand.sc[,2:10])
corrplot(cor(brand.sc[,2:10]))
corrplot(cor(brand.sc[,2:10]), order = "hclust")

### 1.2.3 Mean rating by brand
brand.mean <- aggregate(. ~ brand, data=brand.sc, mean) 
brand.mean

rownames(brand.mean) <- brand.mean[, 1]
#### Use brand for the row name
brand.mean <- brand.mean [, -1]
brand.mean
heatmap.2(as.matrix(brand.mean),main = "Brand attributes", trace = "none", key = FALSE, dend = "none"
          #turn off some options
)

### 1.2.4 Principal component analysis (PCA) using princomp()
brand.pc<- princomp(brand.mean, cor = TRUE)
#We added "cor =TRUE" to use correlation-based one. 
summary(brand.pc)
plot(brand.pc,type="l") # scree plot
loadings(brand.pc) # pc loadings
brand.pc$scores # the principal components

biplot(brand.pc, main = "Brand positioning")

colMeans(brand.mean[c("Fresco", "Burnt Fork Bend", "Pura Delizia"), ]) - brand.mean["Castronovo",]

### 1.2.5 Factor analysis using factanal() *
nScree(brand.mean)
eigen(cor(brand.mean))
brand.fa <- factanal(brand.mean, factors = 2, rotation = "varimax", scores = "regression")

brand.fl<- brand.fa$loadings[, 1:2]
plot(brand.fl,type="n") # set up plot 
text(brand.fl,labels=names(brand.mean),cex=.7)

brand.fs <- brand.fa$scores
plot(brand.fl,type="n") # set up plot 
text(brand.fl,labels=rownames(brand.mean),cex=.7)

