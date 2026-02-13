### Malaysia Population Forecasting with Time Series Analysis

**Description:** Forecasted Malaysia's population for 12 years using historical data and time series modeling to support policy planning insights.

**Technical Approach:**
- Analyzed **55 years of population data** (1970-2024) from Department of Statistics Malaysia
- Performed stationarity testing using **ACF/PACF plots** to identify appropriate model structure
- Developed and compared multiple forecasting models:
  - Holt's Method (exponential smoothing with linear trend)
  - ARIMA models with various parameters
  - Log-transformed ARIMA to handle exponential growth patterns
- Selected **Log ARIMA(0,2,0)** and **Holt's Method** as best models based on:
  - **AIC (Akaike Information Criterion)**: -449.45 for Log ARIMA
  - Error measures (RMSE, MAE, MAPE)
  - Residual diagnostic tests (normality, independence, homoscedasticity)
- Generated 12-year forecast with 95% confidence intervals

---

#### **Exploratory Data Analysis**

![Malaysia Population Time Series](/assets/img/projects/malaysia-population/figure1-timeseries.png)
*Figure 1: Historical population trend (1970-2024) showing exponential growth pattern*

![Descriptive Statistics](/assets/img/projects/malaysia-population/table1-descriptive-stats.png)
*Table 1: Summary statistics - 55 observations from 10,882 to 34,059 (in thousands)*

![Boxplot Distribution Analysis](/assets/img/projects/malaysia-population/figure3-distribution.png)
![Histogram Distribution Analysis](/assets/img/projects/malaysia-population/figure4-distribution.png)
*Figures 3-4: Boxplot and histogram showing data distribution and identifying potential outliers*

---

#### **Stationarity Testing**

![ACF and PACF Plots](/assets/img/projects/malaysia-population/figure2-acf-pacf.png)
*Figure 2: (a) PACF and (b) ACF plots indicating non-stationarity - gradual decay in ACF suggests need for differencing*

---

#### **Model Comparison & Selection**

![Holt's Method Formula](/assets/img/projects/malaysia-population/holts-formula.png)
*Holt's Method equations: Level (Lt), Trend (Tt), and Forecast formula*

**Our optimal Holt's forecast equation:**  
ŷ(t+h) = 10562.8659 + 354.5528 × h

![Model Comparison - Fitted Values](/assets/img/projects/malaysia-population/table3-fitted-plots.png)
![Model Comparison - Fitted Values](/assets/img/projects/malaysia-population/table3.2-fitted-plots.png)
![Model Comparison - Fitted Values](/assets/img/projects/malaysia-population/table3.3-fitted-plots.png)
*Table 3: Actual vs Fitted values for all candidate models (Average, Naive, Holt's, ARIMA variants)*

![Statistical Validation](/assets/img/projects/malaysia-population/table2-pvalue-assumptions.png)
*Table 2: P-values for residual diagnostics - Log ARIMA(0,2,0) passes all assumption tests*

![Error Measures](/assets/img/projects/malaysia-population/table4-error-measures.png)
*Table 4: Error comparison across models - Log ARIMA(0,2,0) has lowest AIC (-449.45)*

---

#### **Residual Diagnostics (Best Models)**

![Holt's Residuals](/assets/img/projects/malaysia-population/table5-residuals-holts.png)
*Holt's Method residual checks: Q-Q plot shows near-normality; histogram and ACF confirm white noise*

![ARIMA Residuals](/assets/img/projects/malaysia-population/table6-residuals-arima.png)
*Log ARIMA(0,2,0) residual diagnostics: Normal Q-Q plot, histogram, and ACF showing good model fit*

![Additional Residual Plots](/assets/img/projects/malaysia-population/table6.2-residuals-arima.png)
*ACF of residuals and residual plots over time confirming model assumptions*

---

#### **12-Year Population Forecast**

![Forecast Table](/assets/img/projects/malaysia-population/table6-forecast-values.png)
*Table 6: Year-by-year population projections from 2025-2036 using both best models*
---

**Key Results:**
- **Best Models Identified:** Holt's Method and Log ARIMA(0,2,0)
- **Forecast Horizon:** 12 years (2025-2036)
- **Projected Population by 2036:** ~42.3-43.0 million (with confidence intervals)
- **Model Validation:** Residuals showed white noise pattern with no autocorrelation
- **All assumption tests passed:** Normality, independence, homoscedasticity

**Business Impact:**
- Provides actionable population growth projections for government resource planning
- Confidence intervals enable scenario planning (best/worst case)
- Model selection process demonstrates rigorous statistical methodology

---

**Skills Demonstrated:**
- **R Programming** (forecast, tseries packages)
- **Time Series Analysis** (trend identification, seasonality testing)
- **ARIMA Modeling** (parameter selection, differencing, log transformation)
- **Exponential Smoothing** (Holt's Linear Trend Method)
- **Model Diagnostics** (ACF/PACF, residual analysis, assumption testing)
- **Model Selection** (AIC, error measures, statistical tests)
- **Statistical Rigor** (p-value interpretation, hypothesis testing)
- **Data Visualization** (time series plots, diagnostic charts, forecast visualization)

**My Role:** Time Series Modeling & Implementation (Group Project)

---

[← Back to Projects](/projects.md)
