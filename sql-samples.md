---
layout: page
title: SQL Code Samples
subtitle: Real-world SQL techniques from production analytics work
---

These SQL samples demonstrate techniques I've used in production analytics projects at SEEK. All examples are anonymized (generic table/column names, fake data) for confidentiality while preserving the technical approach.

**Note: Additional SQL examples will be added as I document more projects from my internship work.**
---

## 1. Query Migration: Schema Mapping & Data Transformation

**Context:** Migrated 18 queries from generic shared table to purpose-built analytical table, requiring systematic field mapping and conversion.

**Challenge:** Handle nested property structures, case sensitivity, and column name differences.

**Original Query (using legacy shared table):**
```sql
-- Before migration: Using oversized shared table with nested properties
SELECT
    activity_site AS site,
    platform,
    experiments['experiment-feature-test'].variant AS variant,
    COUNT(DISTINCT visitor_id) AS users,
    COUNT(DISTINCT session_id) AS visits,
    COUNT(DISTINCT session_id) / COUNT(DISTINCT visitor_id) AS visit_per_user
    
FROM analytics_platform.legacy_data.shared_events
  
WHERE 1=1 
    AND event_date_site BETWEEN DATE('2024-09-01') AND LAST_DAY(DATE('2024-09-01'))
    AND platform IN ('ios app', 'android app')
    AND activity_site IN ('site_a', 'site_b', 'site_c', 'site_d')
    AND experiments['experiment-feature-test'].variant IS NOT NULL
    AND system_source IN ('segment')  -- Field only in old table
    AND LOWER(source_event_name) IN ('page_displayed')
    AND record_is_valid = 'true'  -- Data quality flag in old table
    
GROUP BY ALL
ORDER BY 1, 2, 3;
```

**Migrated Query (using purpose-built analytical table):**
-- After migration: Purpose-built table with optimized structure
```sql
SELECT
    LOWER(brand_country) AS site,  -- Column renamed + case conversion
    platform,
    experiments['experiment-feature-test'].variant AS variant,
    COUNT(DISTINCT uid) AS users,  -- visitor_id → uid
    COUNT(DISTINCT vid) AS visits,  -- session_id → vid
    COUNT(DISTINCT vid) / COUNT(DISTINCT uid) AS visit_per_user
    
FROM analytics_platform.analytics_db.analytics_events  -- New purpose-built table
  
WHERE 1=1 
    AND date BETWEEN DATE('2024-09-01') AND LAST_DAY(DATE('2024-09-01'))  -- event_date_site → date
    AND platform IN ('ios app', 'android app')
    AND LOWER(brand_country) IN ('sa', 'sb', 'sc', 'sd')  -- activity_site → brand_country, values changed
    AND experiments['experiment-feature-test'].variant IS NOT NULL
    AND LOWER(event_name) IN ('page_displayed')  -- source_event_name → event_name
    AND date IS NOT NULL  -- Simplified data quality check
    
GROUP BY ALL
ORDER BY 1, 2, 3;
```
**Key Techniques:**
- Schema mapping across different table structures
- Handling nested vs. flat column differences
- Case sensitivity management with LOWER()
- Field availability assessment (removed unavailable fields)
- Data quality validation approach changes

## 2. Query Consolidation: Flag-Based Architecture

**Context:** Consolidated 16 separate queries into single query using flag-based approach for dashboard flexibility.

**Challenge:** Multiple queries had identical filters but calculated different metrics. How to combine without losing metric specificity?

**Before Consolidation (One of 16 Separate Queries):**

-- Individual Query #7: Content Exposure Tracking
-- This was ONE of 16 similar queries, each scanning the table separately
```sql
SELECT 
    event_date,
    platform,
    experiments['experiment-feature-test'].variant AS variant,
    COUNT(DISTINCT content_impression_id) AS unique_impressions,
    COUNT(DISTINCT uid) AS visitors,
    COUNT(DISTINCT CASE WHEN content_type LIKE '%video%' 
        THEN uid END) AS video_visitors,
    COUNT(DISTINCT CASE WHEN content_type LIKE '%thread%' 
        THEN uid END) AS community_visitors

FROM analytics_platform.analytics_db.analytics_events

WHERE 1=1
    -- These filters repeated in ALL 16 queries ↓
    AND date BETWEEN DATE('2024-09-01') AND LAST_DAY(DATE('2024-09-01'))
    AND platform IN ('ios app', 'android app')
    AND LOWER(country) IN ('market_a', 'market_b', 'market_c', 'market_d')
    AND experiments['experiment-feature-test'].variant IS NOT NULL
    -- This filter unique to this query ↓
    AND event_name = 'content_cards_viewed'
    AND date IS NOT NULL
    AND event_name IS NOT NULL

GROUP BY event_date, platform, variant;
```
**After Consolidation (Single Query with Flags):**
-- Consolidated query replacing 16 separate queries
-- Uses flags instead of separate WHERE clauses for each metric
```sql
WITH main_query AS (
    SELECT 
        event_date,
        platform,
        country,
        experiments['experiment-feature-test'].variant AS variant,
        event_name,
        uid,
        vid,
        content_impression_id,
        content_type,
        action_type,
        
        -- FLAG SYSTEM: Replace separate queries with flag indicators
        
        -- Content Exposure (replaces Query #7)
        CASE WHEN event_name = 'content_cards_viewed' 
            THEN 1 END AS flag_impression_content,
        CASE WHEN event_name = 'content_cards_viewed' 
            AND (content_type LIKE '%video%' OR content_type LIKE '%episodic%') 
            THEN 1 END AS flag_impression_video,
        CASE WHEN event_name = 'content_cards_viewed' 
            AND content_type LIKE '%thread%' 
            THEN 1 END AS flag_impression_community,
        
        -- User Activation (replaces Query #11)
        CASE WHEN event_name IN ('video_viewed', 'feature_video_viewed') 
            THEN 1 END AS flag_activation_video,
        
        -- Community Engagement (replaces Query #13)
        CASE WHEN event_name IN (
            'thread_displayed', 'create_thread_succeeded', 
            'like_button_pressed', 'comment_succeeded'
        ) THEN 1 END AS flag_activation_community,
        
        -- Video Engagement (replaces Query #12)
        CASE WHEN (event_name IN ('feature_video_viewed', 'feature_module_displayed')
            AND LOWER(action_type) IN ('pause video', 'video complete', 'play video')) 
            THEN 1 END AS flag_video_watched,
        
        -- Bookmark Actions (replaces Query #15)
        CASE WHEN event_name = 'bookmark_pressed' 
            THEN 1 END AS flag_bookmark,
        
        -- Notification Tracking (replaces Query #16)
        CASE WHEN event_name = 'notification_badge_pressed' 
            THEN 1 END AS flag_notification_fired
        
    FROM analytics_platform.analytics_db.analytics_events
    
    WHERE 1=1
        -- Shared filters applied ONCE (not repeated 16 times)
        AND date BETWEEN DATE('2024-09-01') AND LAST_DAY(DATE('2024-09-01'))
        AND platform IN ('ios app', 'android app')
        AND LOWER(country) IN ('market_a', 'market_b', 'market_c', 'market_d')
        AND experiments['experiment-feature-test'].variant IS NOT NULL
        
        -- Consolidated event filter (covers all 16 original queries)
        AND event_name IN (
            'content_cards_viewed',      -- For content exposure
            'video_viewed',              -- For video activation
            'feature_video_viewed',      -- For video engagement
            'thread_displayed',          -- For community
            'create_thread_succeeded',   -- For community engagement
            'like_button_pressed',       -- For interactions
            'comment_succeeded',         -- For interactions
            'bookmark_pressed',          -- For bookmarks
            'notification_badge_pressed', -- For notifications
            'feature_module_displayed'   -- For video tracking
        )
        
        AND date IS NOT NULL
        AND event_name IS NOT NULL
)

SELECT * FROM main_query;
```
**Dashboard then calculates metrics using flags:**
-- Content Exposure Users (equivalent to original Query #7)
```sql 
COUNT(DISTINCT CASE WHEN flag_impression_content = 1 THEN uid END)

-- Video Visitors (equivalent to CASE WHEN in original query)
COUNT(DISTINCT CASE WHEN flag_impression_video = 1 THEN uid END)

-- Activation Rate
COUNT(DISTINCT CASE WHEN flag_activation_video = 1 THEN uid END) 
/ NULLIF(COUNT(DISTINCT uid), 0) * 100
```
**Key Techniques:**
- CTE for shared filtering logic (single table scan)
- Flag-based architecture for metric flexibility
- Consolidated event filtering (single WHERE clause)
- Dashboard-level calculations using flags
- Performance optimization: 16 table scans → 1 table scan

**Impact:** 70%+ load time reduction, maintained 100% data accuracy

---

## 3. User Segmentation: Multi-Table Join with Complex Business Logic

**Context:** Ad-hoc analysis requested by Senior Partnerships Manager to quantify student and unemployed graduate segments for external partner reporting.

**Challenge:** Define "student" vs "unemployed graduate" using data across three tables with incomplete profiles and ambiguous user states.

**Business Question:** "What percentage of students and unemployed graduates viewed partner content in 2025?"

**Approach:** Multi-table LEFT JOIN with defensive NULL handling and clear segmentation rules.

```sql
-- Ad-Hoc User Segmentation Analysis
-- 3-table join: content engagement + career history + education history

WITH content_viewers AS (
    -- Users who engaged with partner content
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
    -- Employment status and work history
    SELECT 
        candidate_id,
        is_new_to_workforce,
        has_workhistory,
        current_company_name,
        profile_title
    FROM dataplatform.dimensions.dim_candidate
),

education_history AS (
    -- Education completion status
    SELECT 
        candidate_id,
        is_course_completed,
        course_completed_year,
        course_completed_month,
        course_level,
        institution_name
    FROM dataplatform.candidate_mgmt.candidate_education
    WHERE is_course_completed IN ('Y', 'N')
),

user_classification AS (
    -- Apply segmentation logic with NULL handling
    SELECT
        cv.candidate_id,
        cv.country,
        MONTH(cv.date) AS month,
        ch.is_new_to_workforce,
        ch.has_workhistory,
        eh.is_course_completed,
        eh.course_completed_year,

        -- Segmentation CASE WHEN with defensive NULL logic
        CASE 
            -- STUDENT: Currently enrolled, not graduated, no work history
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

            -- OTHER: Employed or unclear status
            ELSE 'Other'
        END AS user_type

    FROM content_viewers cv
    LEFT JOIN career_history ch ON cv.candidate_id = ch.candidate_id
    LEFT JOIN education_history eh ON ch.candidate_id = eh.candidate_id
)

-- Final aggregation with percentage calculations
SELECT 
    country,
    month,
    COUNT(DISTINCT candidate_id) AS total_users,
    
    -- Segment counts
    COUNT(DISTINCT CASE WHEN user_type = 'Student' THEN candidate_id END) AS students,
    COUNT(DISTINCT CASE WHEN user_type = 'Unemployed Graduate' THEN candidate_id END) AS unemployed_graduates,
    COUNT(DISTINCT CASE WHEN user_type = 'Other' THEN candidate_id END) AS other_users,
    
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

**Key Techniques:**

**1. LEFT JOIN for Incomplete Data:**
- Not all users have complete career/education profiles
- LEFT JOIN preserves all content viewers
- NULL handling in CASE WHEN accounts for missing data

**2. Defensive NULL Logic:**
```sql
(is_course_completed = 'N' OR is_course_completed IS NULL)
```
- Treats NULL as potential match rather than automatic exclusion
- Conservative approach: only exclude when clearly doesn't match

**3. Multi-Condition Segmentation:**
- Each segment requires 3-4 conditions to be TRUE
- AND logic within each CASE branch
- Clear precedence (Student checked first, then Graduate, then Other)

**4. Business Rule Implementation:**
- Translated ambiguous business question into concrete SQL logic
- Documented assumptions for stakeholder transparency
- Handled edge cases systematically

**5. Percentage Calculations:**

```sql
ROUND(100.0 * numerator / denominator, 2)
```
- Explicit decimal (100.0) prevents integer division
- Consistent 2-decimal precision for reporting

**Result:** Delivered segmentation for 150,000+ users across 8 markets with clear methodology documentation

---

## 4. Multi-Granularity Data Model: UNION ALL Pattern for Tableau

**Context:** Dashboard development requiring multiple aggregation levels (overall, by module, by channel, by origin) in single Tableau data source.

**Challenge:** How to provide different aggregation granularities without creating separate queries or risking incorrect aggregation mixing in Tableau?

**Solution:** UNION ALL pattern with `data_type` field to distinguish aggregation levels.

**Approach:** Build multiple aggregation CTEs with identical column structure, combine with UNION ALL, use `data_type` for filtering.

```sql
-- Multi-Granularity Dashboard Data Model
-- Pattern: Base CTE → Multiple Aggregations → UNION ALL

WITH all_base AS (
    -- Foundation: All events with classifications
    SELECT
        date,
        uid,
        visit_id,
        platform,
        RIGHT(brand_country, 2) AS country,
        channel,
        view_action_origin,
        module_name,
        module_provider_meta,
        
        -- Event classification logic
        CASE 
            WHEN event_name = 'video_viewed' 
                AND action_type = 'Tap To Play On Module Screen' 
                THEN 'video_viewed'
            WHEN event_name = 'thread_displayed'
                THEN 'thread_viewed'
            ELSE event_name 
        END AS event_names
        
    FROM dataplatform.content_analytics.content_metadata
    WHERE date >= ADD_MONTHS(CURRENT_DATE(), -6)
),

-- Aggregation Level 1: Overall Daily (Date + Platform + Country)
overall_daily AS (
    SELECT 
        date,
        platform,
        country,
        NULL AS channel,           -- Position 4: Not grouped, set to NULL
        NULL AS utm_campaign,      -- Position 5: Not grouped, set to NULL
        NULL AS module_name,       -- Position 6: Not grouped, set to NULL
        NULL AS view_action_origin, -- Position 7: Not grouped, set to NULL
        
        COUNT(DISTINCT CASE WHEN event_names = 'video_viewed' 
            THEN uid END) AS video_uv,
        COUNT(DISTINCT CASE WHEN event_names = 'thread_viewed' 
            THEN uid END) AS thread_uv,
        COUNT(DISTINCT uid) AS total_uv,
        
        'overall_daily' AS data_type  -- Label for Tableau filtering
    FROM all_base
    GROUP BY date, platform, country
),

-- Aggregation Level 2: Module Daily (+ Module dimension)
module_daily AS (
    SELECT 
        date,
        platform,
        country,
        NULL AS channel,           -- Position 4: Not grouped, set to NULL
        NULL AS utm_campaign,      -- Position 5: Not grouped, set to NULL
        module_name,               -- Position 6: Grouped dimension
        NULL AS view_action_origin, -- Position 7: Not grouped, set to NULL
        
        COUNT(DISTINCT uid) AS video_uv,
        NULL AS thread_uv,         -- Not relevant at module level
        NULL AS total_uv,          -- Denominator not at this grain
        
        'module_daily' AS data_type
    FROM all_base
    WHERE event_names = 'video_viewed'  -- Module breakdown only for video
    GROUP BY date, platform, country, module_name
),

-- Aggregation Level 3: Origin Daily (+ Action Origin dimension)
origin_daily AS (
    SELECT
        date,
        platform,
        country,
        NULL AS channel,           -- Position 4: Not grouped
        NULL AS utm_campaign,      -- Position 5: Not grouped
        NULL AS module_name,       -- Position 6: Not grouped
        view_action_origin,        -- Position 7: Grouped dimension
        
        COUNT(DISTINCT uid) AS video_uv,
        NULL AS thread_uv,
        NULL AS total_uv,
        
        'origin_daily' AS data_type
    FROM all_base 
    WHERE event_names = 'video_viewed'
    GROUP BY date, platform, country, view_action_origin
),

-- Aggregation Level 4: Channel Daily (+ Marketing Channel dimension)
channel_daily AS (
    SELECT 
        date,
        platform,
        country,
        LOWER(channel) AS channel, -- Position 4: Grouped dimension
        utm_campaign,              -- Position 5: Grouped dimension
        NULL AS module_name,       -- Position 6: Not grouped
        NULL AS view_action_origin, -- Position 7: Not grouped
        
        COUNT(DISTINCT uid) AS video_uv,
        NULL AS thread_uv,
        NULL AS total_uv,
        
        'channel_daily' AS data_type
    FROM all_base
    WHERE event_names = 'video_viewed'
    GROUP BY date, platform, country, channel, utm_campaign
)

-- Combine all aggregations into single table
SELECT * FROM overall_daily
UNION ALL SELECT * FROM module_daily
UNION ALL SELECT * FROM origin_daily
UNION ALL SELECT * FROM channel_daily;
```
**Why This Pattern Works:**

**1. Single Tableau Data Source:**
- One connection instead of four separate queries
- Simplified dashboard maintenance
- Consistent filtering across all visualizations

**2. data_type Field Prevents Aggregation Errors:**
- Tableau filters on `data_type` to get correct granularity
- Example: Overall trend uses `data_type = 'overall_daily'`
- Example: Module breakdown uses `data_type = 'module_daily'`
- Prevents accidentally mixing aggregation levels

**3. NULL Pattern Communicates Intent:**
- Dimensions not in GROUP BY explicitly set to NULL
- Makes it obvious which dimensions are valid for each aggregation level
- Prevents misuse in Tableau (NULL dimensions can't be used)

**4. Identical Column Structure Required:**
All CTEs must have:
✓ Same number of columns
✓ Same column names
✓ Same column ORDER (UNION ALL matches by position!)
✓ Same data types


**Common Mistake:** Wrong column order → data appears in wrong columns after UNION

**Prevention:** 
- Define column template once
- Copy-paste to all CTEs
- Add position comments for verification

---

**Tableau Dashboard Usage:**

```sql
-- Overall KPI Chart
[Filter: data_type = 'overall_daily']
Metric: SUM([video_uv])

-- Module Performance Table
[Filter: data_type = 'module_daily']
Dimensions: [module_name]
Metric: SUM([video_uv])

-- Marketing Attribution
[Filter: data_type = 'channel_daily']
Dimensions: [channel]
Metric: SUM([video_uv])
```
**Key Techniques:**
- Multi-level CTE architecture
- UNION ALL for combining aggregations
- NULL pattern for unused dimensions
- data_type labeling for Tableau filtering
- Position-aware column ordering

**Impact:** Enabled flexible dashboard with multiple drill-down levels from single query, used in production dashboard serving content operations team

**Note:** Additional SQL examples from other projects will be added as documentation progresses.

[← Back to Projects](/projects.md)



