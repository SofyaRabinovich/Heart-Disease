#Libraries used
library(broom)
library(dslabs)
library(HistData)
library(tidyverse)
library(tidyr)
library(tidyselect)
library(tidytext)
library(dplyr)
library(gridExtra)
library(ggplot2)
library(ggpubr)
library(ggrepel)
library(ggsci)
library(ggsignif)
library(ggthemes)
library(readxl)
library(readr)
library(reshape2)
library(lpSolve)
library(lubridate)
library(caret)
library(e1071)
library(MASS)
library(purrr)
library(pdftools)
library(matrixStats)
library(rpart)
library(Rborist)
library(recosystem)
library(randomForest)
library(party)
library(car)
library(rattle)

# Download data from https://www.kaggle.com/ronitf/heart-disease-uci
data <- read.csv("heart.csv")

# Data Transformation 
summary(data)
data_tidy <- data %>%
  mutate(sex = ifelse(sex == 1, "Male", "Female"), 
         fbs = ifelse(fbs == 1, ">120", "<= 120"),
         exang = ifelse(exang == 1, "Yes", "No"), 
         restecg = ifelse(restecg == 0, "Normal", "Abnormal"), 
         cp = ifelse(cp == 1, "Typical Angina", 
                     ifelse(cp == 2, "Atypical Angina", 
                            ifelse(cp == 3, "Non-Anginal Pain", "Asymptomatic"))), 
         target = ifelse(target == 1, "Heart Disease", "No Heart Disease"), 
         slope = as.factor(slope), 
         ca = as.factor(ca), 
         thal = as.factor(thal))
#rename Columns
data_tidy <- data_tidy %>%
  rename("Age" = age, 
         "Sex" = sex,
         "Chest_Pain_type" = cp, 
         "Resting_blood_pressure" = trestbps, 
         "Cholesterol" =chol, 
         "Fasting_blood_sugar" = fbs, 
         "Resting_electrocardiographic_results" = restecg, 
         "Maximum_heart_rate_achieved" = thalach, 
         "Exercise_induced_angina " = exang, 
         "ST_depression" = oldpeak, 
         "ST_slope" = slope, 
         "Number_of_major_vessels " = ca, 
         "Thalassemia" = thal, 
         "Heart_Disease" = target) %>%
  mutate_if(is.character, as.factor)

#Data Exploration 
#See summary statistics 
summary(data_tidy)
# First of all we will visualise how many people have HD
data_tidy %>%
  ggplot(aes(Heart_Disease, fill = Heart_Disease)) + 
  geom_bar() +
  xlab("Presence/Absence of Heart Disease") +
  ylab("Count") +
  ggtitle("Heart Disease")
#Investigate Chest pain and HD occurence
data_tidy %>%
  ggplot(aes(Chest_Pain_type, fill = Heart_Disease)) +
  geom_bar(stat = "count") +
  xlab("Chest Pain") +
  ylab("Count") +
  ggtitle("Chest Pan and Heart Disease") 
#Fasting Blood Glucose and HD
data_tidy %>%
  ggplot(aes(Fasting_blood_sugar, fill = Heart_Disease)) +
  geom_bar(stat = "count") +
  xlab("Fasting Blood Glucose in mg/dl") +
  ylab("Count") +
  ggtitle("Fasting Blood Glucose and Heart Disease")
#Resting Electrocardiographic Results and HD
data_tidy %>%
  ggplot(aes(Resting_electrocardiographic_results, fill = Heart_Disease)) +
  geom_bar(stat = "count") +
  xlab("Resting Electrocardiographic Results") +
  ylab("Count") +
  ggtitle("Resting Electrocardiographic Results and Heart Disease")
# Exercise induced angina and HD
data_tidy %>%
  ggplot(aes(`Exercise_induced_angina `, fill = Heart_Disease)) +
  geom_bar(stat = "count") +
  xlab("Exercise induced angina") +
  ylab("Count") +
  ggtitle("Exercise induced angina and Heart Disease")
# Thalassemia and HD
data_tidy %>%
  ggplot(aes(Thalassemia, fill = Heart_Disease)) +
  geom_bar(stat = "count") +
  xlab("Thalassemia") +
  ylab("Count") +
  ggtitle("Thalassemia and Heart Disease")
#Sex and Hd
data_tidy %>%
  ggplot(aes(Sex, fill = Heart_Disease)) +
  geom_bar(stat = "count") +
  xlab("Sex") +
  ylab("Count") +
  ggtitle("Sex and Heart Disease")
# Age and HD 
data_tidy %>%
  ggplot(aes(Age, fill = Heart_Disease, color = Heart_Disease)) +
  geom_density(alpha = 0.3) +
  xlab("Age") +
  ylab('Heart Disease') +
  ggtitle("Age and Heart Disease")
#Resting Blood Pressure and HD
data_tidy %>%
  ggplot(aes(Resting_blood_pressure, fill = Heart_Disease, color = Heart_Disease)) +
  geom_density(alpha = 0.3) +
  xlab("Resting Blood Pressure") +
  ylab('Heart Disease') +
  ggtitle("Resting Blood Pressure and Heart Disease")
# Cholesterol and HD 
data_tidy %>%
  ggplot(aes(Cholesterol, fill = Heart_Disease, color = Heart_Disease)) +
  geom_density(alpha = 0.3) +
  xlab("Cholesterol") +
  ylab('Heart Disease') +
  ggtitle("Cholesterol and Heart Disease")
# Maximum Heart Rate
data_tidy %>%
  ggplot(aes(Maximum_heart_rate_achieved, fill = Heart_Disease, color = Heart_Disease)) +
  geom_density(alpha = 0.3) +
  xlab("Maximum Heart Rate") +
  ylab('Heart Disease') +
  ggtitle("Maximum Heart Rate and Heart Disease")
# ST depression and HD 
data_tidy %>%
  ggplot(aes(ST_depression, fill = Heart_Disease, color = Heart_Disease)) +
  geom_density(alpha = 0.3) +
  xlab("ST depression") +
  ylab('Heart Disease') +
  ggtitle("ST depression and Heart Disease")
# Number of major vessels and HD 
data_tidy %>%
  ggplot(aes(`Number_of_major_vessels `, fill = Heart_Disease, color = Heart_Disease)) +
  geom_density(alpha = 0.3) +
  xlab("Number of major vessels colored by flourosopy") +
  ylab('Heart Disease') +
  ggtitle("Number of major vessels  colored by flourosopy and Heart Disease")
# Correlation graph 
correlation <- cor(data)
corrplot::corrplot(correlation, type="upper", 
                   order="hclust")
# Data Analysis 
# Split data into training and test set 
test_index <- createDataPartition(data$target, times = 1, p = 0.3, list = FALSE)
test_set <- data[test_index, ]
training_set <- data[-test_index, ]
#Logistic Regression model 
fit_glm <- glm(target ~., data = training_set, family = 'binomial')
varImp(fit_glm) %>%
arrange(desc(Overall))
y_hat <- predict(fit_glm, type = 'response', 
                 newdata = test_set)
p_hat <- ifelse(y_hat > 0.5, 1, 0)
accuracy_glm <- mean(p_hat == test_set$target) #accuracy of the model 
#Random Forest model 
fit_rf <- randomForest(target ~., data = training_set, ntree = 1000, mtry = 1)
varImp(fit_rf)
y_hat_rf <- predict(fit_rf, test_set)
p_hat_rf <- ifelse(y_hat_rf > 0.5, 1, 0)
accuracy_rf <- mean(p_hat_rf == test_set$target) #accuracy of the model 
#Naive Bayes
fit_nb <- train(as.factor(target)~., data = training_set, 
                method = 'nb')
y_hat_nb <- predict(fit_nb, test_set)
p_hat_nb <- ifelse(as.numeric(y_hat_nb) > 0.5, 1, 0)
accuracy_nb <- mean(p_hat_nb == test_set$target) #accuracy of the model
# Decision Tree
fit_rpart <- rpart(target ~., training_set)
rpart.plot::rpart.plot(fit_rpart) #visualise
plotcp(fit_rpart)
printcp(fit_rpart)#choose low cp value, but remember that too low value will lead to overfitting
fit_rpart_2 <- rpart(target ~., training_set, cp = 0.099284) #train model with optimal cp value
y_hat_rpart <- predict(fit_rpart_2, test_set) #predictive model
p_hat_rpart <- ifelse(y_hat_rpart > 0.5, 1, 0)
accuracy_rpart <- mean(p_hat_rpart == test_set$target)
#KNN
control <- trainControl(method = "cv", 
                        number = 5, 
                        p = .9)
fit_knn <- train(target ~., 
                 data = training_set, 
                 method = 'knn', 
                 trControl = control)
fit_knn_2 <- train(target ~., 
                   data = training_set, 
                   method = 'knn', 
                   trControl = control, 
                   tuneGrid = data.frame(k=9))
y_hat_knn <- predict(fit_knn_2, test_set)
p_hat_knn <- ifelse(y_hat_knn > 0.5, 1, 0)
accuracy_knn <- mean(p_hat_knn == test_set$target) #accuracy of the model
# Make a table to compare accuracy of models
accuracy_model <- data.frame(Model = c("Linear Regression", 
                                       "Random Forest",
                                       "Naive Bayes", 
                                       "Decision Tree",
                                       "Knn"), 
                             Accuracy = c(accuracy_glm*100, 
                                          accuracy_rf*100,
                                          accuracy_nb*100, 
                                          accuracy_rpart*100,
                                          accuracy_knn*100)) %>%
  arrange(desc(Accuracy))
knitr::kable(accuracy_model)
                             
                             

