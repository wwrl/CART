library(dplyr)
library(ggplot2)
library(car)
library("VIM")
library(readxl)
library(rpart)
library(rpart.plot)
library(lubridate)
library(dplyr)
library(MLmetrics)
library(caret)
library(pROC)
library(ROCR)
library(randomForest)
library(xgboost)

## Data
load("D:/dane_zaliczenie (1).RData")

# Visualization for a variable "createtime"
proba_uczaca <- proba_uczaca %>%
  mutate(createtime = as.POSIXct(createtime))
proba_uczaca %>%
  mutate(date = as.Date(createtime)) %>%
  count(date) %>%
  ggplot(aes(x = date, y = n)) +
  geom_line(color = "blue") +
  labs(title = "Liczba transakcji w czasie", 
       x = "Data", 
       y = "Liczba transakcji")+
  theme(plot.title = element_text(hjust = 0.5))

# Visualization for a variable "amount"
ggplot(proba_uczaca, aes(x = amount)) +
  geom_histogram(bins = 50, fill = "blue", alpha = 0.7) +
  labs(title = "Rozkład kwot transakcji", 
       x = "Kwota", 
       y = "Liczba transakcji") +
  coord_cartesian(xlim = c(0, quantile(proba_uczaca$amount, 0.99)))

# Visualization for a variable "recurringaction"
ggplot(proba_uczaca , aes(x=factor(`recurringaction`),fill=factor(`recurringaction`))) +
  geom_bar() +
  theme(legend.position="none")

# Visualization for a variable "issuer"
ggplot(proba_uczaca , aes(x=factor(`issuer`),fill=factor(`issuer`))) +
  geom_bar() +
  theme(legend.position="none")

# Visualization for a variable "status"
ggplot(proba_uczaca , aes(x=factor(`status`),fill=factor(`status`))) +
  geom_bar() +
  theme(legend.position="none")

############################### Enhancing data #############################
proba_uczaca <- proba_uczaca %>%
  mutate(across(c(initialtransaction_id, browseragent, description, recurringaction, 
                  screenheight, screenwidth, acquirerconnectionmethod, expirymonth, 
                  expiryyear, issuer, type, level, countrycode, listtype, mccname), factor))

proba_testowa <- proba_testowa %>%
  mutate(across(c(initialtransaction_id, browseragent, description, recurringaction, 
                  screenheight, screenwidth, acquirerconnectionmethod, expirymonth, 
                  expiryyear, issuer, type, level, countrycode, listtype, mccname), factor))

proba_testowa <- proba_testowa %>%
  mutate(across(c(recurringaction, level, countrycode), ~ factor(.x, levels = levels(proba_uczaca[[cur_column()]]))))

proba_uczaca <- proba_uczaca %>%
  mutate(day_of_week = factor(format(createtime, format = "%A")))

proba_testowa <- proba_testowa %>%
  mutate(day_of_week = factor(format(createtime, format = "%A"), 
                              levels = levels(proba_uczaca$day_of_week)))

proba_uczaca <- proba_uczaca %>%
  mutate(predykcja_status = factor(ifelse(status %in% c("bank declined", "do not honor", "card limit exceeded"), 
                                          "porażka", "sukces")))

colSums(is.na(proba_uczaca))
colSums(is.na(proba_testowa))

proba_uczaca <- proba_uczaca %>%
  select(-id, -initialtransaction_id, -browseragent, -screenheight, -screenwidth, -payclickedtime, -description, -status)
proba_testowa <- proba_testowa %>%
  select(-id, -initialtransaction_id, -browseragent, -screenheight, -screenwidth, -payclickedtime, -description)

proba_testowa <- proba_testowa %>%
  filter(!recurringaction %in% c("INIT_WITH_REFUND", "INIT_WITH_PAYMENT"))
proba_uczaca <- proba_uczaca %>%
  filter(!recurringaction %in% c("INIT_WITH_REFUND", "INIT_WITH_PAYMENT"))

################################ Classification model #################################
drzewo_klasyfikacji <- rpart(
  formula = predykcja_status ~.,
  data = proba_uczaca,
  method = "class")
rpart.plot(drzewo_klasyfikacji, branch.type = 5)

length(proba_testowa$level)
length(predykcje_testowa$amount)

predykcje_klasyfikacja <- predict(drzewo_klasyfikacji, proba_testowa)

tabela_cp <- drzewo_klasyfikacji$cptable
min_cp  <- which.min(tabela_cp[, "xerror"])  
progn_odciecia <- sum(tabela_cp[min_cp, c("xerror", "xstd")]) 
nr_optymalne <- which(tabela_cp[, "xerror"] < progn_odciecia)[1] 
cp_optymalne <-tabela_cp[nr_optymalne, "CP"]

drzewo_klasyfikacji_przyciete<- prune(drzewo_klasyfikacji, cp=cp_optymalne)
rpart.plot(drzewo_klasyfikacji_przyciete)
cbind(drzewo_klasyfikacji_przyciete$variable.importance)
summary(drzewo_klasyfikacji_przyciete)
dotchart(rev(drzewo_klasyfikacji_przyciete$variable.importance))

klasy_predykcji <-predict(object = drzewo_klasyfikacji_przyciete, 
                                      newdata = proba_testowa, 
                                      type = "class")

prawdopodobienstwo_predykcji <-predict( object = drzewo_klasyfikacji_przyciete, 
                                      newdata = proba_testowa, 
                                      type = "prob")

cm = table(Rzeczywiste = proba_uczaca$predykcja_status, Przewidywane = predict(drzewo_klasyfikacji_przyciete, type = "class")) 
cm 

F1_score <- F1_Score((proba_uczaca$predykcja_status),
                     (predict(drzewo_klasyfikacji_przyciete, type = "class")))
print(F1_score)

n = sum(cm)
diag = diag(cm)
accuracy = sum(diag) / n 

accuracy * 100

############################# Model improvement ##############################
max_n <- max(table(proba_uczaca$predykcja_status))
proba_uczaca_2 <- proba_uczaca %>%
  group_by(predykcja_status) %>%
  slice_sample(n = max_n, replace = TRUE) %>%
  ungroup()

drzewo_klasyfikacji_2 <- rpart(
  formula = predykcja_status ~.,
  data = proba_uczaca_2,
  method = "class")

rpart.plot(drzewo_klasyfikacji_2, branch.type = 5)

predykcje_klasyfikacja_2 <- predict(drzewo_klasyfikacji_2, proba_testowa)

tabela_cp_2 <- drzewo_klasyfikacji_2$cptable
min_cp_2  <- which.min(tabela_cp_2[, "xerror"])  
progn_odciecia_2 <- sum(tabela_cp_2[min_cp, c("xerror", "xstd")]) 
nr_optymalne_2 <- which(tabela_cp_2[, "xerror"] < progn_odciecia)[1] 
cp_optymalne_2 <-tabela_cp_2[nr_optymalne, "CP"]

drzewo_klasyfikacji_przyciete_2<- prune(drzewo_klasyfikacji_2, cp=cp_optymalne_2)
rpart.plot(drzewo_klasyfikacji_przyciete_2)
cbind(drzewo_klasyfikacji_przyciete_2$variable.importance)
summary(drzewo_klasyfikacji_przyciete_2)
dotchart(rev(drzewo_klasyfikacji_przyciete_2$variable.importance))

klasy_predykcji_2 <-predict(object = drzewo_klasyfikacji_przyciete_2, newdata = proba_testowa, type = "class")
prawdopodobienstwo_predykcji_2 <-predict( object = drzewo_klasyfikacji_przyciete_2, newdata = proba_testowa, type = "prob")

cm_2 = table(Rzeczywiste = proba_uczaca_2$predykcja_status, Przewidywane = predict(drzewo_klasyfikacji_przyciete_2, type = "class")) 
cm_2

F1_score_2 <- F1_Score((proba_uczaca_2$predykcja_status),
                     (predict(drzewo_klasyfikacji_przyciete_2, type = "class")))
print(F1_score_2)

n_2 = sum(cm_2)
diag_2 = diag(cm_2)
accuracy_2 = sum(diag_2) / n_2
accuracy_2 * 100

####################### Regression model ########################
regresja_proby_uczacej <- proba_uczaca[,-14]

drzewo_regresji <- rpart(
  formula = amount ~.,
  data = regresja_proby_uczacej,
  method = "anova"
)

rpart.plot(drzewo_regresji, branch.type = 5)

cbind(drzewo_regresji$variable.importance)

printcp(drzewo_regresji)

plotcp(drzewo_regresji)

drzewo_regresji_przyciete<- prune(drzewo_regresji, cp= drzewo_regresji$cptable[which.min(drzewo_regresji$cptable[,"xerror"]),"CP"])
rpart.plot(drzewo_regresji_przyciete)

predykcja_proby_uczacej <- regresja_proby_uczacej[,-2]

pognoza_proba_uczaca_1 <- predict(drzewo_regresji, predykcja_proby_uczacej)

regresja_predykcja_f <- predict(drzewo_regresji_przyciete, proba_testowa, method = "anova")

summary(regresja_predykcja_f)

MSE_1 <- mean((regresja_proby_uczacej$amount - pognoza_proba_uczaca_1)^2)
MSE_1

pognoza_proba_uczaca_2 <- predict(drzewo_regresji_przyciete, predykcja_proby_uczacej)

MSE_2 <- mean((regresja_proby_uczacej$amount - pognoza_proba_uczaca_2)^2)
MSE_2

SSE_1 <- sum((pognoza_proba_uczaca_1 - proba_uczaca$amount)^2)
SSE_1

SSE_2 <- sum((regresja_proby_uczacej$amount - pognoza_proba_uczaca_2)^2)
SSE_1

############################### Random Forest ###############################################
for (col in colnames(regresja_proby_uczacej)) {
  if (is.factor(regresja_proby_uczacej[[col]])) {
    proba_testowa[[col]] <- factor(proba_testowa[[col]], levels = levels(regresja_proby_uczacej[[col]]))
  }
}

drzewo_rf <- randomForest(
  proba_uczaca$amount ~ .,  
  data = regresja_proby_uczacej, 
  ntree =  40,   
  mtry = 10, 
  importance = TRUE    
) 

varImpPlot(drzewo_rf)
print(drzewo_rf)

predykcja_rf <- predict(drzewo_rf, proba_testowa)
predykcja_rf[is.na(predykcja_rf)] <- median(predykcja_rf, na.rm = TRUE)  # Mediana

pognoza_proba_uczaca_3 <- predict(drzewo_rf, regresja_proby_uczacej)

MSE_rf <- mean((regresja_proby_uczacej$amount - pognoza_proba_uczaca_3)^2)
MSE_rf

SSE_rf <- sum((regresja_proby_uczacej$amount - pognoza_proba_uczaca_3)^2)
SSE_rf

summary(predykcja_rf)

predykcje_testowa$status <- predykcje_klasyfikacja_2
predykcje_testowa$amount <- predykcja_rf

