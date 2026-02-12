---
layout: page
title: Projects
subtitle: Data Analytics & Machine Learning Work
---

## Professional Work at SEEK

### 1. Career Hub Dashboard Optimization: Migration & Performance Improvement

**Challenge:** Career Hub Experiment tracking dashboard took several days to load and consumed excessive Databricks resources, impacting other users. Root cause: inefficient data structure with 21 separate SQL queries hitting generic shared tables in production.

**Solution:** Migrated to improved analytical structure → consolidated query set → rebuilt & validated Databricks dashboard (public details summarized due to confidentiality)

**Impact:**
- Reduced load time by **70%+** (days → 3-8 minutes)
- Decreased database CPU usage by ~60%
- Eliminated resource contention affecting other Databricks users
- Improved maintainability and created reusable analytical foundation

**Skills:** SQL optimization, data migration, CTEs, performance tuning, dimensional modeling, Databricks dashboards, technical documentation

**📄 [View detailed technical case study →](/career-hub-optimization.md)**

---

### 2. End-to-End Dashboard Development
**Objective:** Build analytics dashboard for stakeholder decision-making from scratch.

**Process:**
- Gathered requirements from product and business teams
- Designed data models and calculated fields
- Built Tableau visualizations with custom calculations
- Created cohesive narrative flow for insights
- Deployed and validated with stakeholders

**Impact:** Enabled real-time KPI monitoring and data-driven decision making

**Skills:** Requirements gathering, data modeling, Tableau, stakeholder management

**📄 [View detailed case study →](/skills-content-dashboard.md)**

---

### 3. User Segmentation Analysis
**Business Question:** "How many students and graduates who are unemployed viewed Microsoft-related content?"

**Approach:**
- Identified relevant data sources and tables
- Created analytical documentation defining metrics
- Wrote complex SQL with CTEs and CASE WHEN for segmentation
- Calculated engagement percentages across categories
- Documented methodology and findings in Confluence

**Skills:** SQL (CTEs, conditional logic), metric definition, documentation

**📄 [View detailed technical case study →](/user-segmentation-analysis.md)**

---
### 4. Technical Documentation & Data Governance
**Deliverables:**
- Data flow diagrams showing relationships between data sources
- Dashboard documentation (metrics, terminologies, tracking logic)
- Technical documentation (query logic, migration steps, change logs)
- User guides and knowledge base articles

**Impact:** Improved team knowledge sharing, faster onboarding, reduced repetitive questions

**Tools:** Confluence, Excel, Miro, Markdown

---

## Academic Projects

### HomeCheck: ML-Powered Home Inspection Assistant
**Description:** CNN-based image classification system to identify common home defects using computer vision.

**Technical Details:**
- Curated and preprocessed **~10,000 images** with data augmentation
- Evaluated multiple CNN architectures (MobileNetV2, EfficientNet, ResNet50)
- Tested various optimizers and learning rates
- Deployed **MobileNetV2 with Adam optimizer** achieving **98% accuracy**
- Built Flask web application with HTML/CSS interface

**GitHub:** [View Project Repository](https://github.com/safiyyahsy/homecheck-ml)

**Skills:** Python, TensorFlow/Keras, CNN, model evaluation, hyperparameter tuning, Flask, web deployment

---

### Malaysia Population Forecasting with Time Series Analysis
**Description:** Forecasted Malaysia's population for 12 years using historical data and time series modeling to support policy planning insights.

**Technical Highlights:**
- Analyzed **55 years of population data** (1970-2024)
- Compared multiple models: Holt's Method, ARIMA, Log-ARIMA
- Selected **Log ARIMA(0,2,0)** as optimal (AIC = -449.45)
- Generated 12-year forecast projecting **~42.3M population by 2036**
- Validated model with comprehensive residual diagnostics

![Population Trend & Forecast](/assets/img/projects/malaysia-population/figure5-forecast-plots.png)  
_12-year population forecast using Holt's Method and ARIMA with 95% confidence intervals_

**Skills:** R (forecast, tseries packages), time series analysis, ARIMA modeling, Holt's Method, ACF/PACF analysis, model selection (AIC), residual diagnostics, statistical validation  
**My Role:** Time Series Modeling & Implementation (Group Project)  
**📄 [View detailed case study →](/malaysia-population-forecast.md)**

---

### U.S. Housing Price Index Forecasting with Multivariate Regression
**Description:** Built a multivariate regression model to forecast U.S. Housing Price Index (HPI) using macroeconomic indicators and validated the model through multicollinearity checks and residual diagnostics.

**Technical Highlights:**
- Modeled HPI using key macroeconomic indicators (SPI, CPI, POP, UNEMP, GDP, MR, RDI) and lag terms
- Performed exploratory time-series analysis and correlation assessment to understand relationships and potential multicollinearity
- Ran VIF screening and iterative model reduction to improve stability and interpretability
- Achieved **Adjusted R² = 0.9988** with statistically significant predictors
- Validated assumptions using residual tests (normality, independence, homoscedasticity, autocorrelation)
- Produced forecasts with **95% confidence intervals**

![Actual vs Predicted (Log HPI)](/assets/img/projects/us-housing/fig5-actual-vs-predicted.png)  
_Actual vs predicted U.S. Housing Price Index (log scale) showing strong model fit._

**Skills:** R, multivariate regression, log transformation, lag features, VIF analysis, correlation analysis, residual diagnostics, forecasting with confidence intervals  
**My Role:** Statistical Modeling & Implementation (Group Project)

**📄 [View detailed case study →](/us-housing-price-forecast.md)**

---

### Restaurant Review Sentiment Analysis with Web Scraping & NLP
**Description:** Built automated data collection pipeline and delivered clean dataset for sentiment classification achieving 98.83% accuracy.

**Technical Approach:**
- **Data Collection (My Focus):**
  - Developed **Python web scraping pipeline** using Playwright to extract Google Reviews
  - Automated extraction of **686 reviews** including:
    - Review text content
    - Star ratings (1-5)
    - Timestamps and reviewer metadata
  - Handled dynamic page loading, pagination, and anti-scraping measures
  - Cleaned and structured data for downstream NLP processing

- **Team's Sentiment Modeling (Using My Dataset):**
  - Text preprocessing in RapidMiner (tokenization, stopword removal, stemming, n-grams)
  - Applied **SMOTE (Synthetic Minority Oversampling)** to handle class imbalance
  - Compared classification models: k-NN, Naive Bayes, **SVM**

**Key Results:**
- Successfully delivered clean, structured dataset with 686 validated records
- Enabled team's **SVM model to achieve 98.83% accuracy** (678/686 correctly classified)
- Demonstrated end-to-end data pipeline from collection to model-ready format

**Skills:** Python (Playwright), web scraping, data cleaning, automated data collection, API handling, data pipeline design

**My Role:** Data Collection Lead (Group Project)

---

### Airline Passenger Satisfaction Dashboard (PowerBI)
**Description:** Interactive business intelligence dashboard analyzing 129K+ passenger records to identify service improvement opportunities.

**Technical Approach:**
- **Data Preprocessing:**
  - Cleaned **129,880 passenger records** from Kaggle dataset
  - Handled missing values and outliers using WEKA
  - Data validation and normalization in Excel

- **Dashboard Development:**
  - Built **5-page interactive PowerBI report**:
    - Overview Dashboard (KPIs and summary metrics)
    - Check-in Experience Analysis
    - Flight Service Quality Breakdown
    - On-board Services Performance
    - Satisfaction Drivers & Segmentation
  - Implemented **15+ visualizations** (pie/donut charts, treemaps, stacked bars, KPI cards)
  - Created dynamic slicers for gender, class, and satisfaction filtering
  - Designed for executive-level decision making

**Key Insights Delivered:**
- Identified **lowest-rated services**: In-flight Wi-Fi, online booking ease, food/drink quality
- **Most impacted segment**: Economy Plus passengers
- **High performers**: Baggage handling, departure/arrival time convenience
- Provided actionable recommendations for service prioritization

**Skills:** PowerBI (DAX measures, data modeling, interactive visualizations), Excel, WEKA, data preprocessing, dashboard design, business storytelling

---

---

### KRISTA Database System
**Description:** Student registration system built on Oracle APEX with normalized relational database design.

**Features:**
- Normalized database schema (3NF)
- Data entry forms with validation
- Entity Relationship Diagrams (ERD)

**Tools:** Oracle APEX, SQL, Database Design

---

## SQL Code Samples

Want to see my SQL skills in action?  
- **SQL snippets (public):** [SQL samples](sql-samples.md)  
- **Mini SQL Lab (mock, runnable):** https://github.com/safiyyahsy/sfyhportfolio/tree/main/mini-sql-lab

Examples include:
- segmentation with `case when`
- cohorting with ctes and date functions
- data quality checks (`union all`)
- joins + conditional aggregation
- multi-grain output via `union all`

---

## Contact Me

📧 [Email](mailto:safiyyahsy28@gmail.com)  
💼 [LinkedIn](https://www.linkedin.com/in/nsin28/)  
📂 [Download Resume](NurSafiyyahInsyirahNordin.pdf)
