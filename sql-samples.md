---
layout: page
title: SQL Code Samples
subtitle: Real-world SQL techniques from production analytics work
---

These SQL samples demonstrate techniques I've used in production analytics projects at SEEK. All examples are anonymized (generic table/column names, fake data) for confidentiality while preserving the technical approach.

*Note: Additional SQL examples will be added as I document more projects from my internship work.*
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

