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

ad.df <- read.csv("8_clickstream.csv", stringsAsFactors = TRUE) 
summary(ad.df)
str(ad.df)

ad.df$clicked_article <- factor(ad.df$clicked_article, ordered = FALSE)
ad.df$clicked_like <- factor(ad.df$clicked_like, ordered = FALSE)
ad.df$clicked_share <- factor(ad.df$clicked_share, ordered = FALSE)

# seconds spent vary for two versions of ads.
aggregate(time_spent_homepage_sec ~ condition, data = ad.df, mean)

# the frequency with which different combinations of condition and like occur
table(ad.df$condition, ad.df$clicked_article)
table(ad.df$condition, ad.df$clicked_like)
table(ad.df$condition, ad.df$clicked_share)

# Visualizing frequencies and proportions
histogram(~ clicked_article | condition, data = ad.df)
histogram(~ clicked_like | condition, data = ad.df)
histogram(~ clicked_share | condition, data = ad.df)

# Visualizing continuous data
ad.mean <- aggregate(time_spent_homepage_sec ~ condition, data = ad.df, mean) 
barchart(time_spent_homepage_sec ~ condition, data = ad.mean, col = "grey")
