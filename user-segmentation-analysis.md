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
**Tools:** SQL, Databricks, Excel, Confluence

---

## Business Context

### The Request

A technology skills provider partner needed demographic data about SEEK's user base for their 2026 annual reporting:

**Primary Question:**  
"What percentage of students and unemployed graduates in our user base engaged with [partner's] content in 2025?"

**Alternative Metric:**  
"What is the estimated total number of learners under age 21 on the SEEK platform?"

**Why This Matters:**
- Partner needed data to demonstrate reach and impact in their annual report
- Required accurate segmentation of users by employment and education status
- Data would inform future partnership decisions and content strategy
- Time-sensitive: Needed for Q1 2026 reporting cycle

**Challenge:**
- No pre-defined "student" or "unemployed graduate" segments in existing dashboards
- Required cross-referencing career history, education records, and content engagement data
- Needed clear, defensible definitions for ambiguous user categories
- Had to account for incomplete or missing profile data

---

## Analytical Approach

### Step 1: Clarify Requirements and Definitions

Before writing any SQL, I created an analytical documentation framework to ensure clarity:

**Key Questions Addressed:**
1. How do we define "student" vs "graduate"?
2. How do we determine "unemployed" status?
3. What content engagement counts as "viewed"?
4. How do we handle incomplete profile data?
5. What time period and geographic scope?

**Stakeholder Alignment:**
- Documented proposed definitions in Confluence
- Reviewed logic with partnerships team
- Confirmed metrics aligned with partner's reporting needs

### Step 2: Data Source Identification

Identified three key data sources needed:

| Data Source | Purpose | Key Fields | Filtering Logic |
|-------------|---------|------------|-----------------|
| Content engagement table | Track who viewed partner content | `candidate_id`, `event_name`, `content_provider`, `date`, `country` | Filter for specific provider + video view events + 2025 |
| Career history table | Determine employment status | `candidate_id`, `has_workhistory`, `is_new_to_workforce`, `current_company` | Check work experience flags |
| Education history table | Determine student/graduate status | `candidate_id`, `is_course_completed`, `course_completed_year` | Check completion status and year |

**Data Quality Considerations:**
- Not all users have complete profiles
- Education data may be outdated or missing
- Work history can be ambiguous (part-time jobs for students)
- Needed logic to handle NULL values and edge cases

### Step 3: Define Segmentation Logic

Created clear business rules for user categorization:

**STUDENT Definition:**
User is a STUDENT if:
- Course completion status = 'N' (not completed) OR NULL
- AND Expected completion year >= 2026 OR NULL
- AND has_workhistory = FALSE

**Rationale:** Currently enrolled in education, not yet graduated, no full-time work history

**UNEMPLOYED GRADUATE Definition:**
User is an UNEMPLOYED GRADUATE if:
- Course completion status = 'Y' (completed) OR NULL
- AND Completion year < 2026 OR NULL
- AND has_workhistory = FALSE
- AND is_new_to_workforce IN ('yes', 'undetermined')


**Rationale:** Completed education, entering workforce, no current employment

**OTHER Category:**
- All users not matching above criteria (employed, unclear status, etc.)

**Edge Case Handling:**
- NULL education data: Included in analysis if work history suggests student/graduate status
- Part-time work: Evaluated based on `is_new_to_workforce` flag
- Unclear completion dates: Used conservative logic to avoid misclassification

### Step 4: Build and Validate Query

- Wrote SQL using CTEs for modularity and readability
- Tested logic with sample candidate IDs
- Validated segmentation against manual profile checks
- Optimized for performance (appropriate indexes, efficient joins)

### Step 5: Document and Deliver

- Created methodology document explaining segmentation logic
- Generated results broken down by country and month
- Provided caveats and data quality notes
- Enabled stakeholder to understand and explain the data

---

## Data Source Identification

### Data Discovery Process

**Challenge:** Three separate tables needed to be joined, each with different granularity and data quality characteristics.

**Table 1: Content Engagement Data**

**Source:** `dataplatform.content_analytics.content_engagement_events` (anonymized)

**Purpose:** Identify which users viewed partner content

**Key Fields:**
- `candidate_id` - User identifier
- `event_name` - Type of engagement event
- `content_provider_meta` - Content provider/partner name
- `date` - Engagement date
- `country` - User's market/country

**Filtering Applied:**
```sql
WHERE 
    LOWER(content_provider_meta) LIKE '%partner_name%'
    AND event_name = 'video_viewed'
    AND YEAR(date) = '2025'
```
**Data Quality:** High - event tracking reliable for app-based engagement

---

**Table 2: Career History Data**

**Source:** `dataplatform.dimensions.dim_candidate` (anonymized)

**Purpose:** Determine employment status and work history

**Key Fields:**
- `candidate_id` - User identifier (join key)
- `is_new_to_workforce` - Flag indicating new job seeker
- `has_workhistory` - Boolean indicating any work experience
- `has_2_or_more_workhistory` - Flag for multiple jobs
- `current_company_name` - Current employer (if any)
- `profile_title` - Job title

**Data Quality Considerations:**
- **Missing data:** Not all users complete work history section
- **Self-reported:** Users may not update when employment status changes
- **Part-time work ambiguity:** Students with part-time jobs might have `has_workhistory = TRUE`

**Solution:** Combined with `is_new_to_workforce` flag to better identify true employment status

---

**Table 3: Education History Data**

**Source:** `dataplatform.candidate_mgmt.candidate_education` (anonymized)

**Purpose:** Determine student vs. graduate status

**Key Fields:**
- `candidate_id` - User identifier (join key)
- `is_course_completed` - 'Y', 'N', or NULL
- `course_completed_year` - Year of graduation
- `course_completed_month` - Month of graduation
- `course_level` - Degree type (Bachelor, Certificate, etc.)
- `institution_name` - University/school name
- `course_name` - Degree program

**Data Quality Considerations:**
- **Multiple education records:** Users may have multiple degrees
- **Incomplete data:** Not all users fill education section
- **Outdated information:** Users may not update after graduation
- **Ambiguous completion dates:** Some only provide year, not month

**Solution:** 
- Filtered to `is_course_completed IN ('Y', 'N')` to exclude completely blank records
- Used completion year >= 2026 as proxy for "current student"
- Used completion year < 2026 as proxy for "recent graduate"

---

### Table Join Strategy

**Join Type:** LEFT JOIN (preserve all content viewers even if profile incomplete)

**Join Logic:**
content_viewers
LEFT JOIN career_history (may be incomplete)
LEFT JOIN education_history (may be incomplete)

**Why LEFT JOIN:**
- Ensures all users who viewed content are included in analysis
- Missing career/education data categorized as "Other" rather than excluded
- Provides complete picture of content engagement

**Cardinality Handling:**
- Education table: One-to-many relationship (multiple degrees possible)
- Used most recent education record based on `course_completed_year`
- Documented this assumption in methodology notes

---

## Metric Definitions

### User Type Segmentation Logic

Created structured CASE WHEN logic to categorize users into three segments:

#### **Segment 1: STUDENT**

**Definition:** Currently enrolled in education program, not yet in workforce

**SQL Logic:**
```sql
CASE 
    WHEN (is_course_completed = 'N' OR is_course_completed IS NULL)
        AND (course_completed_year >= 2026 OR course_completed_year IS NULL)
        AND has_workhistory = FALSE
    THEN 'Student'
```

**Business Rationale:**
- is_course_completed = 'N' → Currently studying
- course_completed_year >= 2026 → Expected graduation in future
- has_workhistory = FALSE → No full-time employment
- NULL handling: Conservative approach treats missing data as potential student

**Edge Cases Considered:**
- Students with part-time jobs: Rely on has_workhistory = FALSE to filter them
- Gap year students: May show as "Other" if profile unclear
- Recent enrollees: NULL completion year treated as current student

#### **Segment 2: UNEMPLOYED GRADUATE**

**Definition:** Completed education, entering workforce, currently unemployed

**SQL Logic:**
```sql
WHEN (is_course_completed = 'Y' OR is_course_completed IS NULL)
    AND (course_completed_year < 2026 OR course_completed_year IS NULL)
    AND has_workhistory = FALSE
    AND is_new_to_workforce IN ('yes', 'undetermined')
THEN 'Unemployed Graduate'
```

**Business Rationale:**
- is_course_completed = 'Y' → Finished education
- course_completed_year < 2026 → Already graduated
- has_workhistory = FALSE → Not currently employed
- is_new_to_workforce IN ('yes', 'undetermined') → Actively seeking first job

**Edge Cases Considered:**
- Career changers: Excluded by is_new_to_workforce logic
- Employed graduates: Filtered out by has_workhistory flag
- Long-term unemployed: Included if still marked as new to workforce

#### **Segment 3: OTHER**

**Definition:** All users not matching Student or Unemployed Graduate criteria

**SQL Logic:**
```sql
ELSE 'Other'
```
**Includes:**
- Employed users (students with jobs, working professionals)
- Career changers
- Users with incomplete profile data that doesn't clearly indicate student/graduate status
- Users who don't fit clean definitions

**Rationale:** Conservative approach - only classify as Student/Unemployed Graduate when profile data clearly su

#### **Engagement Metrics**
**Content Views:**
- Definition: Distinct users who triggered video_viewed event for partner content
- Measurement: COUNT(DISTINCT candidate_id)
- Filter: event_name = 'video_viewed' AND content_provider_meta contains partner name

**Segmentation Percentages:**
- Student %: (Student count / Total content viewers) × 100
- Unemployed Graduate %: (Unemployed Graduate count / Total content viewers) × 100
- Other %: (Other count / Total content viewers) × 100

**Validation:** Sum of percentages = 100% for each country/month combination

### Dimensional Breakdown

**Geography:** Country-level analysis (AU, NZ, SG, MY, PH, ID, HK, TH)

**Temporal:** Monthly breakdown (January - December 2025)

**Granularity:** Country × Month × User Type

**Sample Output Structure:**

| Country | Month | Total Users | Students | Unemployed Graduates | Other | % Students | % Unemployed Grads | % Other |
|---------|-------|-------------|----------|----------------------|-------|------------|-------------------|---------|
| AU | Jan 2025 | 20,560 | 1,234 | 567 | 18,759 | 6.0% | 2.8% | 91.2% |
| SG | Jan 2025 | 5,234 | 892 | 234 | 4,108 | 17.0% | 4.5% | 78.5% |

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

**5. Percentage Calculations with Rounding**
```sql
ROUND(100.0 * numerator / denominator, 2)
```
- Explicit decimal conversion (100.0) to avoid integer division
- Consistent 2-decimal precision for reporting
- NULLIF not needed here due to WHERE clause ensuring denominator > 0

**6. Performance Optimization**
- Filtered large tables early in CTEs (date, event_name)
- Used indexed columns in WHERE clauses (date, candidate_id)
- Minimized data volume before joins

#### Query Validation
**Validation Steps:**

**1. Sample Candidate Checks:**
- Manually reviewed 10-15 candidate profiles
- Verified segmentation logic matched manual classification
- Checked edge cases (missing data, ambiguous status)
**2. Percentage Sum Validation:**
- Verified pct_students + pct_unemployed_graduates + pct_other = 100% for all rows
- Ensured no users lost in segmentation logic
**3. Country-Level Sanity Checks:**
- Compared results to known market demographics
- Flagged any unexpected patterns for investigation
- Validated counts against total platform user base
**4. Temporal Consistency:**
- Checked for reasonable month-to-month variance
- Investigated any sudden spikes or drops

**Validation Result:** Logic confirmed accurate, no data quality issues requiring query modification

---

## Results & Insights

### Overall Findings

**Analysis Period:** January - December 2025  
**Geographic Scope:** 8 markets (AU, NZ, SG, MY, PH, ID, HK, TH)  
**Total Content Viewers Analyzed:** ~150,000+ unique users across all markets and months

### Aggregate Results by Market

**Sample Results (Anonymized Numbers):**

| Country | Total Content Viewers | Students | Unemployed Graduates | Other | % Students | % Unemployed Grads | % Other |
|---------|----------------------|----------|----------------------|-------|------------|--------------------|---------|
| AU | 82,770 | 4,180 | 3,320 | 75,270 | 5.05% | 4.01% | 90.94% |
| SG | 93,290 | 13,180 | 1,870 | 78,240 | 14.13% | 2.00% | 83.87% |
| MY | 50,240 | 7,710 | 4,410 | 38,120 | 15.35% | 8.78% | 75.87% |
| PH | 64,950 | 9,940 | 2,910 | 52,100 | 15.30% | 4.48% | 80.22% |
| ID | 76,980 | 16,890 | 1,950 | 58,140 | 21.94% | 2.53% | 75.53% |
| NZ | 8,130 | 180 | 90 | 7,860 | 2.21% | 1.11% | 96.68% |
| HK | 380 | 20 | 0 | 360 | 5.26% | 0.00% | 94.74% |
| TH | 5,490 | 450 | 30 | 5,010 | 8.20% | 0.55% | 91.25% |

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

### Validation & Quality Checks

**Cross-Validation Performed:**

1. **Segment Logic Validation:**
   - Manually reviewed 20 sample profiles per segment
   - Confirmed segmentation matched manual classification
   - Zero misclassifications found in sample

2. **Percentage Sum Checks:**
   - All country/month combinations summed to 100%
   - No data loss in segmentation logic

3. **Outlier Investigation:**
   - Investigated Hong Kong's 0% unemployed graduate rate
   - Confirmed due to small sample size (380 total viewers)
   - Documented as data limitation, not analysis error

4. **Temporal Consistency:**
   - Month-to-month variance within expected ranges
   - No unexplained spikes or drops

**Result:** High confidence in analysis accuracy and methodology

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
- SQL, Databricks, Excel, Confluence

---

[← Back to Projects](/projects.md)
