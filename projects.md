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

**Skills:** R (forecast, tseries packages), time series analysis, ARIMA modeling, Holt's Method, ACF/PACF analysis, model selection (AIC), residual diagnostics, statistical validation  
**My Role:** Time Series Modeling & Implementation (Group Project)  
**📄 [View detailed case study →](/malaysia-population-forecast.md)**

---

### U.S. Housing Price Index Forecasting with Multivariate Regression
**Description:** Built a multivariate regression model to forecast U.S. Housing Price Index (HPI) using macroeconomic indicators and validated the model through multicollinearity checks and residual diagnostics.

**Technical Highlights:**
- Modeled HPI using macroeconomic indicators (SPI, CPI, POP, UNEMP, GDP, MR, RDI) with lag terms
- Assessed relationships via exploratory analysis and correlation matrix
- Reduced multicollinearity using **VIF screening** and iterative model refinement
- Achieved **Adjusted R² = 0.9988** with statistically significant predictors
- Validated assumptions using residual tests (normality, independence, homoscedasticity, autocorrelation)
- Produced forecasts with **95% confidence intervals**

**Skills:** R, multivariate regression, log transformation, lag features, VIF analysis, correlation analysis, residual diagnostics, forecasting with confidence intervals  
**My Role:** Statistical Modeling & Implementation (Group Project)  
**📄 [View detailed case study →](/us-housing-price-forecast.md)**

---

### NakNak Restaurant Review Sentiment Analysis (Web Scraping)
**Description:** Built an automated data collection pipeline to scrape Google Reviews and deliver a clean dataset for downstream sentiment analysis.

**Technical Highlights:**
- Developed a **Python (Playwright)** scraper to extract review text, ratings, and dates across multiple branches
- Cleaned and structured the dataset to support NLP preprocessing and classification workflows
- Enabled team sentiment modeling (k-NN / Naive Bayes / SVM); best reported result: **98.83% accuracy (SVM with SMOTE)**

**Skills:** Python (Playwright), web scraping, data cleaning, dataset preparation  
**My Role:** Data Collection Lead (Group Project)  
**📄 [View detailed case study →](/naknak-sentiment-analysis.md)**

---

### Airline Passenger Satisfaction Dashboard (PowerBI)
**Description:** Built an interactive PowerBI dashboard to analyze passenger satisfaction across service touchpoints and identify key drivers of dissatisfaction.

**Technical Highlights:**
- Analyzed **129,880** passenger records with multi-page drill-down reporting
- Designed KPI overview + segmentation views with interactive filtering (gender, class, satisfaction)
- Surfaced actionable service improvement areas (e.g., Wi‑Fi, online booking, food/drink)

**Skills:** PowerBI, dashboard design, KPI reporting, segmentation analysis, data cleaning  
**📄 [View detailed case study →](/airline-satisfaction-dashboard.md)**

---

### KRISTA Student Registration System (Oracle APEX)
**Description:** Designed and built a database-driven registration system for a kindergarten franchise to replace manual logbooks and paper records.

**Technical Highlights:**
- Designed normalized relational database (up to **3NF**) and ERD covering core entities (Student, Parent, Registration, Class, Teacher, Package, Fees, Receipts)
- Implemented the application in **Oracle APEX** with data entry forms, validations, and reporting dashboards
- Produced SQL scripts (DDL/DML), integrity constraints (PK/FK), and documentation (data dictionary) to ensure consistent and reliable records

**Skills:** Oracle APEX, SQL, database design, ERD, normalization (1NF–3NF), data integrity constraints, reporting/dashboarding  
**📄 [View detailed case study →](/krista-database-system.md)**

---

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
