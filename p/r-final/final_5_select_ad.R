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

spending.data <- read.csv("7_advertising.csv")
str(spending.data)
plot(spending.data$radio, spending.data$sales)
plot(spending.data$magazines, spending.data$sales)
plot(spending.data$social_media, spending.data$sales)
plot(spending.data$search_ads, spending.data$sales)
plot(spending.data$tv, spending.data$sales)
plot(spending.data$newspaper, spending.data$sales)

# Selecting Advertising platforms

## line
regression_1 <- lm(sales ~ radio + magazines + social_media + search_ads + tv + newspaper, data=spending.data) 
# 83.14% explained
summary(regression_1)

## log
summary(spending.data$radio)
summary(spending.data$magazines)
summary(spending.data$social_media)
summary(spending.data$search_ads)
summary(spending.data$tv)
summary(spending.data$newspaper)

regression_2 <- lm(log(sales) ~ log(radio) + log(magazines) + log(social_media) + log(search_ads) + log(tv) + log(newspaper), data=spending.data) 
# 90.15% explained
summary(regression_2)

regression <- lm(log(sales) ~ log(radio) + log(tv), data=spending.data) 
# 89.93% explained
summary(regression)


# Allocating marketing budgets
mean(spending.data$radio)
mean(spending.data$tv)
mean(spending.data$sales)

# radio
# A 1% increase in radio advertising results in a 0.26% increase in sales.
0.143520 * (log(23.2297) / log(1402.25))

# tv
# A 1% increase in tv advertising results in a 0.26% increase in sales.
0.364471 * (log(147.0425) / log(1402.25))

# synergy effect
center <- function(x) { scale(x, scale = F)}

regression <- lm(log(sales) ~ log(radio) + log(magazines) + log(social_media) + log(search_ads) + log(tv) + log(newspaper) + log(radio) * log(tv), data=spending.data) 
summary(regression)

regression <- lm(log(sales) ~ log(radio) + log(tv) + log(radio) * log(tv), data=spending.data) 
summary(regression)

spending.data <- spending.data %>% mutate(radio_log_centered = center(log(radio)),
                                          tv_log_centered = center(log(tv)), 
                                          newspaper_log_centered = center(log(newspaper)),
                                          magazines_log_centered = center(log(magazines)),
                                          social_media_log_centered = center(log(social_media)),
                                          search_ads_log_centered = center(log(search_ads)))

regression <- lm(log(sales) ~ radio_log_centered + magazines_log_centered + social_media_log_centered + search_ads_log_centered + tv_log_centered + newspaper_log_centered + radio_log_centered * tv_log_centered, data=spending.data) 
summary(regression)

regression <- lm(log(sales) ~ radio_log_centered + tv_log_centered + radio_log_centered * tv_log_centered, data=spending.data) 
summary(regression)

# carryover
adstock <- function(x, rate){
  return(as.numeric(stats::filter(x=x, filter=rate, method="recursive")))
}

spending.data <- spending.data %>% mutate(tv_adstock = adstock(tv,0.1),
                                          magazines_adstock = adstock(magazines, 0.1), 
                                          social_media_adstock = adstock(social_media, 0.1), 
                                          search_ads_adstock = adstock(search_ads, 0.1), 
                                          newspaper_adstock = adstock(newspaper, 0.1), 
                                          radio_adstock = adstock(radio, 0.1))

regression_with_stock <- lm(log(sales) ~ log(radio_adstock) + log(magazines_adstock) + log(social_media_adstock) + log(search_ads_adstock) + log(tv_adstock) + log(newspaper_adstock), data=spending.data) 
# 85.72% explained
summary(regression_with_stock)

spending.data <- spending.data %>% mutate(tv_adstock = adstock(tv,0.1),
                                          radio_adstock = adstock(radio, 0.1))

regression_with_stock <- lm(log(sales) ~ log(radio_adstock) + log(tv_adstock), data=spending.data) 
# 85.65% explained
summary(regression_with_stock)
