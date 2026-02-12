---
layout: page
title: U.S. Housing Price Index Forecasting
subtitle: Multivariate Regression with Macroeconomic Indicators (R)
---

## Project Overview
Built a multivariate regression model to forecast the U.S. Housing Price Index (HPI) using macroeconomic indicators. The work focused on selecting interpretable predictors, managing multicollinearity, validating assumptions, and producing forecast intervals.

## Variables & Data
The dependent variable is **Housing Price Index (HPI)**. Candidate predictors include:
- Stock Price Index (SPI)
- Consumer Price Index (CPI)
- Population (POP)
- Unemployment Rate (UNEMP)
- Real Gross Domestic Product (GDP)
- Mortgage Rate (MR)
- Real Disposable Income (RDI)

![Time Series Plots](/assets/img/projects/us-housing/fig2-1-timeseries.png)
*Time series plots of HPI and macroeconomic indicators (1975–2021).*

![Variables Table](/assets/img/projects/us-housing/table2-1-variables.png)
*Summary of variables and expected relationships with HPI.*

## Exploratory Analysis
To understand relationships and potential feature redundancy, I analyzed correlation patterns across variables.

![Correlation Matrix](/assets/img/projects/us-housing/fig2-2-correlation-matrix.png)
*Pearson correlation matrix indicating strong relationships and multicollinearity risk among some predictors.*

## Modeling Approach
**Method:** Multivariate Linear Regression (with log transformation and lag terms)

Key steps:
1. **Log transformation** to stabilize variance and better linearize relationships.
2. **Lag feature engineering** (e.g., lagged HPI and lagged SPI) to capture temporal dependence.
3. **Multicollinearity management** using **VIF** and iterative model reduction.
4. **Model comparison** across multiple candidate specifications.
5. **Assumption validation** via residual tests (normality, independence, homoscedasticity, autocorrelation).

![VIF + Model Iterations](/assets/img/projects/us-housing/table4-1-vif-models.png)
*VIF screening, coefficient signs, p-values, and adjusted R² across initial/reduced models.*

## Model Validation
I validated key regression assumptions using residual diagnostic tests (e.g., AD test, Box test, Durbin-Watson, BP test).

![Residual Assumption Tests](/assets/img/projects/us-housing/table4-2-residual-tests.png)
*P-values for residual assumption checks across candidate models (Model 10 shown as final).*

## Forecast Results
The final model produced forecasts with confidence intervals and showed strong fit between actual and predicted values on the log scale.

![Forecast Table](/assets/img/projects/us-housing/table5-1-forecast.png)
*5-step ahead forecast with 95% confidence intervals (log scale).*

![Actual vs Predicted](/assets/img/projects/us-housing/fig5-1-actual-vs-predicted.png)
*Actual vs predicted U.S. Housing Price Index (log scale).*

## Key Results
- **Model performance:** **Adjusted R² = 0.9988**
- **Process rigor:** addressed multicollinearity (VIF), validated residual assumptions, and produced forecast intervals
- **Outcome:** an interpretable, validated regression model suitable for forecasting and scenario thinking

## Skills Demonstrated
- R (statistical modeling)
- Multivariate regression
- Log transformation & lag features
- Correlation analysis
- VIF-based multicollinearity handling
- Residual diagnostics & hypothesis testing
- Forecasting with confidence intervals

**My Role:** Statistical Modeling & Implementation (Group Project)

[← Back to Projects](/projects.md)
