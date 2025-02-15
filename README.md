# CART
## Analysis and Modeling of Transactional Data
#### Project Description
This project focuses on analyzing, cleaning, and modeling transactional data. It includes the implementation of classification and regression models to predict transaction status and amounts.
The project was developed in R language. 

## Analysis Steps
#### 1. Data Loading and Exploration
Data is loaded from a .RData file, followed by basic exploration, including variable visualization:

Transaction time distribution

Histogram of transaction amounts

Bar charts for categorical variables (issuer, recurringaction, status)
#### 2. Data Cleaning and Processing

Conversion of selected variables to factor format.

Creation of the day_of_week variable (day of the week of the transaction).

Removal of unnecessary columns (id, description, screenheight, etc.).

Filtering data and eliminating selected NA values.

#### 3. Building Classification Models

Two classification models were created:

Decision tree (rpart) for predicting transaction status (success vs failure).

Pruned decision tree (prune) – model optimization based on the cp criterion.

Model evaluation: Calculation of confusion matrix, accuracy, and F1-score.

#### 4. Regression Model

Regression model (rpart) for predicting transaction amount.

Model pruning (prune) and parameter optimization.

Calculation of model errors (MSE, SSE).

#### 5. Random Forest for Amount Prediction

Training the randomForest model to predict transaction amounts.

Variable importance assessment (varImpPlot).

Final prediction and result comparison.

## Summary

The project performs a complete transaction analysis process – from initial exploration, through data cleaning, to building classification and regression models. Both classic decision trees and Random Forest were used to predict transaction amounts. The classification model allows analyzing which transactions may be declined by the bank, while the regression model helps estimate transaction values.


#### The project was developed as part of a university project


