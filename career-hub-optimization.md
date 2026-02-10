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

**Conversion Process:**

1. **Identify pattern within group** - Find the common query structure
2. **Convert first query in pattern** - Apply all schema mappings, test thoroughly
3. **Use as template** - Adapt the working conversion for similar queries
4. **Individual testing** - Run each converted query and verify output
5. **Document issues** - Track which queries had problems

**Tracking Method:**

- Used Databricks notebook with clear section headers for each query
- Named queries descriptively: `Query_01_Content_Exposure`, `Query_02_Content_Engagement`, etc.
- Commented each query with: Original purpose, conversion date, validation status
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
- Their resource impact was minimal compared to the total 21 original queries
- Full migration would have required additional data engineering work beyond project scope

**Step 4: Validation**

Ensuring data accuracy was critical since the dashboard informed experiment decisions affecting product strategy.

**Validation Methodology:**

Created comprehensive validation spreadsheet comparing original vs. converted queries at granular level.

**Validation Structure:**

For each converted query, compared results across all dimension combinations:
- **Dimensions validated:** Site (market), Platform (iOS/Android), Experiment Variant (control/treatment)
- **Metrics validated:** Users, Visits, Visit_per_UV (visits per unique visitor)
- **Calculation:** Difference = Converted - Original, % Difference = (Difference / Original) × 100

**Validation Spreadsheet Format:**

| Site | Platform | Variant | Users (Original) | Visits (Original) | Visit_per_UV (Original) | Users (Converted) | Visits (Converted) | Visit_per_UV (Converted) | % Diff Users | % Diff Visits | % Diff Rate |
|------|----------|---------|------------------|-------------------|-------------------------|-------------------|--------------------|--------------------------|--------------|--------------|--------------| 
| Market A | android | 0 | 16,063 | 23,557 | 1.466538007 | 16,063 | 23,557 | 1.466538007 | 0% | 0% | 0% |
| Market A | ios | 0 | 24,364 | 37,159 | 1.525160072 | 24,364 | 37,159 | 1.525160072 | 0% | 0% | 0% |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

**Validation Coverage:**

- **18 converted queries** validated
- **~30-50 dimension combinations** per query (sites × platforms × variants)
- **3 core metrics** per combination: Users, Visits, Calculated Rate
- **Total validation rows:** 500+ individual comparisons

**Sample Validation Results (Query: Content Exposure):**

| Site | Platform | Variant | Users | Visits | Visit_per_UV | Difference | Status |
|------|----------|---------|-------|--------|--------------|------------|--------|
| jobhk | android app | 0 | 16,063 | 23,557 | 1.4665 | 0% all metrics | ✅ Match |
| jobhk | ios app | 0 | 24,364 | 37,159 | 1.5252 | 0% all metrics | ✅ Match |
| jobth | android app | 0 | 45,308 | 62,602 | 1.3817 | 0% all metrics | ✅ Match |
| jobid | ios app | 1 | 73,111 | 114,192 | 1.5619 | 0% all metrics | ✅ Match |
| jobau | android app | 0 | 163,567 | 206,113 | 1.2601 | 0% all metrics | ✅ Match |
| jobnz | ios app | 0 | 34,897 | 43,851 | 1.2566 | 0% all metrics | ✅ Match |

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
- ✅ User counts: 0% variance
- ✅ Visit counts: 0% variance  
- ✅ Calculated rates: 0% variance
- ✅ All dimension combinations validated

**No discrepancies found** - Schema mapping was accurate, logic preserved correctly.

**Validation Duration:** ~1 week of systematic testing and documentation

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
