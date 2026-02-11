---
layout: page
title: "Case Study: Career Hub Dashboard Optimization"
subtitle: A two-phase approach to data migration and query consolidation
---

## Project Summary

**Context:** A production analytics dashboard used to monitor experiments became effectively unusable due to long load times and high resource consumption.

**My role:** Product Analytics Intern (data modeling + SQL optimization + dashboard rebuild and validation)

**Outcome:**
- Reduced dashboard load time by **70%+** (from days/timeouts to seconds/minutes depending on filters)
- Reduced resource contention impacting other Databricks users
- Reduced query maintenance overhead (21 queries → 6)

> **Confidentiality note:** Company-specific implementation details (schemas, event taxonomy, SQL logic, and internal methodology) are intentionally omitted. I can walk through the technical approach in an interview using mock data examples.

---

## Problem

The dashboard had:
- **21 separate queries** hitting large shared datasets
- repeated filters and duplicate logic across queries
- heavy compute usage that impacted other users
- slow performance (timeouts / multi-hour or multi-day load behavior depending on query set)

---

## Approach (High Level)

### Phase 1 — Migration (foundation)
- Moved dashboard logic away from a generic shared dataset to a more fit‑for‑purpose analytical structure
- Performed source‑to‑target mapping and ensured definitions stayed consistent
- Identified a small subset of queries that could not be migrated due to unavailable fields and kept them separate

### Phase 2 — Consolidation (performance)
- Looked for repeated patterns across the migrated queries
- Consolidated **16** compatible queries into a single main query output (two additional queries remained separate due to incompatible aggregation grain)
- Reduced redundant scans by centralizing shared filters and logic

### Phase 3 — Dashboard rebuild & validation
- Recreated the Databricks dashboard using the optimized query structure
- Added parameters and calculated fields to support dashboard filtering and metric computation
- Validated the rebuilt dashboard against the archived original to ensure outputs matched

---

## Validation (What I Checked)

To ensure data quality, I validated at the same grain each query/reporting output required:
- spot checks of results across key breakdowns (e.g., market/platform/variant where applicable)
- reconciliation checks (totals and rates)
- sanity checks over time and across markets
- ensured the rebuilt dashboard matched the original dashboard outputs for the same filters

---

## Deliverables

- Optimized query set (21 → 6 total queries)
- Rebuilt Databricks dashboard (matching archived original visual outputs)
- Documentation: assumptions, metric definitions, validation notes, and change log

---

## Skills Demonstrated

- SQL optimization (pattern consolidation, reducing redundant scans)
- Data migration & mapping (source → analytical structure)
- Validation methodology (accuracy + reconciliation)
- Dashboard development (Databricks dashboard parameters + calculated fields)
- Technical documentation

---

[← Back to Projects](/projects.md)
