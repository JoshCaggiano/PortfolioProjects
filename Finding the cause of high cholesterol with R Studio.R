
heart <- read.csv("C:/Users/jcagg/OneDrive/Academic Yearly Downloads/2021 (Fall)/DSS 665 - R Statistical Programming/heart.csv", header=T)
summary(heart)  # need to create dummy variables for sex and resting ecg

install.packages("fastDummies")  #new package to create dummy variables
library("fastDummies")
dummy.heart <- dummy_cols(heart, select_columns = c('Sex', 'RestingECG'))  #creates Dummy Variables
dummy.heart <- subset(dummy.heart, select = -c(Sex, Sex_F, RestingECG, RestingECG_LVH)) #omitted columns we don't need
dummy.heart
summary(dummy.heart) #summary statistics with updated dummy variables - need to change categorical variables from numeric to factor


dummy.heart$Sex_M <- factor(dummy.heart$Sex_M, labels=c("Female","Male"))                           #factor for sex
dummy.heart$RestingECG_Normal <- factor(dummy.heart$RestingECG_Normal, labels=c("LVH","Normal"))    #factor for Resting ECG
dummy.heart$HeartDisease <- factor(dummy.heart$HeartDisease, labels=c("No","Yes"))                  #factor for Heart Disease
class(dummy.heart$Sex_M)
summary(dummy.heart)
dummy.heart

hist(dummy.heart$Age,main = "Histogram of Age", xlab="Age",breaks=seq(0,80,by=5),col="red")   #histogram for Age                    
hist(dummy.heart$Cholesterol,main = "Histogram of Cholesterol", xlab="Cholesterol",breaks=seq(0,700,by=10),col="red") #Histogram for Cholesterol
hist(dummy.heart$RestingBP,main = "Histogram of Resting BP", xlab="Resting BP",breaks=seq(0,250,by=10),col="red") #Histogram for Resting BP
hist(dummy.heart$MaxHR,main = "Histogram of Max Heart Rate", xlab="Max Heart Rate",breaks=seq(0,250,by=10),col="red") #Histogram for Resting BP

summary(lm(dummy.heart$Cholesterol ~ dummy.heart$Age + dummy.heart$RestingBP + dummy.heart$HeartDisease  #initial model with all variables
                            + dummy.heart$MaxHR + dummy.heart$Sex_M + dummy.heart$RestingECG_Normal))

summary(lm(dummy.heart$Cholesterol ~ dummy.heart$RestingBP + dummy.heart$HeartDisease  #model without age
           + dummy.heart$MaxHR + dummy.heart$Sex_M + dummy.heart$RestingECG_Normal))

summary(lm(dummy.heart$Cholesterol ~ dummy.heart$RestingBP + dummy.heart$HeartDisease  #model without Resting ECG, Final Model
           + dummy.heart$MaxHR + dummy.heart$Sex_M))
