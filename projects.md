---
layout: page
title: Projects
subtitle: Data Analytics & Machine Learning Work
---

## Professional Work at SEEK

### 1. Career Hub Dashboard Optimization: Migration & Performance Improvement

**Challenge:** Career Hub Experiment tracking dashboard took several days to load and consumed excessive Databricks resources, impacting other users. Root cause: inefficient data structure with 21 separate SQL queries hitting generic shared tables in production.

**Phase 1: Data Migration & Restructuring**
- Analyzed current query structure and identified inefficiencies in data sources
- Designed purpose-built analytical tables optimized for dashboard requirements
- Mapped data transformations from generic tables to new analytical structure
- Migrated and validated queries on Databricks
- Documented mapping logic and migration process

**Phase 2: Query Consolidation & Optimization**
- Analyzed query execution plans to identify bottlenecks and redundant data fetches
- Consolidated 21 separate queries into 6 optimized queries (1 main + 5 supporting)
- Implemented CTEs to eliminate repeated logic and reduce complexity
- Leveraged new analytical tables to improve query performance

**Impact:**
- Reduced load time by **70%+** (days → 8 minutes)
- Decreased database CPU usage by ~60%
- Eliminated resource contention affecting other Databricks users
- Improved maintainability (consolidated queries vs 21 separate queries)
- Created reusable analytical tables for future dashboard development

**Skills:** SQL optimization, data migration, CTEs, query execution analysis, performance tuning, dimensional modeling, Databricks, Tableau, technical documentation

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

**GitHub:** [View Project Repository](https://github.com/safiyyahsy/homecheck) *(you'll add this link later)*

**Skills:** Python, TensorFlow/Keras, CNN, model evaluation, hyperparameter tuning, Flask, web deployment

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

Want to see my SQL skills in action? Check out my [SQL examples page](/sql-samples) with anonymized code demonstrating:
- Complex CTEs and window functions
- Query optimization techniques
- User segmentation logic
- Data validation queries

---

## Contact

Interested in discussing these projects or potential opportunities?

📧 [Email](mailto:safiyyahsy28@example.com)  
💼 [LinkedIn](www.linkedin.com/in/nsin28)  
📂 [Download Resume](link-to-resume) *(optional)*
