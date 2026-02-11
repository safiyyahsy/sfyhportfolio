---
layout: page
title: "End-to-End Dashboard Development: Skills Content Operations"
subtitle: Building analytics dashboard from data modeling to Tableau deployment
---

## Table of Contents

- [Project Overview](#project-overview)
- [Business Context](#business-context)
- [Project Phases](#project-phases)
- [Data Modeling Architecture](#data-modeling-architecture)
- [SQL Implementation](#sql-implementation)
- [Tableau Dashboard Development](#tableau-dashboard-development)
- [Skills Demonstrated](#skills-demonstrated)

---

## Project Overview

**Type:** Full dashboard development project  
**Duration:** ~1 month  
**Stakeholders:** Skills Content Operations Team  
**Purpose:** Enable content team to monitor Skills content performance with daily granularity, track activation drivers, and measure engagement depth  
**Tools:** SQL, Databricks, Tableau

**My Contribution:**
- Adapted existing dashboard patterns to Skills content metrics
- Built two data models (Model 1: UV/Activation, Model 2: Depth metrics)
- Enhanced from monthly to daily granularity for real-time monitoring
- Developed all Tableau visualizations
- Created dashboard glossary and documentation

**Collaboration:**
- Requirements gathered by Senior Data Analyst
- Data models reviewed by Senior Data Analyst
- Final dashboard validated with Senior Data Analyst

---

## Business Context

### Stakeholder Need

**Primary Users:** Skills Content Operations Team

**Business Problem:**
- Content team needed daily visibility into Skills content performance across markets (currently had monthly reporting)
- Existing Community Content Operations dashboard (daily) worked well - wanted similar structure for Skills
- Required real-time monitoring of: activation rates, video plays, watch time, content depth
- Needed ability to identify which marketing channels and product features drive content discovery

**Success Criteria:**
- Mirror Community Content Ops dashboard structure for team consistency
- Track activation by marketing channel and product discovery method (action origin)
- Enable content drill-down by module/video at daily grain
- Provide depth metrics (completion rate, watch time per module)
- Support multiple dimensions: date (daily), platform, country, channel, campaign, action origin, module

**Reference Dashboards:**

For alignment and pattern reuse, I studied two existing dashboards:

1. **Community Content Operations Dashboard (Model 2)** - Daily-based
   - Data modeling pattern: `base CTE → aggregation CTEs → UNION ALL`
   - Use of `data_type` field to separate aggregation levels in Tableau
   - Overall + breakdown structure

2. **Skills Health Dashboard (Model 1 & 2)** - Monthly-based
   - Event/UV framework approach
   - Module metadata lookup from reference table
   - Watch time and completion rate calculation logic

**My Adaptation:**
- Combined patterns from both reference dashboards
- Enhanced from monthly (Skills Health) to **daily granularity** (like Community Ops)
- Adapted Community's UNION ALL architecture for Skills metrics
- Built two separate models matching the two-model pattern from Skills Health

---

## Project Phases

### Phase 1: Requirements Review & Reference Dashboard Study

**Duration:** ~1 week

**Requirements Received (from Senior Data Analyst):**

The Senior Data Analyst gathered stakeholder requirements and provided me with clear specifications:

**Dashboard Structure:**
- Mirror the **Community Content Operations Dashboard** style for consistency
- Enable content team to use familiar interface patterns

**Key Metrics Required:**

1. **Conversion/Activation Metrics:**
   - Overall Content Consumption % (CC%)
   - Skills CC% (video-specific activation)
   - Community CC% (thread engagement)

2. **Volume Metrics:**
   - Daily Skills Unique Visitors (UV)
   - Play Events (total video plays)
   - Watch Minutes (total viewing time)

3. **Driver Analysis:**
   - Marketing Channel attribution (first-touch)
   - Product Discovery paths (Action Origin - where users found content)

4. **Content Performance:**
   - Module-level trends (which videos performing best)
   - Module-level tables with detailed metrics

5. **Depth Metrics:**
   - Completion rate by module
   - Watch minutes by module

**Dimensions Needed:**
- **Date:** Daily granularity (enhancement from monthly in existing Skills dashboard)
- **Platform:** iOS app, Android app
- **Country:** 8 SEEK markets (AU, NZ, SG, MY, PH, ID, HK, TH)
- **Marketing Channel:** First attribution channel
- **UTM Campaign:** Campaign identifier
- **Action Origin:** Product discovery path (homepage, search, bookmark, etc.)
- **Module Name:** Content identifier

---

### Reference Dashboard Analysis

To ensure alignment with existing patterns and avoid reinventing the wheel, I studied two reference dashboards:

**Reference 1: Community Content Operations Dashboard (Model 2) - Daily**

**What I learned:**
- **Data modeling pattern:** `comm_base` CTE → multiple aggregation CTEs → `UNION ALL` into single table
- **Key technique:** Use `data_type` field to label aggregation granularity
  - Example: `'overall_daily'`, `'tid_daily'` (thread ID), `'origin_daily'`, `'channel_campaign_daily'`
- **Why this matters:** Prevents incorrect aggregation mixing in Tableau (forces filtering on `data_type`)
- **Column structure:** All aggregation CTEs must have identical column order and names for UNION ALL compatibility
- **NULL pattern:** Dimensions not in GROUP BY set to NULL

**Code studied:** Event classification logic, aggregation patterns, union structure

---

**Reference 2: Skills Health Dashboard (Model 1 & 2) - Monthly**

**Model 1 (Event/UV framework):**
- Event tracking and UV calculation approach
- Module metadata lookup from Airtable reference table
- Learning category enrichment

**Model 2 (Watch time/depth):**
- Watch time calculation logic from video events
- Completion rate formula: `(sum(watch_time) / 60) / (max(video_duration) * sum(plays))`
- Module-level performance aggregation

**Code studied:** Video event filtering (`action_type = 'Tap To Play On Module Screen'`), watch time extraction, completion rate logic

---

### Design Decisions Made

**Decision 1: Two-Model Architecture**

Following Skills Health dashboard use of metrics, separated into two models:
- **Model 1:** UV, activation, drivers (who engaged, from where, which channel)
- **Model 2:** Depth metrics (how long they watched, completion rates)

**Rationale:** Different calculation logic and granularity requirements for each metric type

---

**Decision 2: Adopt Community Model 2 UNION ALL Pattern**

For Model 1, used Community dashboard's architecture:
- Base CTE with all events
- Multiple aggregation CTEs at different granularities
- UNION ALL into single table
- `data_type` field for Tableau filtering

**Rationale:** 
- Proven pattern already in production
- Team familiarity (easier handoff and maintenance)
- Stakeholders prefer consistent dashboard structure

---

**Decision 3: Daily Granularity (Enhancement)**

**Original Skills Health:** Monthly aggregation  
**My Implementation:** Daily aggregation

**Rationale:**
- Content team needed real-time monitoring (not monthly lag)
- Aligned with Community dashboard's daily grain
- Enabled faster identification of content performance issues

**Trade-off:** Larger data volume, but acceptable for 6-month rolling window

---

**Decision 4: Module Metadata Lookup (Adapted)**

Reused Skills Health Model 1 approach:
- Join to module reference table for clean module titles
- Fallback to event module name if metadata missing
- Ensured consistent naming across dashboard

---

### Key Learnings from Reference Study

**What worked in existing dashboards:**
- UNION ALL pattern keeps Tableau simple (one data source)
- `data_type` field prevents aggregation errors
- Consistent column structure critical for UNION compatibility
- NULL pattern for unused dimensions makes intent clear

**What I needed to adapt:**
- Community pattern was for thread events, needed adaptation for video events
- Skills Health was monthly, needed conversion to daily
- Combined learnings from both to build Skills Content Ops approach

**Time spent studying:** ~2-3 days understanding patterns before building

---

### Phase 2: Building Model 1 - UV & Activation Metrics

**Duration:** ~2 weeks
**Purpose:** Track who activated (UV), from where (drivers), and overall conversion rates

---

#### Step 1: Foundation - all_base CTE

**Goal:** Create standardized base dataset with all events classified and enriched with metadata.

**Adapted from:** Community Model 2 `comm_base` pattern

**What I Built:**

```sql
-- Foundation CTE: all_base
-- Adapted from Community dashboard pattern for Skills metrics

WITH all_base AS (
    SELECT
        metadata.date,
        metadata.uid,
        metadata.visit_id,
        metadata.utm_campaign,
        metadata.channel,
        metadata.link_position,
        metadata.platform,
        RIGHT(metadata.brand_country, 2) AS country,  -- Extract country code
        metadata.view_action_origin,
        metadata.learning_category,
        LEFT(metadata.module_id_tx, 9) AS module_id,  -- Standardize module ID format
        metadata.module_name,
        metadata.module_provider_meta,
        metadata.action_type,
        metadata.episodic_title,
        
        -- Event Classification Logic
        CASE 
            -- Community Events (for combined activation tracking)
            WHEN metadata.event_name = 'like_button_pressed' 
                AND metadata.link_position IN ('thread', 'thread card', 'thread comment') 
                AND metadata.link_action = 'like'
                AND metadata.loginid IS NOT NULL 
                THEN 'like_thread'
            
            WHEN metadata.event_name = 'like_button_pressed' 
                AND metadata.link_position IN ('thread', 'thread card', 'thread comment') 
                AND metadata.link_action = 'unlike' 
                THEN 'unlike_thread'
            
            WHEN metadata.event_name = 'share_pressed' 
                AND metadata.link_position = 'thread' 
                THEN 'share_pressed_thread'
            
            WHEN metadata.event_name IN (
                'reply_thread_post_pressed',
                'reply_thread_comment_post_pressed',
                'comment_thread_post_succeeded'
            ) THEN 'comment_thread'
            
            WHEN metadata.event_name = 'comment_succeeded' 
                AND metadata.link_action = 'reply comment posted' 
                AND metadata.link_position = 'thread comment reply' 
                THEN 'reply_comment'
            
            WHEN metadata.event_name IN (
                'create_thread_post_succeeded',  -- App event
                'create_thread_post_completed'   -- Web event
            ) THEN 'create_thread_completion'
            
            WHEN metadata.event_name = 'create_thread_displayed' 
                THEN 'create_thread_initiation'
            
            -- Skills Video Play Event (strict filtering)
            WHEN metadata.event_name = 'video_viewed' 
                AND metadata.action_type = 'Tap To Play On Module Screen'  -- Only intentional plays
                THEN 'video_viewed'
            
            ELSE metadata.event_name 
        END AS event_names
        
    FROM dataplatform.content_analytics.content_metadata metadata
    WHERE 1=1
        AND metadata.date >= ADD_MONTHS(CURRENT_DATE(), -6)  -- Rolling 6-month window
)
```
**Key Adaptations Made:**

**1. Event Classification Enhancement:**
- Adapted Community's thread event logic
- Added Skills video play event with action_type filter
- Standardized event names for consistency (e.g., web vs app event name differences)

**2. Module ID Standardization:**
```sql
LEFT(module_id_tx, 9) AS module_id
```
- Original module IDs had varying formats
- Standardized to first 9 characters for consistent grouping

**3. Geographic Extraction:**
```sql
RIGHT(brand_country, 2) AS country
```
- Brand_country format: 'jobhk', 'jobau'
- Extracted 2-letter country code for cleaner aggregation

**4. Date Range Optimization:**
```sql
WHERE date >= ADD_MONTHS(CURRENT_DATE(), -6)
```
- Limited to 6-month rolling window (vs. full history)
- Balances data availability with query performance
- Dashboard parameters allow further filtering

**5. Event Exclusions:**
- Excluded Skills-specific events handled in Model 2 (video pause, certificate events, bookmarks)
- Prevents duplication between models
- Keeps Model 1 focused on activation (not depth)

#### Step 2: Overall Aggregation - overall_daily CTE

**Granularity:** Date + Platform + Country (highest-level summary)

**Purpose:** Power top-level charts and overall trend analysis
```sql
overall_daily AS (
    SELECT 
        date,
        platform,
        country,
        NULL AS channel,           -- Not grouped by these dimensions
        NULL AS utm_campaign,
        NULL AS module_name,
        NULL AS module_provider_meta,
        NULL AS episodic_title,
        NULL AS view_action_origin,
        
        -- Community Activation UV
        COUNT(DISTINCT CASE WHEN event_names IN (
            'view_thread_displayed',
            'like_thread',
            'share_pressed_thread',
            'reply_comment',
            'comment_thread',
            'create_thread_completion'
        ) THEN uid END) AS comm_activ_uv,
        
        -- Skills Activation UV
        COUNT(DISTINCT CASE WHEN event_names = 'video_viewed' 
            THEN uid END) AS skills_uv,
        
        -- Combined Activation UV (Skills OR Community)
        COUNT(DISTINCT CASE WHEN event_names IN (
            'view_thread_displayed',
            'like_thread',
            'share_pressed_thread',
            'reply_comment',
            'comment_thread',
            'create_thread_completion',
            'video_viewed'
        ) THEN uid END) AS skills_comm_activ_uv,
        
        -- Video Play Events (granular tracking)
        COUNT(DISTINCT CASE WHEN event_names = 'video_viewed' 
            THEN CONCAT(module_name, visit_id) END) AS total_skills_events,
        
        -- Skills Visits (session-level)
        COUNT(DISTINCT CASE WHEN event_names = 'video_viewed' 
            THEN visit_id END) AS skills_visits,
        
        -- Total Content Hub UV (denominator for conversion %)
        COUNT(DISTINCT uid) AS ch_uv,
        
        'overall_daily' AS data_type
    FROM all_base
    GROUP BY date, platform, country
)
```

**Metrics Explained:**

| Metric | Purpose | Calculation Logic |
|--------|---------|-------------------|
| `comm_activ_uv` | Users who engaged with community features | Distinct users with thread engagement events |
| `skills_uv` | Users who played videos | Distinct users with video play event |
| `skills_comm_activ_uv` | Combined activation | Distinct users with either Skills OR Community events |
| `total_skills_events` | Granular play tracking | Distinct module+visit combinations (tracks multiple plays per visit) |
| `skills_visits` | Session-level plays | Distinct visits with video plays |
| `ch_uv` | Total Content Hub users | All distinct users (denominator for % calculations) |

**Why CONCAT(module_name, visit_id) for Events:**
- Tracks if same visit played multiple different modules
- More accurate than just COUNT(*) which includes pause/resume duplicates
- Enables per-visit engagement depth analysis

---

#### Step 3: Module Breakdown - module_daily CTE

**Granularity:** Date + Platform + Country + **Module Name** (content-level detail)

**Purpose:** Track performance of individual videos/modules

```sql
module_daily AS (
    SELECT 
        date,
        platform,
        country,
        NULL AS channel,
        NULL AS utm_campaign,
        module_name,              -- Content identifier
        module_provider_meta,     -- Content provider/partner
        episodic_title,           -- Series name if part of series
        NULL AS view_action_origin,
        
        NULL AS comm_activ_uv,    -- Not relevant at module level
        COUNT(DISTINCT uid) AS skills_uv,  -- Users who played this module
        NULL AS skills_comm_activ_uv,
        
        COUNT(DISTINCT visit_id) AS total_skills_events,  -- Plays of this module
        NULL AS skills_visits,
        NULL AS ch_uv,            -- Denominator not meaningful at module grain
        
        'module_daily' AS data_type
    FROM all_base
    WHERE event_names = 'video_viewed'  -- Only video play events
        AND action_type = 'Tap To Play On Module Screen'  -- Intentional plays only
    GROUP BY date, platform, country, module_name, module_provider_meta, episodic_title
)
```
**Why Filter to Specific Action Type:**
- Video events fire on multiple actions (play, pause, complete, resume)
- Only "Tap To Play On Module Screen" represents intentional content consumption
- Prevents over-counting from user pausing/resuming same video

**Dashboard Usage:** Powers "Video Viewed" tab with module trend charts and tables

#### Step 4: Action Origin Breakdown - action_origin_daily CTE
**Granularity:** Date + Platform + Country + View Action Origin (product discovery path)

**Purpose:** Identify which product features drive content discovery
```sql
action_origin_daily AS (
    SELECT
        date,
        platform,
        country,
        NULL AS channel,
        NULL AS utm_campaign,
        NULL AS module_name,
        NULL AS module_provider_meta,
        NULL AS episodic_title,
        view_action_origin,       -- Discovery path
        
        NULL AS comm_activ_uv,
        COUNT(DISTINCT uid) AS skills_uv,
        NULL AS skills_comm_activ_uv,
        
        COUNT(DISTINCT CASE WHEN event_names = 'video_viewed' 
            THEN CONCAT(module_name, visit_id) END) AS total_skills_events,
        COUNT(DISTINCT visit_id) AS skills_visits,
        NULL AS ch_uv,
        
        'origin_daily' AS data_type
    FROM all_base 
    WHERE event_names = 'video_viewed'
    GROUP BY date, platform, country, view_action_origin
)
```
**Action Origin Examples:**
- Homepage recommendation
- Search results
- Bookmark
- Notification
- Direct navigation
- External referral

**Dashboard Usage:** Powers "Product Discovery Channel" driver analysis

#### Step 5: Marketing Channel Breakdown - channel_campaign_daily CTE
**Granularity:** Date + Platform + Country + Channel + Campaign (marketing attribution)

**Purpose:** Track which marketing efforts drive Skills content engagement
```sql
channel_campaign_daily AS (
    SELECT 
        date,
        platform,
        country,
        LOWER(channel) AS channel,    -- Standardize case for consistency
        utm_campaign,                 -- Campaign identifier
        NULL AS module_name,
        NULL AS module_provider_meta,
        NULL AS episodic_title,
        NULL AS view_action_origin,
        
        NULL AS comm_activ_uv,
        COUNT(DISTINCT uid) AS skills_uv,
        NULL AS skills_comm_activ_uv,
        
        COUNT(DISTINCT CASE WHEN event_names = 'video_viewed' 
            THEN CONCAT(module_name, visit_id) END) AS total_skills_events,
        COUNT(DISTINCT visit_id) AS skills_visits,
        NULL AS ch_uv,
        
        'channel_campaign_daily' AS data_type
    FROM all_base
    WHERE event_names = 'video_viewed'
    GROUP BY date, platform, country, channel, utm_campaign
)
```
**Channel Examples:**
- Organic (direct traffic)
- Email campaigns
- Display ads (GDN)
- Social media
- Referrer - SEEK (cross-platform)
- Paid search

**Dashboard Usage:** Powers "Marketing Channel" driver analysis

#### Step 6: UNION ALL - Combining All Aggregations
```sql
SELECT * FROM overall_daily
UNION ALL SELECT * FROM module_daily
UNION ALL SELECT * FROM action_origin_daily
UNION ALL SELECT * FROM channel_campaign_daily
```
**Output:** Single table with 4 aggregation levels distinguished by data_type field

**Column Structure (must be identical across all CTEs):**

| Column | overall_daily | module_daily | origin_daily | channel_daily |
|--------|---------------|--------------|--------------|---------------|
| date | ✓ | ✓ | ✓ | ✓ |
| platform | ✓ | ✓ | ✓ | ✓ |
| country | ✓ | ✓ | ✓ | ✓ |
| channel | NULL | NULL | NULL | ✓ |
| module_name | NULL | ✓ | NULL | NULL |
| view_action_origin | NULL | NULL | ✓ | NULL |
| skills_uv | ✓ | ✓ | ✓ | ✓ |
| ch_uv | ✓ | NULL | NULL | NULL |
| data_type | 'overall_daily' | 'module_daily' | 'origin_daily' | 'channel_daily' |

**Critical Learning:** UNION ALL matches by column **position**, not name. All CTEs must have exact same column count, order, and data types.

---

---

### Phase 3: Building Model 2 - Depth Metrics (Watch Time & Completion Rate)

**Duration:** ~1 week
**Purpose:** Measure how deeply users engage with content (watch duration, completion rates)

**Adapted from:** Skills Health Dashboard Model 2 (monthly) → Enhanced to daily granularity

---

#### Goal

Track video engagement depth at module level:
- How long users watch each video (watch minutes)
- What percentage of videos users complete (completion rate)
- Which modules have highest/lowest engagement depth

**Why Separate from Model 1:**
- Different calculation logic (watch time aggregation vs. simple UV counts)
- Different granularity needs (requires video-level detail)
- Different event filtering (needs pause/complete events, not just play)

---

#### Step 1: Watch Time Calculation - watch_mins CTE

**Challenge:** Calculate accurate watch time from video engagement events.

**Video Event Types:**
- `video_viewed` with action types: Play, Pause, Video Complete, Back Button, Continue Play
- Each action fires an event with `video_watch_time` field
- Need to capture MAX watch time per user per video (not sum, which would double-count)

**My Implementation:**

```sql
WITH watch_mins AS (
    SELECT  
        date,
        platform,
        RIGHT(brand_country, 2) AS country,
        visit_id,
        module_provider_meta,
        module_name,
        learning_category,
        episodic_title,
        module_id_tx,
        uid,
        loginid AS candidate_id,
        video_or_playlist,
        video_length / 60 AS video_duration_mins,  -- Convert seconds to minutes
        
        -- Count plays (only intentional play actions)
        SUM(CASE 
            WHEN event_name IN ('video_viewed') 
                AND action_type IN ('Tap To Play On Module Screen') 
            THEN 1 END) AS total_plays,
        
        -- Calculate max watch time (prevents double-counting from multiple events)
        MAX(CAST(CASE 
            WHEN ((video_or_playlist = 'Video' 
                AND event_name IN ('video_viewed') 
                AND action_type IN ('Pause Video', 'Video Complete', 'Back Button')) 
                OR event_name IN ('video_viewed')) 
                AND video_watch_time <= video_length  -- Data quality: watch time can't exceed video length
                AND CAST(video_watch_time AS INT) > 0  -- Exclude zero or negative values
            THEN video_watch_time 
        END AS INT)) AS video_watch_time,
        
        MAX(date) AS max_latest_date
        
    FROM dataplatform.content_analytics.content_metadata
    WHERE event_name IN ('video_viewed')
        AND action_type IN (
            'Pause Video',
            'Video Complete',
            'Back Button',
            'Back To Previous Page',
            'Continue Play Video',
            'Play Video',
            'Tap To Play On Module Screen',
            'Tap To Play'
        )
        AND date BETWEEN '2025-01-01' AND '2025-01-07'  -- Daily date filter
    GROUP BY ALL
)
```
**Key Logic Decisions:**

**1. MAX Watch Time (not SUM):**
- Multiple events fire as user watches (pause, resume, complete)
- SUM would count same viewing multiple times
- MAX captures furthest point user reached in video

**2. Data Quality Filters:**
```sql
AND video_watch_time <= video_length  -- Can't watch more than video duration
AND CAST(video_watch_time AS INT) > 0  -- Exclude invalid data
```
- Prevents anomalies from tracking errors
- Ensures clean calculation inputs

**3. Total Plays vs Watch Time:**
- total_plays: Counts intentional play initiations
- video_watch_time: Measures actual viewing duration

**Different purposes:** plays = engagement frequency, watch time = engagement depth

**4. Granularity:**
- Grouped by: date, visit, uid, module
- Enables both user-level and module-level aggregation downstream

---

#### Step 2: Module-Level Aggregation - watch_mins2 CTE

**Granularity:** Date + Platform + Country + Module (daily module performance)

**Purpose:** Calculate completion rate and aggregate watch minutes by module

```sql
watch_mins2 AS (
    SELECT 
        date,
        platform,
        country,
        module_provider_meta,
        learning_category,
        module_name,
        episodic_title,
        module_id_tx,
        video_or_playlist,
        
        -- Completion Rate Calculation
        (SUM(video_watch_time) / 60) / (MAX(video_duration_mins) * SUM(total_plays)) AS completion_rate,
        
        -- User and engagement metrics
        COUNT(DISTINCT uid) AS play_uv,
        SUM(video_watch_time) / 60 AS watch_mins,  -- Total watch minutes
        COUNT(DISTINCT visit_id) AS skill_visits,
        NULL AS visits,          -- CH total visits (not at module level)
        NULL AS career_uv,       -- Total UV (not at module level)
        COUNT(*) AS total_plays,
        MAX(max_latest_date) AS latest_data_date,
        
        'daily_breakdown' AS data_type
    FROM watch_mins
    GROUP BY date, platform, country, module_provider_meta, learning_category, 
             module_name, episodic_title, module_id_tx, video_or_playlist
)
```
**Key Metric: Completion Rate Formula**

```sql
completion_rate = (SUM(watch_time) / 60) / (MAX(video_duration) * SUM(plays))
```
****Formula Breakdown:****
- Numerator: SUM(video_watch_time) / 60 = Total minutes watched
- Denominator: MAX(video_duration_mins) * SUM(total_plays) = Total possible watch time
- Result: Percentage of video actually watched

Example:
- Video duration: 10 minutes
- Total plays: 100 times
- Total watch time: 500 minutes
- Completion rate: 500 / (10 × 100) = 0.50 = 50%
- Interpretation: On average, users watch 50% of this video's content

****Why This Formula:****
- Accounts for multiple plays (users may replay content)
- Normalizes across different video lengths
- Industry-standard completion rate calculation

**Step 3: Overall Totals - uv_breakdown CTE**
**Granularity:** Date + Platform + Country (overall totals for denominator calculations)

**Purpose:** Provide total UV and visit counts for per-user metric calculations in Tableau

```sql
uv_breakdown AS (
    SELECT 
        date,
        platform,
        RIGHT(brand_country, 2) AS country,
        NULL AS module_provider_meta,
        NULL AS learning_category,
        NULL AS module_name,
        NULL AS episodic_title,
        NULL AS module_id_tx,
        NULL AS video_or_playlist,
        NULL AS completion_rate,
        
        -- Play-specific UV
        COUNT(DISTINCT CASE WHEN event_name = 'video_viewed' 
            THEN uid END) AS play_uv,
        NULL AS watch_mins,
        
        -- Visit-level tracking
        COUNT(DISTINCT CASE WHEN event_name = 'video_viewed' 
            THEN visit_id END) AS skill_visits,
        COUNT(DISTINCT visit_id) AS visits,  -- Total CH visits (all events)
        
        -- Total UV (all Content Hub users)
        COUNT(DISTINCT uid) AS career_uv,
        NULL AS total_plays,
        MAX(date) AS latest_data_date,
        
        'daily_total' AS data_type
    FROM dataplatform.content_analytics.content_metadata
    WHERE 1=1
        AND date BETWEEN '2025-01-01' AND '2025-01-07'
    GROUP BY date, platform, country
    ORDER BY date DESC
)
```
**Purpose of This CTE:**

Provides denominators for Tableau calculated fields
Example: Watch mins per user = [watch_mins] / [career_uv]
Enables per-user, per-visit normalization

**Step 4:** Final UNION - Model 2 Output
```sql
SELECT * FROM watch_mins2      -- Module-level depth metrics
UNION ALL
SELECT * FROM uv_breakdown     -- Overall totals for denominators
```
**Output Structure:**

| data_type | Has completion_rate | Has module_name | Has career_uv | Purpose |
|-----------|---------------------|-----------------|---------------|---------|
| `daily_breakdown` | ✓ | ✓ | NULL | Module-level depth analysis |
| `daily_total` | NULL | NULL | ✓ | Overall totals for per-user calculations |

**Tableau Dashboard Usage:**
- Completion rate charts: Filter `data_type = 'daily_breakdown'`
- Per-user metrics: Use `daily_total` for denominator, `daily_breakdown` for numerator

---

### Model 2 Key Enhancements

## Enhancement 1: Daily Granularity (from monthly reference)

**Reference:** Skills Health Model 2 used `date_month`
**My implementation:** Changed to `date` for daily tracking
**Impact:** Real-time monitoring instead of monthly lag

## Enhancement 2: Data Quality Filters
```sql
AND video_watch_time <= video_length  -- Prevent tracking errors
AND CAST(video_watch_time AS INT) > 0  -- Exclude invalid values
```
- Added validation logic not in reference
- Ensures clean completion rate calculations

### Enhancement 3: Simplified Date Filtering

**Reference:** Used date_month >= add_months(current_date(), -12)
**My implementation:** Direct date range for testing: date BETWEEN '2025-01-01' AND '2025-01-07'
Production version uses dashboard parameters for flexibility

---

## Tableau Dashboard Development

### Dashboard Structure

**Data Sources:**
- **Model 1:** UV, activation, and driver metrics
- **Model 2:** Watch time and completion rate metrics

**Global Filters Applied to All Visualizations:**
- Date Range (default: last 30 days, adjustable)
- Platform (iOS app, Android app, or both)
- Country (multi-select across 8 markets)

**Dashboard Tabs:**
1. **Overall Tab** - High-level KPIs and driver analysis
2. **Video Viewed Tab** - Module-level content performance and depth

---

### Tab 1: Overall Performance & Drivers

**Purpose:** Monitor overall activation trends and identify what drives content discovery

**Visualizations Built:**

**1. Conversion Rate Trend (Line Chart)**
- **Metrics:** Overall CC%, Skills CC%, Community CC%
- **X-axis:** Date (daily)
- **Y-axis:** Conversion percentage
- **Data source:** Model 1, `data_type = 'overall_daily'`
- **Calculated fields:**
  - `Skills CC% = [skills_uv] / [ch_uv] × 100`
  - `Community CC% = [comm_activ_uv] / [ch_uv] × 100`
  - `Overall CC% = [skills_comm_activ_uv] / [ch_uv] × 100`

**2. Daily Skills UV (Stacked Area Chart)**
- **Metric:** Skills Unique Visitors
- **Dimensions:** Date (X-axis), Country (color stack)
- **Data source:** Model 1, `data_type = 'overall_daily'`
- **Purpose:** Track total user activation volume by market

**3. Play Events (Stacked Area Chart)**
- **Metric:** Total video play events
- **Dimensions:** Date (X-axis), Country (color stack)
- **Data source:** Model 1, `data_type = 'overall_daily'`
- **Purpose:** Track content consumption frequency

**4. Watch Minutes (Stacked Area Chart)**
- **Metric:** Total watch minutes
- **Dimensions:** Date (X-axis), Country (color stack)
- **Data source:** Model 2, `data_type = 'daily_total'`
- **Calculated field:** `SUM([watch_mins])`
- **Purpose:** Track content consumption depth

---

**Driver Analysis Section:**

**5. Marketing Channel Activation (Trend + Table)**

**Trend Chart (Line):**
- **Metric:** Skills CC% by channel
- **Data source:** Model 1, `data_type = 'channel_campaign_daily'`
- **Calculated field:** `Skills UV / Total UV` by channel
- **Filters:** Top N channels by volume
- **Purpose:** To identify the trend

**Table (Heatmap):**
- **Rows:** Marketing Channel
- **Columns:** Date (daily)
- **Values:** Skills UV (color-coded)
- **Purpose:** Identify which channels consistently drive engagement

**6. Product Discovery Driver (Action Origin)**

**Trend Chart (Line):**
- **Metric:** Skills CC% by action origin
- **Data source:** Model 1, `data_type = 'origin_daily'`
- **Calculated field:** `Skills UV / Total UV` by origin
- **Filters:** Top N origins selector (parameter-driven)
- **Purpose:** To identify the trend

**Table (Heatmap):**
- **Rows:** Action Origin (product feature)
- **Columns:** Date (daily)
- **Values:** Skills UV (color-coded)
- **Purpose:** Identify which product features drive content discovery

**Top N Filter Implementation:**
- Dashboard parameter: "Top N Origins" (default: 10)
- Filters action_origin by rank based on total UV
- Reduces clutter while highlighting key drivers

---

### Tab 2: Video Viewed (Module Performance & Depth)

**Purpose:** Deep dive into individual module/video performance

**Visualizations Built:**

**7. Video Viewed CC% by Module (Multi-line Trend)**
- **Metric:** Skills UV by module over time
- **Data source:** Model 1, `data_type = 'module_daily'`
- **Lines:** Each module (top 10-15 by default)
- **Filters:** Module name selector, provider selector
- **Purpose:** Identify trending content and performance changes

**8. Video Viewed CC% Table (Heatmap)**
- **Rows:** Module Name
- **Columns:** Date
- **Values:** Skills UV (color intensity by volume)
- **Data source:** Model 1, `data_type = 'module_daily'`
- **Purpose:** Precise daily values for each module

**9. Completion Rate by Module (Table Heatmap)**
- **Rows:** Module Name
- **Columns:** Date
- **Values:** Completion Rate % (color: green = high, red = low)
- **Data source:** Model 2, `data_type = 'daily_breakdown'`
- **Purpose:** Identify which content users finish vs. abandon

**10. Watch Minutes by Module (Table Heatmap)**
- **Rows:** Module Name
- **Columns:** Date
- **Values:** Total watch minutes (color by intensity)
- **Data source:** Model 2, `data_type = 'daily_breakdown'`
- **Purpose:** Measure total engagement depth per module

**Local Filters (Tab 2 only):**
- Module name selector
- Module provider selector
- Episodic title filter (for series content)

---

### Dashboard Features

**1. Glossary Panel**

Created reference panel explaining all metrics:

**Metric Definitions:**
- **Skills UV:** Unique users who played at least one video
- **Overall CC%:** Percentage of CH users who activated (Skills OR Community)
- **Skills CC%:** Percentage of CH users who played videos
- **Community CC%:** Percentage of CH users who engaged with threads
- **Play Events:** Total video play initiations
- **Watch Mins:** Total minutes of video content consumed
- **Completion Rate:** Percentage of video content actually watched

**Data Quality Notes:**
- "Data may have 1-day delay for complete processing"
- "Completion rate calculated at module+visit+user level"
- "Action origin may be NULL for organic traffic"

**Purpose:** Enable self-service - users can understand metrics without asking analyst

---

**2. Parameter-Driven Flexibility**

**Global Parameters:**
- Date range selector (default: last 30 days, adjustable to custom range)
- Platform filter (multi-select)
- Country filter (multi-select)

**Local Parameters:**
- Top N modules to display (reduces visual clutter)
- Module provider filter (isolate specific content partners)

**Benefit:** Stakeholders can explore data without SQL knowledge or analyst intervention

---

## Validation & Deployment

### Data Model Validation

**Model 1 Testing:**
- Verified `data_type` filtering worked correctly in Tableau
- Checked NULL patterns for unused dimensions
- Validated UNION ALL column alignment (all dimensions appearing in correct columns)
- Compared overall totals against source tables for sanity checks

**Model 2 Testing:**
- Validated completion rate formula with manual calculations for sample modules
- Checked watch time values against expected ranges (0-100% of video duration)
- Verified denominator logic (career_uv from `daily_total` accessible in Tableau)

**Cross-Model Validation:**
- Verified `skills_uv` counts matched between Model 1 and Model 2
- Checked date ranges aligned across both models
- Ensured no metric discrepancies between models

---

### Dashboard Review Process

**Internal Review (with Senior Data Analyst):**
- Walked through dashboard layout and logic
- Explained calculated fields and data sources
- Received feedback on visualization choices
- Iterated on chart types and filters based on suggestions

**Iterations Made:**
- Added Top N filter for action origins (reduced visual clutter)
- Enhanced glossary with more detailed metric definitions
- Adjusted color schemes for better readability
- Added data delay caveat note

---

### Deployment

**Steps Taken:**
1. Published dashboard to Tableau Server
2. Set up refresh schedule (daily at 6 AM)
3. Configured user permissions (Content Ops team access)
4. Conducted dashboard walkthrough session with team

---

## Impact & Outcomes (Summary)

- Enabled **daily monitoring** of Skills content performance (previously monthly reporting)
- Provided **self-service drill-downs** by module, marketing channel, and product discovery path (action origin)
- Added **depth metrics** (watch minutes + completion rate) to support content quality decisions

## What I Built

**Data models (SQL, Databricks):**
- **Model 1 (Activation/Drivers):** multi-CTE + `UNION ALL` architecture with `data_type` to support multiple aggregation levels in Tableau
- **Model 2 (Depth):** daily watch minutes + completion rate calculations adapted from monthly Skills Health model

**Tableau dashboard:**
- Built **all visualizations** and filter logic (global vs local filters)
- Added glossary/definitions panel for stakeholder self-service
- Senior Data Analyst reviewed the final dashboard and logic

## Skills Demonstrated

- **SQL & data modelling:** CTE design, conditional logic, multi-grain modelling via `UNION ALL`, daily vs monthly conversion
- **BI / Tableau:** dashboard build, calculated fields, parameters/filters, visual design for stakeholders
- **Analytics execution:** translating requirements into metrics, validation checks, iteration based on review feedback
- **Documentation:** metric definitions + usage notes (glossary)

## Tools
SQL • Databricks • Tableau • Excel

---

## Key Takeaways
- Reusing proven dashboard modelling patterns (with clear enhancements) improves delivery speed and maintainability.
- Separating activation metrics vs depth metrics into two models keeps logic cleaner and reduces risk of mis-aggregation.

---

[← Back to Projects](/projects.md)
