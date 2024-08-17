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

# 2 Choice-Based Conjoint Analysis

## 2.1 product design

### 2.1.1 import and check data
cbc.df <- read.csv("5_conjoint.csv", stringsAsFactors = TRUE)
head(cbc.df, n = 5)
summary(cbc.df, digits = 2)
str(cbc.df)

cbc.df <- subset(cbc.df, select = -c(Block,Age_Group,Gender,Salary, Education, Employment, Location_by_region, Choco_Consumption, Sustainability_Score))
head(cbc.df, n = 5)
summary(cbc.df, digits = 2)
str(cbc.df)

xtabs(Choice~Origin, data=cbc.df)
xtabs(Choice~Manufacture, data=cbc.df)
xtabs(Choice~Energy, data=cbc.df)
xtabs(Choice~Nuts, data=cbc.df)
xtabs(Choice~Tokens, data=cbc.df)
xtabs(Choice~Organic, data=cbc.df)
xtabs(Choice~Premium, data=cbc.df)
xtabs(Choice~Fairtrade, data=cbc.df)
xtabs(Choice~Sugar, data=cbc.df)

### 2.1.2 prepare the data

cbc.df$Origin <- relevel(cbc.df$Origin, ref = "Venezuela")
cbc.df$Manufacture <- relevel(cbc.df$Manufacture, ref = "UnderDeveloped")
cbc.df$Energy <- relevel(cbc.df$Energy, ref = "Low")
cbc.df$Nuts <- relevel(cbc.df$Nuts, ref = "No")
cbc.df$Tokens <- relevel(cbc.df$Tokens, ref = "No")
cbc.df$Organic <- relevel(cbc.df$Organic, ref = "No")
cbc.df$Premium <- relevel(cbc.df$Premium, ref = "No")
cbc.df$Fairtrade <- relevel(cbc.df$Fairtrade, ref = "No")
cbc.df$Sugar <- relevel(cbc.df$Sugar, ref = "Low")

## 2.1.3 Multinomial conjoint model estimation with mlogit()
cbc.mlogit <- dfidx(cbc.df, choice="Choice",
                    idx=list(c("Choice_id", "Consumer_id"), "Alternative"))

model<-mlogit(Choice ~ 0+Origin+Manufacture+Energy+Nuts+Tokens+Organic+Premium+Fairtrade+Sugar+Price, data=cbc.mlogit) 
kable(summary(model)$CoefTable)

### 2.1.4 Model fit
model.constraint <-mlogit(Choice ~ 0+Nuts, data = cbc.mlogit)
lrtest(model, model.constraint)

### 2.1.5 Interpreting Conjoint Analysis Findings
kable(head(predict(model,cbc.mlogit)))

predicted_alternative <- apply(predict(model,cbc.mlogit),1,which.max) 
selected_alternative <- cbc.mlogit$Alternative[cbc.mlogit$Choice>0] 
confusionMatrix(table(predicted_alternative,selected_alternative),positive = "1")

## 2.2 Willingness to pay

### 2.2.1 What is the Nuts' value
(coef(model)["NutsNuts and Fruit"]-coef(model)["NutsNuts only"]) / (-coef(model)["Price"])

### 2.2.2 Willingness to Pay for an Attribute Upgrade
coef(model)["NutsNuts and Fruit"] / (-coef(model)["Price"])
coef(model)["NutsNuts only"] / (-coef(model)["Price"])
coef(model)["EnergyHigh"] / (-coef(model)["Price"])
coef(model)["OrganicYes"] / (-coef(model)["Price"])
coef(model)["SugarHigh"] / (-coef(model)["Price"])
