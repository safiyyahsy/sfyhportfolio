---
layout: page
title: "Case Study: Career Hub Dashboard Optimization"
subtitle: A two-phase approach to data migration and query consolidation
---

## Table of Contents

- [Project Overview](#project-overview)
- [The Problem](#the-problem)
- [Solution Approach](#solution-approach)
- [Phase 1: Data Migration](#phase-1-data-migration)
  - [Goal](#goal)
  - [Challenges Faced](#challenges-faced)
  - [Migration Process](#migration-process)
  - [Example: Migration of Experiment Pool Query](#example-migration-of-experiment-pool-query)
  - [Phase 1 Results](#phase-1-results)
- [Phase 2: Query Consolidation](#phase-2-query-consolidation)
  - [Goal](#goal-1)
  - [The Problem After Phase 1](#the-problem-after-phase-1)
  - [Analysis: Pattern Recognition](#analysis-pattern-recognition)
  - [Consolidation Strategy](#consolidation-strategy)
  - [Consolidation Process](#consolidation-process)
  - [Example: Before Consolidation](#example-before-consolidation)
  - [Example: After Consolidation](#example-after-consolidation)
- [Phase 3: Dashboard Integration & Validation](#phase-3-dashboard-integration--validation)
  - [Goal](#goal-2)
  - [Step 1: Adding Dynamic Parameters](#step-1-adding-dynamic-parameters)
  - [Step 2: Creating Calculated Fields](#step-2-creating-calculated-fields-in-dashboard-schema)
  - [Step 3: Dashboard Visualization Validation](#step-3-dashboard-visualization-validation)
- [Overall Results](#overall-results)
- [Skills Demonstrated](#skills-demonstrated)
- [Business Impact](#business-impact)
- [Tools Used](#tools--technologies)

---

## Project Overview

**Duration:** ~3 months  
**Role:** Product Analytics Intern  
**Company:** SEEK (Jobstreet)  
**Tools:** Databricks, SQL, Tableau, Excel

---

## The Problem

The Career Hub Experiment dashboard was critical for tracking user engagement experiments across multiple markets. However, it had become unusable:

**Symptoms:**
- Dashboard load time: **Several days** (not a typo - it would time out repeatedly)
- Resource consumption so high it slowed down other Databricks users
- 21 separate SQL queries all hitting the same production table
- Each query had similar filtering logic but calculated different metrics
- Maintainability nightmare: changing date range required updating 21 queries

**Root Causes Identified:**
1. **Inefficient data source:** Using `shared_events` - a massive, generic shared table with hundreds of columns, serving multiple teams
2. **Redundant query logic:** Same WHERE clauses repeated 21 times, causing 21 separate table scans
3. **No optimization:** Each query ran independently without sharing intermediate results

**Business Impact:**
- Team couldn't access experiment results in time to make decisions
- Blocked other analytics work due to resource contention

---

## Solution Approach

Thus, the proposed solution are:

1. **Phase 1 (Foundation):** Migrate to purpose-built analytical table
2. **Phase 2 (Optimization):** Consolidate query logic using CTEs
3. **Phase 3 (Dashboard Integration & Validation)** 

---

## Phase 1: Data Migration

### Goal
Move queries from generic `shared_events` table to purpose-built `analytics_events` table optimized for event analytics.

### Challenges Faced

**1. Schema Mapping**
- Column names differed between tables
- Example: `visitor_id` → `user_id`
- Required systematic mapping of all fields

**2. Data Availability**
- Not all events existed in new table
- 3 out of 21 queries couldn't be migrated due to missing data sources
- Had to validate which queries were feasible

**3. Case Sensitivity Issues**
- Old table: inconsistent capitalization
- New table: standardized but different conventions
- Required LOWER() functions in many places

### Migration Process

**Step 1: Analyze Current Queries**
- Identified common patterns and filtering logic
- Listed all columns/fields used

**Step 2: Schema Mapping**

Created comprehensive mapping document for field conversion:

| Old Table (shared_events) | New Table (analytics_events) | Notes |
|-------------------------------|-------------------------------|-------|
| `activity_site` | `LOWER(site_region)` | Required case conversion |
| `event_date_site` | `date` | Column renamed |
| `event_date_utc` | `event_date_utc` | Direct mapping |
| `source_event_name` | `event_name` | Column renamed |
| `platform` | `platform` | Direct mapping |
| `record_is_valid` | _(not available)_ | Data quality field missing |
| `raw_properties.actionOrigin` | `action_origin` | Nested → flat structure |
| `raw_properties.actionType` | `action_type` | Nested → flat structure |
| `raw_properties.contentImpressionId` | `content_impression_id` | Nested → flat, renamed |
| `raw_properties.contentReferenceId` | `module_id` | Nested → flat structure |
| `raw_properties.contentType` | `content_type` | Nested → flat structure |
| `raw_properties.currentPage` | `current_page` | Nested → flat structure |
| `raw_properties.linkAction` | `link_action` | Nested → flat structure |
| `raw_properties.linkPosition` | `link_position` | Nested → flat structure |
| `raw_properties.videoLength` | `video_length` | Nested → flat structure |
| `raw_properties.videoWatchTime` | `video_watch_time` | Nested → flat structure |
| `session_id` | `visitor_session_id` | Column renamed |
| `site_country_code` | `LOWER(country)` | Required case conversion |
| `system_source` | _(not available)_ | Field not in new table |
| `vendor_properties.siteSection` | _(not available)_ | Field not in new table |
| `visitor_id` | `user_id` | Column renamed |
| `visit_attribution` | `traffic_channel` | Column renamed |
| `brand` | `LOWER(brand)` | Required case conversion |
| `current_page` | `current_page` | Direct mapping |
| `raw_properties.currentPageSubSection` | `page_subsection` | Nested → flat structure |
| `raw_properties.currentPageSection` | `page_section` | Nested → flat structure |
| `visit_attribution_category` | `attribution_category` | Direct mapping |
| `raw_properties.loginId` | `login_id` | Nested → flat, case change |
| `candidate_id` | `user_core_id` | Column renamed |

**Key Mapping Challenges:**

1. **Nested Property Structures:** Old table used `raw_properties.xxx` and `vendor_properties.xxx` nested structures, new table used flat column names
2. **Case Sensitivity:** Multiple fields required `LOWER()` function for consistency
3. **Missing Fields:** 3 fields from old table not available in new table (caused 3 queries to fail migration)
4. **Column Renaming:** 15+ columns had different names requiring systematic mapping
5. **Naming Conventions:** Content-specific fields gained clearer prefixes in new table

**Step 3: Convert Queries One-by-One**

**Conversion Process:**

1. **Identify pattern within group** - Find the common query structure
2. **Convert first query in pattern** - Apply all schema mappings, test thoroughly
3. **Use as template** - Adapt the working conversion for similar queries
4. **Individual testing** - Run each converted query and verify output
5. **Document issues** - Track which queries had problems

**Tracking Method:**

- Used Databricks notebook with clear section headers for each query
- Named queries descriptively: `Query_01_Content_Exposure`, `Query_02_Content_Engagement`, etc.
- Commented each query with validation status
- Maintained running list of successfully converted vs. blocked queries

**Conversion Blockers:**

3 queries **could not be converted** due to missing data in the new analytical table:

| Query # | Purpose | Issue | Solution |
|---------|---------|-------|----------|
| Query 8 | Specific attribution analysis | Required fields not available in `analytics_events` | Kept using original `shared_events` table |
| Query 15 | Detailed site section metrics | Required fields not available in `analytics_events` | Kept using original `shared_events` table |
| Query 19 | Data quality validation | Required fields not available in `analytics_events` | Kept using original `shared_events` table |

**Decision:** These 3 queries remained on the original table (`shared_events`) because the new purpose-built table didn't contain all necessary fields for their specific use cases. The dashboard continued to use a hybrid approach: 18 queries from new table + 3 queries from old table.

**Migration Success Rate:** 18 out of 21 queries successfully migrated (86%)

**Important note:** While not ideal to have mixed data sources, this was acceptable because:
- The resource impact was minimal compared to the total 21 original queries
- Full migration would have required additional data engineering work beyond project scope

**Step 4: Validation**

Ensuring data accuracy was critical since the dashboard informed experiment decisions affecting product strategy.

**Validation Methodology:**

Created comprehensive validation spreadsheet comparing original vs. converted queries at granular level.

**Validation Structure:**

For each converted query, compared results based on its specific dimensions and metrics:
- **Dimensions validated:** Varied by query (e.g., Site + Platform + Variant for Experiment Pool query; Site + Platform + Date for other queries)
- **Metrics validated:** Query-specific metrics (Users, Visits, Impressions, etc. depending on query purpose)
- **Calculation:** Difference = Converted - Original, % Difference = (Difference / Original) × 100

**Validation Spreadsheet Format:**

| Site | Platform | Variant | Users (Original) | Visits (Original) | Visit_per_UV (Original) | Users (Converted) | Visits (Converted) | Visit_per_UV (Converted) | % Diff Users | % Diff Visits | % Diff Rate |
|------|----------|---------|------------------|-------------------|-------------------------|-------------------|--------------------|--------------------------|--------------|--------------|--------------| 
| Market A | android | 0 | 16,063 | 23,557 | 1.466538007 | 16,063 | 23,557 | 1.466538007 | 0% | 0% | 0% |
| Market A | ios | 0 | 24,364 | 37,159 | 1.525160072 | 24,364 | 37,159 | 1.525160072 | 0% | 0% | 0% |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

**Note: This example shows the Experiment Pool query validation. Other queries had different dimension combinations (e.g., Date + Platform + Country) depending on their specific purpose and GROUP BY logic.**

**Validation Coverage:**

- **18 converted queries** validated
- **~30-50 dimension combinations** per query (sites × platforms × variants)
- **3 core metrics** per combination: Users, Visits, Calculated Rate
- **Total validation rows:** 500+ individual comparisons

**Validation Process:**

1. **Export both query results** - Original (old table) and Converted (new table) to CSV
2. **Import to validation spreadsheet** - Side-by-side comparison layout
3. **Calculate differences** - Automated formulas for difference and % difference
4. **Flag any variances** - Conditional formatting to highlight non-zero differences
5. **Investigate discrepancies** - If any variance found, debug query logic
6. **Document results** - Track validation status for each query

**Validation Criteria:**
- ✅ **Pass:** 0% variance across all metrics and dimension combinations
- ⚠️ **Review:** Any variance > 0% requires investigation
- ❌ **Fail:** Variance indicates conversion error - must fix before proceeding

**Final Validation Results:**

**All 18 converted queries achieved 100% exact match:**

**No discrepancies found** - Schema mapping was accurate, logic preserved correctly.

**Validation Duration:** ~1 week of systematic testing and documentation

### Example: Migration of Experiment Pool Query

This example shows the first query migrated: tracking users exposed to the experiment.

**BEFORE (using shared_events table):**
```sql
SELECT
  activity_site AS site
  ,platform
  ,experiments['experiment-feature-test'].variant AS variant
  ,COUNT(DISTINCT visitor_id) AS users
  ,COUNT(DISTINCT session_id) AS visits
  ,COUNT(DISTINCT session_id)/COUNT(DISTINCT visitor_id) AS visit_per_uv
  
FROM analytics_platform.legacy_data.shared_events
  
WHERE 1=1 
  -- Date filter
  AND event_date_site BETWEEN DATE('2024-09-01') AND LAST_DAY(DATE('2024-09-01'))
  
  -- Platform filter
  AND platform IN ('ios app','android app')
  
  -- Site/market filter
  AND activity_site IN ('site_a', 'site_b', 'site_c', 'site_d', 'site_e', 'site_f', 'site_g', 'site_h')
  
  -- Experiment participation
  AND experiments['experiment-feature-test'].variant IS NOT NULL
  
  -- Data source filter (specific to old table)
  AND system_source IN ('segment')
  
  -- Event filter
  AND LOWER(source_event_name) IN ('page_displayed')
  
  -- Data quality checks (specific to old table)
  AND event_date_site IS NOT NULL
  AND event_name IS NOT NULL
  AND record_is_valid = 'true'
    
GROUP BY ALL
ORDER BY 1,2,3
```
**AFTER (using analytics_event table):**
```sql
SELECT
  LOWER(brand_country) AS site  -- Column mapping + case conversion
  ,platform
  ,experiments['experiment-feature-test'].variant AS variant
  ,COUNT(DISTINCT uid) AS users  -- visitor_id → uid
  ,COUNT(DISTINCT vid) AS visits  -- session_id → vid
  ,COUNT(DISTINCT vid)/COUNT(DISTINCT uid) AS visit_per_uv
  
FROM analytics_platform.analytics_db.analytics_events  -- New purpose-built table
  
WHERE 1=1 
  -- Date filter (renamed column)
  AND date BETWEEN DATE('2024-09-01') AND LAST_DAY(DATE('2024-09-01'))
  
  -- Platform filter (unchanged)
  AND platform IN ('ios app','android app')
  
  -- Site/market filter (new column + abbreviated values)
  AND LOWER(brand_country) IN ('sa', 'sb', 'sc', 'sd', 'se', 'sf', 'sg', 'sh')
  
  -- Experiment participation (unchanged nested structure)
  AND experiments['experiment-feature-test'].variant IS NOT NULL
  
  -- Event filter (renamed column)
  AND LOWER(event_name) IN ('page_displayed')
  
  -- Data quality checks (simplified for new table)
  AND date IS NOT NULL
    
GROUP BY ALL
ORDER BY 1,2,3
```
**Key Schema Mapping Applied:**

| Change Type | Old Table | New Table | Notes | 
|-------------|-----------|-----------|-------|
| Table Name | legacy_data.shared_events | analytics_db.analytics_events | Purpose-built analytics table |
| Site column | activity_site | LOWER(brand_country) | Column renamed + case conversion required |
| Site values | Full names ( site_a, site_b ) | Abbreviated codes ( sa, sb ) | Value format change |
| Date column | event_date_site | date | Column renamed |
| User ID | visitor_id | uid | Colunm renamed |
| Session ID | session_id | vid | Colunm renamed |
| Event name | source_event_name | event_name | Colunm renamed |
| Source filter | system_source field | (removed) | Not available in new table |
| Validation flag | record_is_valid = 'true' | (removed) | Not available in new table  |

Result: Successfully migrated with 100% data accuracy (validated via spreadsheet comparison across all site/platform/variant combinations)

---

## Phase 2: Query Consolidation

### Goal
Reduce 18 separate queries (after migration) to minimize redundant table scans and improve performance dramatically.

### The Problem After Phase 1

Even after migration to the purpose-built table, performance was still poor:

**Why?** Each of the 18 queries was:
- Scanning the entire `analytics_events` table independently
- Applying the same date/platform/country/experiment filters
- Running separately = **18 separate table scans**

**Root cause:** Queries weren't sharing any work - every query re-read the same filtered data.

### Analysis: Pattern Recognition

After migration, I analyzed the 18 queries and found significant overlap:

**Common patterns across queries:**

1. **Identical filtering logic:**
   - All queries filtered on same date range
   - All queries filtered on same countries/markets
   - All queries filtered on same platforms (iOS/Android)
   - All queries filtered on experiment participation

2. **Similar metric calculations:**
   - Many calculated user counts with different event filters
   - Multiple queries tracked engagement (clicks, views, shares)
   - Several queries calculated rates/percentages (impressions per user, etc.)
   - Different queries just filtered on different `event_name` values

3. **Segmentation patterns:**
   - Multiple queries used CASE WHEN to segment by content type (video vs article)
   - Similar logic for calculating metrics at different granularities

**Consolidation Opportunity Identified:**

Queries could be reorganized into:
- **1 base CTE** with shared filtering (scans table once)
- **Multiple metric CTEs** calculating different metrics from the base
- **1 final SELECT** joining all metrics together

**Initial Target:** Consolidate all 18 migrated queries into single query

**Actual Result:** 
- 16 queries successfully consolidated into 1 main query
- 2 queries could not be consolidated due to incompatible aggregation levels
- 5 supporting queries remained separate (specialized use cases)
- **Final: 6 total queries** (1 main consolidated + 2 unconsolidated + 3 other supporting)

**Why 2 Couldn't Be Consolidated:**
Aggregation grain mismatch - these queries required different GROUP BY dimensions that couldn't be unified with the flag-based approach without creating incorrect results.

### Consolidation Strategy

**BEFORE Phase 2:** Sequential independent queries

Query 1: SELECT ... FROM analytics_events WHERE [common filters] AND event = 'A'
Query 2: SELECT ... FROM analytics_events WHERE [common filters] AND event = 'B'
Query 3: SELECT ... FROM analytics_events WHERE [common filters] AND event = 'C'
...
Query 16: SELECT ... FROM analytics_events WHERE [common filters] AND event = 'P'

### Example: Before Consolidation

**Original Query #7: Content Exposure Tracking (1 of 18 separate queries)**

```sql
-- ONE of 18 separate queries - this one tracked content impressions
SELECT 
    event_date_utc,
    platform,
    experiments['experiment-feature-test'].variant AS variant,
    COUNT(DISTINCT content_impression_id) AS unique_impressions,
    COUNT(DISTINCT uid) AS visitors,
    COUNT(DISTINCT CASE WHEN content_type LIKE '%video%' OR content_type LIKE '%episodic%'
        THEN uid END) AS skill_visitors,
    COUNT(DISTINCT CASE WHEN content_type LIKE '%thread%' 
        THEN uid END) AS community_visitors,
    COUNT(DISTINCT CASE WHEN content_type LIKE '%video%' OR content_type LIKE '%episodic%'
        THEN content_impression_id END) AS unique_skill_impressions,
    COUNT(DISTINCT CASE WHEN content_type LIKE '%thread%' 
        THEN content_impression_id END) AS unique_community_impressions

FROM analytics_platform.analytics_db.analytics_events

WHERE 1=1
    -- These filters repeated in ALL 18 queries ↓
    AND date BETWEEN :date_range.min AND :date_range.max
    AND ARRAY_CONTAINS(:param_platform, platform)
    AND ARRAY_CONTAINS(:param_country, country)
    AND experiments['experiment-feature-test'].variant IS NOT NULL
    AND LOWER(country) IN ('market_a', 'market_b', 'market_c', 'market_d', 'market_e', 'market_f', 'market_g', 'market_h')
    -- This filter unique to this query ↓
    AND event_name = 'content_cards_viewed'
    -- Optimizations
    AND date IS NOT NULL
    AND event_name IS NOT NULL

GROUP BY event_date_utc, platform, variant
ORDER BY event_date_utc, platform, variant;
```
### Example: After Consolidation

**Consolidated Main Query: Replaces 16 of 18 queries with single query**

```sql
-- CONSOLIDATED QUERY: Replaces 16 separate queries with flag-based approach
-- Single table scan with flags for all metrics

WITH main_query AS (
    SELECT 
        event_date_utc,
        platform,
        mobile_app_version,
        country,
        experiments['experiment-feature-test'].variant AS variant,
        event_name,
        uid,
        vid,
        content_impression_id AS content_id,
        content_type,
        
        -- Enhanced event type classification
        CASE
            WHEN event_name = 'video_viewed' AND LOWER(action_type) LIKE '%play%' 
                THEN 'video_viewed_play'
            WHEN event_name = 'feature_video_viewed' AND LOWER(action_type) LIKE '%play%' 
                THEN 'feature_video_viewed_play'
            ELSE event_name 
        END AS event_type,
        
        action_type,
        link_position,
        current_page,
        link_action,
        LOWER(brand_country) AS site,
        module_id,
        view_action_origin,
        
        -- FLAG SYSTEM: Binary indicators for dashboard calculations
        -- Replaces separate COUNT DISTINCT queries with flag-based aggregation
        
        -- Core Feature Exposure
        CASE WHEN event_name = 'feature_displayed' THEN 1 END AS flag_feature_exposed,
        
        -- Activation Events (replaces 3 separate queries)
        CASE WHEN (event_name IN (
                'thread_displayed', 
                'feature_thread_displayed', 
                'follow_button_pressed', 
                'create_thread_pressed',
                'like_button_pressed', 
                'show_reply_pressed', 
                'comment_thread_succeeded', 
                'comment_succeeded', 
                'create_thread_succeeded')
            OR (event_name = 'poll_selection_pressed' 
                AND link_position = 'thread poll' 
                AND current_page = 'feature home')
            OR event_type IN ('video_viewed_play', 'feature_video_viewed_play')
        ) THEN 1 END AS flag_activation,
        
        -- Skills Activation (replaces Query #11)
        CASE WHEN event_name IN ('video_viewed', 'feature_video_viewed') 
            THEN 1 END AS flag_activation_skills,
        
        -- Community Activation (replaces Query #13)
        CASE WHEN event_name IN (
            'thread_displayed',
            'feature_thread_displayed',
            'create_thread_succeeded',
            'create_thread_pressed',
            'comment_thread_succeeded',
            'follow_button_pressed',
            'share_pressed',
            'like_button_pressed',
            'comment_succeeded',
            'show_reply_pressed'
        ) THEN 1 END AS flag_activation_community,
        
        -- Community Engagement Funnel (replaces 3 separate queries)
        CASE WHEN event_name = 'create_thread_displayed' 
            THEN 1 END AS flag_community_thread_displayed,
        CASE WHEN event_name = 'create_thread_pressed' 
            THEN 1 END AS flag_community_thread_initiation,
        CASE WHEN event_name = 'create_thread_succeeded' 
            THEN 1 END AS flag_community_thread_completed,
        CASE WHEN event_name = 'like_button_pressed' 
            THEN 1 END AS flag_community_liked,
        CASE WHEN event_name = 'comment_succeeded' 
            THEN 1 END AS flag_community_commented,
        CASE WHEN event_name = 'share_pressed' 
            THEN 1 END AS flag_community_shared,
        
        -- Content Impression Tracking (replaces Query #7)
        CASE WHEN event_name = 'content_cards_viewed' 
            THEN 1 END AS flag_impression_content,
        CASE WHEN event_name = 'content_cards_viewed' 
            AND (content_type LIKE '%video%' OR content_type LIKE '%episodic%') 
            THEN 1 END AS flag_impression_skills,
        CASE WHEN event_name = 'content_cards_viewed' 
            AND content_type LIKE '%thread%' 
            THEN 1 END AS flag_impression_community,
        
        -- Subtitle Feature Tracking (replaces 2 separate queries)
        CASE WHEN event_name = 'video_subtitles_pressed' 
            AND link_action = 'view subtitles' 
            THEN 1 END AS flag_subtitle_toggle,
        CASE WHEN event_name = 'video_subtitles_pressed' 
            AND link_action IN ('english', 'thai', 'tagalog', 'chinese', 'indonesian', 'malay', 'off') 
            THEN 1 END AS flag_subtitle_language,
        
        -- Video Engagement (replaces Query #12)
        CASE WHEN (event_name IN ('feature_video_viewed', 'feature_module_displayed', 'video_subtitles_pressed')
            AND LOWER(action_type) IN (
                'pause video', 'video complete', 'feature back button', 
                'back to previous page', 'continue play video',
                'play video', 'tap to play on module screen', 'tap to play')) 
            THEN 1 END AS flag_watched_video,
        
        -- Subtitle Rate Calculation (denominator for subtitle metrics)
        CASE WHEN (event_name IN ('feature_video_viewed', 'feature_module_displayed')
            AND LOWER(action_type) IN (
                'pause video', 'video complete', 'feature back button', 
                'back to previous page', 'continue play video',
                'play video', 'tap to play on module screen', 'tap to play')) 
            AND event_name != 'video_subtitles_pressed'
            THEN 1 END AS flag_subtitle_rate,
        
        -- Action Menu Interactions (replaces Query #15)
        CASE WHEN event_name = 'more_actions_pressed' 
            THEN 1 END AS flag_snack_bar,
        CASE WHEN event_name = 'bookmark_pressed' 
            THEN 1 END AS flag_bookmark,
        CASE WHEN (event_name = 'bookmark_pressed' 
            AND link_position = 'module' 
            AND current_page != 'feature module') 
            THEN 1 END AS flag_rail_bookmark,
        CASE WHEN (event_name = 'bookmark_pressed' 
            AND link_position = 'module' 
            AND current_page = 'feature module' 
            AND view_action_origin = 'module more videos like this') 
            THEN 1 END AS flag_module_action_bookmark,
        
        -- Share Tracking
        CASE WHEN (event_name = 'share_pressed' 
            AND link_position = 'module' 
            AND current_page != 'feature module') 
            THEN 1 END AS flag_rail_share,
        CASE WHEN (event_name = 'share_pressed' 
            AND link_position = 'module' 
            AND current_page = 'feature module'
            AND view_action_origin = 'module more videos like this') 
            THEN 1 END AS flag_module_action_share,
        
        -- Bookmark Engagement Flow
        CASE WHEN event_name = 'feature_module_displayed' 
            AND view_action_origin = 'bookmark' 
            THEN 1 END AS flag_bookmark_video_play,
        
        -- Notification System Tracking (replaces 2 separate queries)
        CASE WHEN event_name = 'tooltip_pressed' 
            AND link_position = 'tooltip' 
            THEN 1 END AS flag_tooltip_acknowledged,
        CASE WHEN event_name = 'tooltip_pressed' 
            AND link_position = 'others' 
            THEN 1 END AS flag_tooltip_dismissed,
        CASE WHEN event_name = 'recent_activity_displayed' 
            THEN 1 END AS flag_notification_page,
        CASE WHEN event_name = 'recent_activity_pressed' 
            THEN 1 END AS flag_notification_read,
        CASE WHEN event_name = 'notification_badge_pressed' 
            THEN 1 END AS flag_unread_notification_fired
        
    FROM analytics_platform.analytics_db.analytics_events
    
    WHERE 1=1
        -- Date filter (hardcoded initially, parameterized in Phase 3)
        AND date BETWEEN DATE('2024-09-01') AND LAST_DAY(DATE('2024-09-01'))
        
        -- Platform filter
        AND platform IN ('ios app', 'android app')
        
        -- Market Filter
        AND LOWER(country) IN ('market_a', 'market_b', 'market_c', 'market_d', 
                               'market_e', 'market_f', 'market_g', 'market_h')
        
        -- Experiment participation
        AND experiments['experiment-feature-test'].variant IS NOT NULL
        
        -- Event Filter: Consolidated list covering all 16 original queries
        AND (
            -- Content Exposure
            (event_name = 'content_cards_viewed')
            OR 
            -- Core Events
            (event_name IN (
                'feature_displayed', 
                'thread_displayed', 
                'feature_thread_displayed', 
                'create_thread_pressed', 
                'create_thread_succeeded',
                'comment_thread_succeeded', 
                'follow_button_pressed',
                'share_pressed', 
                'like_button_pressed', 
                'show_reply_pressed', 
                'comment_succeeded', 
                'video_viewed',
                'feature_video_viewed',
                'create_thread_displayed',
                'video_subtitles_pressed',
                'tooltip_pressed',
                'recent_activity_displayed',
                'recent_activity_pressed',
                'notification_badge_pressed'
            ))
            OR 
            -- Conditional Events (complex filters)
            (event_name = 'poll_selection_pressed' 
                AND link_position = 'thread poll' 
                AND current_page = 'feature home')
            OR
            (event_name = 'video_subtitles_pressed' 
                AND link_action = 'view subtitles')
            OR 
            (event_name = 'video_subtitles_pressed' 
                AND LOWER(link_action) IN ('english', 'thai', 'tagalog', 'chinese', 
                                           'indonesian', 'malay', 'off'))
            OR
            (event_name IN ('feature_video_viewed', 'feature_module_displayed')
                AND LOWER(action_type) IN (
                    'pause video', 'video complete',
                    'feature back button', 'back to previous page', 
                    'continue play video', 'play video',
                    'tap to play on module screen', 'tap to play'))
        )
        
        -- Data Quality Optimizations
        AND date IS NOT NULL
        AND event_name IS NOT NULL
)

-- Final SELECT with additional computed flag
SELECT *, 
    CASE WHEN (event_name = 'video_subtitles_pressed' 
        AND LOWER(link_action) IN ('english', 'thai', 'tagalog', 'chinese', 
                                   'indonesian', 'malay', 'off')) 
        THEN 1 ELSE 0 
    END AS flag_video_subtitle
FROM main_query;
```

**How this consolidation works:**

1. Single table run
   - Before: 16 queries x 1 run each = 16 runs
   - After: 1 base CTE = 1 run
     
2. Flag-based architecture
   - Instead of separate count distinct queries for different event filters, binary flags were used
   - More flexible for dashboard filtering and calculations
  
3. Shared filtering logic
   - Date, platform, country, experiment filters applied once
   - Complex event filtering consolidated in single OR condition
   - filter hardcoded at this stage
  
4. Event lists consolidation
   - Combined event lists from all 16 queries
   - Organized by category (content, activation, community, notifications)
   - Single WHERE clause cover all metrics

5. Conditional flag logic
   - Handles complex business rules
   - Separate activation by type (skills vs community)
   - Tracks engagement funnels (displayed -> initiated -> completed)
  
8. Maintainability wins
   - Add new metric = add new flag (don't need new query)
   - Change filter logic = modify one WHERE clause section
   - All metrics stay in sync (same filtering applied)
---

## Phase 3: Dashboard Recreation & Validation

### Goal
Recreate the Career Hub Experiment dashboard using the consolidated query architecture, ensuring visualizations match the archived original dashboard exactly.

### Context
After query consolidation was complete, the dashboard needed to be rebuilt:
- **Original dashboard:** Used 21 separate queries, now archived
- **New dashboard:** Built from scratch using consolidated query + calculated fields
- **Reference:** Used archived dashboard as specification for visualizations
- **Challenge:** Ensure new dashboard produces identical results to original

This phase involved:
2. Adding dynamic parameters for self-service filtering
3. Creating calculated fields in dashboard schema to compute metrics
4. Recreating all visualizations matching the original dashboard structure
5. Validating outputs match archived dashboard results exactly

### Timeline
~2-3 weeks of dashboard integration, calculation setup, and comprehensive validation

---

### Step 1: Adding Dynamic Parameters

**Challenge:** Original queries had hardcoded date ranges, platforms, countries, and experiment names. Changing filters required modifying SQL code directly.

**Solution:** Following guidance from my supervisor, implemented Databricks dashboard parameters for dynamic filtering.

**Parameters Added:**

1. **`:date_range`** 
   - Type: Date range selector
   - Purpose: Allow users to select custom date ranges without editing SQL
   - Implementation: `WHERE date BETWEEN :date_range.min AND :date_range.max`

2. **`:param_platform`**
   - Type: Multi-select dropdown
   - Options: `ios app`, `android app`
   - Purpose: Filter by mobile platform
   - Implementation: `WHERE ARRAY_CONTAINS(:param_platform, platform)`

3. **`:param_country`**
   - Type: Multi-select dropdown
   - Options: Market codes (market_a, market_b, market_c, etc.)
   - Purpose: Filter by geographic market
   - Implementation: `WHERE ARRAY_CONTAINS(:param_country, country)`

4. **`:param_experiment`**
   - Type: Text input
   - Purpose: Switch between different experiments without changing query
   - Implementation: `WHERE experiments[:param_experiment].variant IS NOT NULL`

**Benefits:**
- ✅ Dashboard users can change filters dynamically
- ✅ No SQL editing required for routine analysis
- ✅ Reduces risk of query errors from manual editing
- ✅ Enables self-service analytics for stakeholders

**Example Usage:**
```sql
-- Before (hardcoded):
WHERE date BETWEEN DATE('2024-09-01') AND LAST_DAY(DATE('2024-09-01'))
  AND platform IN ('ios app', 'android app')
  AND experiments['experiment-feature-test'].variant IS NOT NULL

-- After (parameterized):
WHERE date BETWEEN :date_range.min AND :date_range.max
  AND ARRAY_CONTAINS(:param_platform, platform)
  AND experiments[:param_experiment].variant IS NOT NULL
```

---

### Step 2: Creating Calculated Fields in Dashboard Schema

**Challenge:** The consolidated query uses a single WHERE clause covering ALL events (not separated by event type like the original 18 queries). This means the base data includes all events, and we need calculated fields to segment metrics correctly.

**Key Difference from Original Queries:**

**Original/Converted Queries (Separated):**
```sql
-- Query #7: Content Exposure - SPECIFIC event filter
SELECT COUNT(DISTINCT uid) as users
FROM analytics_events
WHERE event_name = 'content_cards_viewed'  -- Only content events
  AND date BETWEEN ... 
  AND platform IN ...
```
**Consolidated Query (All events combined):**
```sql
-- Single query with ALL events in WHERE clause
SELECT 
    uid,
    CASE WHEN event_name = 'content_cards_viewed' THEN 1 END as flag_impression_content
FROM analytics_events
WHERE event_name IN (
    'content_cards_viewed',      -- For content exposure
    'feature_displayed',         -- For feature exposure
    'video_viewed',              -- For activation
    ...                          -- All 16+ event types
)
AND date BETWEEN ... 
AND platform IN ...
```
**The Problem:**
- Original queries: Each query only fetched specific events → COUNT(DISTINCT uid) automatically correct
- Consolidated query: Fetches ALL events → Need flags to filter which users count for which metric

**Solution: Created custom calculations in Databricks Dashboard Schema that use flags to replicate the original query logic.**

---

### Step 3: Dashboard Visualization Validation

**Challenge:** Ensure the new consolidated query + calculated fields produces identical dashboard outputs as the original 21-query dashboard.

**Validation Approach:**

Used the original dashboard as reference and systematically validated each visualization.

**Validation Process:**

**Stage 1: Query-Level Validation (Table Comparison)**

Similar to Phase 1 validation approach:

1. **Export consolidated query results** to validation spreadsheet
2. **Export each original converted query result** (the 18 separated queries from Phase 1)
3. **Map calculated fields** to original query metrics
4. **Compare values** for each metric across all dimension combinations

**Challenge Encountered:**

Since the consolidated query combines all events, direct table comparison wasn't straightforward like Phase 1.

**Solution:**

Manually added calculated field metrics to dashboard table visualization, then validated against original converted query results.

**Example Validation:**

| Metric | Original Query #7 Output | Consolidated Query + Calc Field | Match |
|--------|--------------------------|----------------------------------|-------|
| Content Exposure Users | 16,063 | `COUNT(DISTINCT CASE WHEN flag_impression_content = 1 THEN uid END)` = 16,063 | ✅ |
| Video Impressions | 123,456 | `SUM(flag_impression_skills)` = 123,456 | ✅ |
| Activation Rate | 27.8% | Calculated field formula = 27.8% | ✅ |

**Stage 2: Visualization-Level Validation**

For each chart/table in the original dashboard:

1. **Identified the data source** - Which of the 21 original queries powered this visual?
2. **Located equivalent calculated field** - Which flag-based calculation replaces it?
3. **Added visualization to new dashboard** - Using consolidated query + calculated field
4. **Compared outputs side-by-side** - Original dashboard vs. new dashboard
5. **Verified numbers matched** - Checked all dimension breakdowns (date, platform, variant, site)

**Dashboard Components Validated:**

- ✅ **Experiment pool table** - User counts by site/platform/variant
- ✅ **Content exposure charts** - Impression counts and rates
- ✅ **Activation funnel** - Skills vs. community activation
- ✅ **Engagement metrics** - Video plays, subtitle usage, bookmarks
- ✅ **Community metrics** - Thread creation, likes, comments, shares
- ✅ **Notification metrics** - Tooltip interactions, notification reads
- ✅ **Time series charts** - All metrics over time
- ✅ **Breakdown tables** - By country, platform, content type

**Result:** All visualizations matched original dashboard exactly across all test scenarios.

**Issues Found:** None - All calculated fields produced equivalent results to original separated queries.

**Validation Duration:** ~1-2 weeks of systematic testing and comparison

**Sign-off:** 
- Reviewed dashboard with supervisor
- Demonstrated equivalence to original dashboard
- Confirmed all metrics accessible and accurate
- Presented to the stakeholders

---

### Phase 3 Results

**Dashboard Integration:**
- ✅ **4 dynamic parameters** implemented for self-service filtering
- ✅ **20+ calculated fields** created in dashboard schema
- ✅ **All visualizations validated** - 100% match to original dashboard
- ✅ **Tested across multiple scenarios** - Different dates, platforms, markets, variants

**Dashboard Performance:**
- **Before (21 queries):** Days to load, frequent timeouts
- **After (1 consolidated query + 2 converted queries + 3 original query):** **3-8 minutes** consistently
- **Improvement:** Dashboard now usable for real-time experiment monitoring

**Maintainability Improvements:**
- **Before:** 21 queries to update when logic changes
- **After:** 5 queries to maintain, calculations visible in dashboard schema
- **Impact:** Reduced maintenance burden, easier knowledge transfer

**Final Dashboard Architecture:**

**Databricks Dashboard**
• 4 Dynamic Parameters
• 20+ Calculated Fields (Schema)
• 15+ Visualizations

▼

**Consolidated Query**
• 1 main query (replaces 16)
• 2 converted queries
• 3 original queries
• Total: 6 queries (was 21 originally)

▼

**Purpose-Built Analytical Table:**
analytics_events

**Documentation Delivered:**
- Calculated field definitions and formulas
- Validation results spreadsheet
- Migration notes for future reference

---

## Overall Results

### Project Summary

Successfully optimized Career Hub Experiment dashboard through systematic three-phase approach: data migration, query consolidation, and dashboard integration.

### Quantified Impact

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Dashboard Load Time** | Days (frequent timeouts) | 12 seconds | **70%+ reduction** |
| **Number of Queries** | 21 separate queries | 6 queries (1 main + 5 supporting) | **71% reduction** |
| **Database CPU Usage** | High (impacting other users) | Normal | **~60% reduction** |
| **Successfully Migrated** | N/A | 18 out of 21 queries | **86% success rate** |
| **Data Accuracy** | Baseline | 100% match validated | **0% variance** |
| **Maintainability** | 21 queries to update | 1 main query to update | **95% reduction in maintenance** |

### Timeline

- **Phase 1 (Migration):** 3-4 weeks
- **Phase 2 (Consolidation):** 3-4 weeks  
- **Phase 3 (Dashboard Integration):** 2-3 weeks
- **Total Project Duration:** ~3 months

### Key Deliverables

1. **Migrated analytical foundation** - 18 queries on purpose-built table
2. **Consolidated query architecture**
3. **Self-service dashboard** - 4 parameters + 20+ calculated fields
4. **Comprehensive documentation** - Schema mapping, validation results, usage guides
5. **Knowledge transfer** - Process documented for future optimization projects

**Stakeholder and Team Feedback:**
- Engagement & Career Hub team: "Dashboard is finally usable for decision-making"
- Business users: "Love that now it is usable"

---

## Skills Demonstrated

**SQL & Data Engineering:**
- Data migration and schema mapping
- Data validation at scale
- Flag-based architecture for analytics (learned through Supervisor)

**Analytical & Problem-Solving:**
- Pattern recognition (found consolidation opportunities)
- Multi-phase project planning (migration → consolidation → optimization)
- Systematic validation methodology

**Documentation & Communication:**
- Technical documentation (schema mapping, query logic, validation results)

---

## Business Impact

**Performance Improvement:**
- Dashboard load time: Days → 3-8 minutes (70%+ reduction)
- Database CPU usage: ~60% reduction
- Eliminated resource contention for other Databricks users

**Operational Efficiency:**
- Maintenance: 21 queries → 6 queries (71% reduction)
- Self-service: Users can filter without SQL edits
- Real-time monitoring: Stakeholders access experiment data instantly

**Scalable Foundation:**
- Purpose-built analytical table supports future dashboards
- Flag-based pattern reusable for other projects
- Migration methodology documented for team

---

## Key Takeaways

**Fix the Foundation First:** Performance issues often stem from data architecture, not just query logic. Migration to purpose-built table enabled consolidation to be effective.

**Validate Obsessively:** 100% accuracy validation gave stakeholders confidence to adopt new dashboard. Without thorough validation, performance gains wouldn't matter if data was wrong.

**Trade-offs Are Acceptable:** 3 queries couldn't migrate, 2 queries couldn't consolidate - keeping them separate was acceptable. Perfect consolidation wasn't required for 70% improvement.

**Documentation Enables Scale:** Comprehensive documentation means this approach can be replicated for other dashboards facing similar issues.

---

## Tools & Technologies

- **Databricks:** Notebook, dashboard development
- **SQL:** Query development, optimization, CTEs
- **Excel:** Data validation, comparison analysis, automated calculations, documentation

---

[← Back to Projects](/projects.md)
