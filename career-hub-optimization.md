---
layout: page
title: "Case Study: Career Hub Dashboard Optimization"
subtitle: A two-phase approach to data migration and query consolidation
---

## Project Overview

**Duration:** ~3 months  
**Role:** Product Analytics Intern  
**Company:** SEEK (Jobstreet)  
**Tools:** Databricks, SQL, Tableau, Confluence

---

## The Problem

The Career Hub Experiment dashboard was critical for tracking user engagement experiments across multiple markets (AU, NZ, SG, MY, PH, ID, HK, TH). However, it had become unusable:

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
- Stakeholders couldn't access experiment results in time to make decisions
- Blocked other analytics work due to resource contention
- Risk of missing experiment insights during critical testing periods

---

## Solution Approach

Thus, the proposed solution are:

1. **Phase 1 (Foundation):** Migrate to purpose-built analytical table
2. **Phase 2 (Optimization):** Consolidate query logic using CTEs

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
- Documented all 21 queries and their purpose
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
- Rewrote each query using new table schema
- Maintained original logic exactly
- Added validation queries to compare results

**Step 4: Validation**
- Ran old and new queries side-by-side
- Compared row counts, metrics, aggregations
- Line-by-line verification for accuracy

### Example: Migration of Content Exposure Query

**BEFORE (using candidate_staging):**
```sql
-- Original query structure (simplified for confidentiality)
SELECT
    event_date_utc,
    experiment_variant,
    COUNT(DISTINCT uid) as visitors,
    COUNT(DISTINCT content_impression_id) as impressions
FROM candidate_staging
WHERE 1=1
    AND event_date_utc BETWEEN '2024-09-01' AND '2024-09-30'
    AND event_name = 'content_viewed'
    AND experiment_variant IS NOT NULL
    AND LOWER(country) IN ('au', 'nz', 'sg', 'my')
GROUP BY event_date_utc, experiment_variant;
