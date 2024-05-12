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

retail.raw <- readLines("6_groceries.dat")
head(retail.raw)
tail(retail.raw)
summary(retail.raw)

retail.list <- strsplit(retail.raw, ",")
names(retail.list) <- paste("Trans", 1:length(retail.list))
str(retail.list)

some(retail.list) #note: random sample; your results may vary
retail.trans <- as(retail.list, "transactions") #takes a few seconds 
summary(retail.trans)


inspect(head(retail.trans,3))
# Finding rules
groc.rules <- apriori(retail.trans, parameter = list(supp=0.01, conf=0.3, target="rules"))

inspect(subset(groc.rules, lift > 3))

# plot rules
plot(groc.rules)
plot(groc.rules, engine = "plotly", interactive=TRUE)

# Finding and Plotting Subsets of Rules
groc.hi <- head(sort(groc.rules, by="lift"), 15) 
inspect(groc.hi)

plot(groc.hi, method="graph")
