---
layout: page
title: "Ad-Hoc Analysis: User Segmentation for Partnership Reporting"
subtitle: Defining and quantifying student and graduate segments using multi-table SQL joins
---

## Table of Contents

- [Project Overview](#project-overview)
- [Business Context](#business-context)
- [Analytical Approach](#analytical-approach)
- [Data Source Identification](#data-source-identification)
- [Metric Definitions](#metric-definitions)
- [SQL Implementation](#sql-implementation)
- [Results & Insights](#results--insights)
- [Skills Demonstrated](#skills-demonstrated)

---

## Project Overview

**Type:** Ad-hoc analytical request  
**Duration:** 3 days  
**Requester:** Senior Partnerships Manager  
**Purpose:** External partner reporting (technology skills provider partnership)  
**Tools:** SQL, Databricks, Excel

---

## Business Context

### The Request

A technology skills provider partner needed demographic data about SEEK's user base for their 2025 annual reporting:

**Primary Question:**  
"What percentage of students and unemployed graduates in our user base engaged with [partner's] content in 2025?"

**Additional Request (Not Feasible):**  
"Estimate total learners under age 21 on the platform."

**Constraint:**  
Age is not available in the current analytics base (field removed), so I could not produce an age-based estimate. I communicated this limitation and proceeded with student/unemployed graduate segmentation using education and work-history proxies instead.

**Why This Matters:**
- Partner needed data to demonstrate reach and impact in their annual report
- Required accurate segmentation of users by employment and education status
- Data would inform future partnership decisions and content strategy
- Time-sensitive: Needed for Q1 2026 reporting cycle

**Challenges:**
- Age-based segmentation was not possible due to age field removal from analytics base
- No pre-defined "student" / "unemployed graduate" segments available out-of-the-box
- Required joining engagement + career history + education history to define segments
- Needed defensible rules with NULL handling due to incomplete profiles

---

## Analytical Approach

### Step 1: Clarify definitions & scope
Before writing SQL, I aligned the request into clear, measurable definitions:
- What counts as **viewed content**
- How to classify **Student**, **Unemployed Graduate**, **Other**
- Time period: **2025**
- Output grain: **Country × Month**
- How to handle **incomplete profiles (NULLs)**

### Step 2: Identify minimum data required
Used the minimum set of tables needed to connect:
- content engagement → who viewed partner content
- career history → employment/workforce signals
- education history → student/graduate signals

### Step 3: Implement conservative segmentation rules
Implemented defensible rules using CASE WHEN with explicit NULL handling (detailed in SQL section).

### Step 4: Validate and sanity-check
- Spot-checked sample profiles for logic correctness
- Ensured segment counts reconcile (segment % sums to 100% per country/month)
- Reviewed outliers (e.g., small markets with very low volumes)

### Step 5: Deliver results + documented caveats
Delivered a country + monthly breakdown with clear assumptions and limitations for stakeholder reporting.

---

---

## Data Source Identification

Three tables were required to link content views to education and workforce signals:

### 1) Content Engagement (Views)
**Purpose:** Identify users who viewed partner content in 2025  
**Key fields:** `candidate_id`, `date`, `country`, `event_name`, `content_provider_meta`  
**Notes:** Used as the anchor dataset (all viewers retained)

### 2) Candidate Career History
**Purpose:** Determine workforce/employment signal  
**Key fields:** `candidate_id`, `has_workhistory`, `is_new_to_workforce`  
**Notes:** Profile completeness varies; used conservative rules

### 3) Candidate Education History
**Purpose:** Determine student vs graduate signal  
**Key fields:** `candidate_id`, `is_course_completed`, `course_completed_year`  
**Notes:** Users may have multiple records; NULLs handled conservatively

### Join Strategy
Used **LEFT JOINs** to keep all content viewers even if career/education data is missing.

---

---

## Metric Definitions

### Viewed Content (2025)
A user is counted as a viewer if they triggered the relevant view event for content where the provider metadata matches the partner name.

### User Segments (Conservative Rules)
- **Student:** course not completed (or missing) AND expected completion year ≥ 2026 (or missing) AND no work history  
- **Unemployed Graduate:** course completed (or missing) AND completion year < 2026 (or missing) AND no work history AND new-to-workforce flag in ('yes','undetermined')  
- **Other:** everyone else

### Output Grain
- **Geography:** Country  
- **Time:** Month (within 2025)  
- **Grain:** Country × Month

### Outputs Produced
- Total unique viewers
- Viewer counts by segment
- Segment percentages per country/month

---

### Assumptions & Limitations

**Assumptions Made:**
1. Users with `has_workhistory = FALSE` are genuinely unemployed (not just incomplete profiles)
2. `course_completed_year >= 2026` indicates current student
3. `is_new_to_workforce` flag is reasonably accurate for recent graduates
4. Video view events accurately represent content engagement

**Known Limitations:**
1. **Profile completeness:** Not all users complete education/work sections
2. **Data freshness:** Users may not update profiles after status changes
3. **Part-time work ambiguity:** Students with casual jobs may be misclassified
4. **Self-reported data:** All profile data is user-submitted, not verified

**Mitigation:**
- Documented all assumptions in methodology notes
- Provided data quality caveats with results
- Enabled stakeholder to understand confidence level
- Suggested follow-up analyses to validate findings

**Reported to Stakeholder:**  
"These estimates are based on available profile data. Actual percentages may vary due to profile completeness (~X% of users have complete education/work data)."

**Sample Output Structure:**

---

## SQL Implementation

### Query Structure

Used multi-level CTEs to organize complex logic and make the analysis maintainable and understandable.

### Complete SQL Query (Anonymized)

```sql
-- Ad-Hoc Analysis: Student and Unemployed Graduate Segmentation
-- Purpose: Quantify user segments for partnership reporting
-- Date Range: 2025 full year
-- Requester: Senior Partnerships Manager

WITH content_viewers AS (
    -- Identify users who viewed partner content in 2025
    SELECT 
        candidate_id,
        date,
        country,
        event_name,
        content_provider_meta
    FROM dataplatform.content_analytics.content_engagement_events
    WHERE 
        LOWER(content_provider_meta) LIKE '%technology_partner%'
        AND event_name = 'video_viewed'
        AND YEAR(date) = '2025'
), 

career_history AS (
    -- Get employment and work history data
    SELECT 
        candidate_id,
        is_new_to_workforce,
        current_company_name,
        profile_title,
        previous_company_name,
        has_workhistory,
        has_2_or_more_workhistory,
        has_education
    FROM dataplatform.dimensions.dim_candidate
),

education_history AS (
    -- Get education completion status and timeline
    SELECT 
        candidate_id,
        is_course_completed,
        course_completed_year,
        course_completed_month,
        course_level,
        institution_name,
        course_name
    FROM dataplatform.candidate_mgmt.candidate_education
    WHERE 
        is_course_completed IN ('Y', 'N')  -- Exclude completely missing education data
),

user_classification AS (
    -- Join all data sources and apply segmentation logic
    SELECT
        cv.candidate_id,
        cv.country,
        MONTH(cv.date) AS month,
        ch.is_new_to_workforce,
        ch.has_workhistory,
        ch.current_company_name,
        ch.profile_title,
        eh.is_course_completed,
        eh.course_completed_year,

        -- Segmentation Logic
        CASE 
            -- STUDENT: Currently enrolled, not yet graduated, no work history
            WHEN (eh.is_course_completed = 'N' OR eh.is_course_completed IS NULL)
                AND (eh.course_completed_year >= 2026 OR eh.course_completed_year IS NULL)
                AND ch.has_workhistory = FALSE
            THEN 'Student'

            -- UNEMPLOYED GRADUATE: Graduated, new to workforce, no work history
            WHEN (eh.is_course_completed = 'Y' OR eh.is_course_completed IS NULL)
                AND (eh.course_completed_year < 2026 OR eh.course_completed_year IS NULL)
                AND ch.has_workhistory = FALSE
                AND ch.is_new_to_workforce IN ('yes', 'undetermined')
            THEN 'Unemployed Graduate'

            -- OTHER: Employed, unclear status, or doesn't match criteria
            ELSE 'Other'
        END AS user_type

    FROM content_viewers cv
    LEFT JOIN career_history ch ON cv.candidate_id = ch.candidate_id
    LEFT JOIN education_history eh ON ch.candidate_id = eh.candidate_id
)

-- Final aggregation by country, month, and user type
SELECT 
    country,
    month,
    
    -- Total user counts
    COUNT(DISTINCT candidate_id) AS total_users,
    
    -- Segment counts
    COUNT(DISTINCT CASE WHEN user_type = 'Student' THEN candidate_id END) AS students,
    COUNT(DISTINCT CASE WHEN user_type = 'Unemployed Graduate' THEN candidate_id END) AS unemployed_graduates,
    COUNT(DISTINCT CASE WHEN user_type = 'Other' THEN candidate_id END) AS other,
    
    -- Segment percentages
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN user_type = 'Student' THEN candidate_id END) 
        / COUNT(DISTINCT candidate_id), 2) AS pct_students,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN user_type = 'Unemployed Graduate' THEN candidate_id END) 
        / COUNT(DISTINCT candidate_id), 2) AS pct_unemployed_graduates,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN user_type = 'Other' THEN candidate_id END) 
        / COUNT(DISTINCT candidate_id), 2) AS pct_other
    
FROM user_classification
GROUP BY country, month
ORDER BY country, month;
```
### Key SQL Techniques Used

**1. Multi-Level CTEs for Modularity**
```sql
WITH content_viewers AS (...),
     career_history AS (...),
     education_history AS (...),
     user_classification AS (...)
```
- Each CTE handles one logical step
- Easy to test and validate individually
- Readable and maintainable

**2. Complex CASE WHEN for Segmentation**
- Nested conditions with AND/OR logic
- NULL handling at multiple decision points
- Clear business rule implementation

**3. Conditional Aggregation**
```sql
COUNT(DISTINCT CASE WHEN user_type = 'Student' THEN candidate_id END)
```
- Calculate multiple segments in single GROUP BY
- Efficient alternative to multiple queries or subqueries

**4. LEFT JOIN for Data Completeness**
- Preserves all content viewers even with incomplete profiles
- Allows analysis of profile completion rates
- Handles one-to-many relationships (multiple education records)

#### Query Validation
- **Spot checks:** manually reviewed 10–15 candidate profiles to confirm segmentation logic (including NULL/edge cases)
- **Reconciliation:** verified segment counts reconcile and percentages sum to 100% for each country × month row
- **Sanity checks:** reviewed outliers and month-to-month trends to confirm results were plausible
- 
**Validation Result:** Logic confirmed accurate, no data quality issues requiring query modification

---

## Results & Insights

### Overall Findings

**Analysis Period:** January - December 2025  
**Geographic Scope:** 8 markets (AU, NZ, SG, MY, PH, ID, HK, TH)  
**Total Content Viewers Analyzed:** ~150,000+ unique users across all markets and months

### Aggregate Results by Market

**Sample Results (Anonymized Numbers):**
*Note: Results below are anonymized for confidentiality (values scaled/modified while preserving relative patterns across markets).*

| Country | Total Content Viewers | Students | Unemployed Graduates | Other | % Students | % Unemployed Grads | % Other |
|---------|----------------------|----------|----------------------|-------|------------|--------------------|---------|
| AU | 82.5k | 4.8k | 3.5k | 70k | 5.82% | 4.24% | 89.94% |
| SG | 90k | 13k | 1.5k | 50k | 14.44% | 1.67% | 83.89% |
| MY | 50k | 7.1k | 4k | 45k | 14.20% | 8.00% | 77.80% |
| PH | 63k | 9k | 2.5k | 42k | 14.29% | 3.97% | 81.76% |
| ID | 75k | 16k | 1.2k | 58k | 21.33% | 1.60% | 77.07% |
| NZ | 8k | 150 | 90 | 7k | 1.88% | 1.13% | 97.00% |
| HK | 190 | 10 | 0 | 300 | 5.26% | 0.00% | 94.74% |
| TH | 5k | 150 | 30 | 5k | 3.00% | 0.60% | 96.40% |

**Key Insights:**

**1. Geographic Variation in Student Engagement**
- **Highest student %:** Indonesia (21.94%), Philippines (15.30%), Malaysia (15.35%)
- **Lowest student %:** New Zealand (2.21%), Australia (5.05%), Hong Kong (5.26%)
- **Insight:** Southeast Asian markets show significantly higher student engagement with content

**2. Unemployed Graduate Engagement**
- **Highest unemployed grad %:** Malaysia (8.78%), Philippines (4.48%), Australia (4.01%)
- **Lowest unemployed grad %:** Hong Kong (0.00%), Thailand (0.55%), New Zealand (1.11%)
- **Insight:** Malaysia shows notably high unemployed graduate engagement

**3. Market-Specific Patterns**
- **AU/NZ (Developed markets):** Lower student/graduate percentages, majority "Other" (employed users)
- **SEA markets (Emerging):** Higher student percentages, active upskilling behavior
- **Mature professionals dominant:** 75-97% of viewers categorized as "Other" across all markets

**4. Temporal Trends (Monthly Analysis)**
Based on monthly breakdown:
- **Peak student engagement:** September-November (university semester periods)
- **Graduate engagement:** Relatively stable year-round
- **Seasonal patterns:** Aligned with academic calendars in respective markets

---

## Skills Demonstrated

**SQL & Data Analysis:**
- Advanced SQL (multi-level CTEs, complex CASE WHEN logic, LEFT JOINs)
- User segmentation methodology
- Data quality assessment
- Metric definition and validation

**Business Analysis:**
- Requirements clarification with stakeholders
- Translating ambiguous business questions into clear analytical framework
- Defining defensible business rules for edge cases
- Communicating technical results to non-technical audience

**Documentation:**
- Analytical methodology documentation
- SQL code commenting and documentation
- Results presentation with data quality caveats
- Knowledge base article creation

**Tools:**
- SQL, Databricks, Excel

---

[← Back to Projects](/projects.md)
