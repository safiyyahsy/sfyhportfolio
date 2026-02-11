---
layout: page
title: "End-to-End Dashboard Development: Skills Content Operations"
subtitle: Building analytics dashboard from data modeling to Tableau deployment
---

## Project Summary

**Context:** The content operations team needed a daily dashboard to monitor Skills content performance, identify traffic drivers, and evaluate engagement depth. Existing references included a daily Community Ops dashboard and a monthly Skills Health dashboard.

**My role:** Dashboard developer (SQL modeling + Tableau build). Requirements were provided and final work was reviewed by a Senior Data Analyst.

**Duration:** ~1 month

> **Confidentiality note:** SQL, schema/field names, and internal tracking/event taxonomy are intentionally omitted. The architecture and approach are presented at a high level, and I can demonstrate the patterns using mock datasets during interviews.

---

## Problem

- The team needed **daily** monitoring (previously available insights were mainly **monthly**)
- Stakeholders wanted both:
  - **Activation/volume** metrics (who engaged, where from, which content)
  - **Depth** metrics (watch minutes, completion rate)
- The dashboard needed drill-downs by:
  - market/platform
  - marketing channel / campaign
  - product discovery path (action origin)
  - module/video

---

## Approach (High Level)

### 1) Align to existing dashboard patterns
To ensure consistency and maintainability, I studied and reused proven patterns from:
- **Community Content Ops (daily)**: multi-grain modeling approach for BI dashboards
- **Skills Health (monthly)**: Skills metric definitions and depth metric calculations

### 2) Build two data models (separation of concerns)
I implemented a two-model design to keep logic clean and prevent mis-aggregation:

**Model 1 — Activation & Drivers (daily)**
- Supports overall trends and driver breakdowns (e.g., by channel, discovery path, module)
- Enables drill-down without requiring separate data sources for each view

**Model 2 — Depth Metrics (daily)**
- Watch minutes and completion rate logic adapted from the monthly Skills Health model
- Converted to **daily** granularity for operational monitoring

### 3) Build the Tableau dashboard
- Created all dashboard tabs and visualizations
- Implemented global filters (date, platform, country) and local drill-down filters (module/provider)
- Added a glossary/definitions panel to support self-service use
- Iterated based on senior review and stakeholder feedback

---

## What the Dashboard Enables

**Operational monitoring (daily):**
- Skills engagement volume and trends
- Under/over-performing modules
- Changes in engagement depth over time

**Driver insights:**
- Which marketing channels/campaigns drive Skills engagement
- Which product discovery paths contribute most to activation
- Content-level performance comparison across markets/platforms

**Depth insights:**
- Watch minutes by module
- Completion rate by module (quality/retention proxy)

---

## Deliverables

- Two daily-grain data models (activation/drivers + depth)
- Tableau dashboard with:
  - overall trends
  - driver breakdowns
  - module drill-down views
  - depth metrics views
- Documentation: metric definitions, glossary, and usage notes

---

## Skills Demonstrated

- BI dashboard development (Tableau): filters, calculated fields, layout, usability
- Data modeling: designing multi-grain datasets for dashboard use
- Adapting and improving existing patterns (monthly → daily)
- Validation and stakeholder review iteration
- Documentation for self-service analytics

## Tools
SQL • Databricks • Tableau • Excel

---

[← Back to Projects](/projects.md)
