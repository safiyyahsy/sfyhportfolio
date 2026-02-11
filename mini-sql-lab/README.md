# Mini SQL Lab (Mock Data)
**github folder:** https://github.com/safiyyahsy/sfyhportfolio/tree/main/mini-sql-lab

This folder contains a small, public-safe SQL mini project to demonstrate my SQL skills without using any employer data or internal methodology.

## What’s inside
- `schema.sql` — creates tables
- `data/` — small CSV files (mock data)
- `queries/` — example SQL queries

## Skills demonstrated
- CTEs and multi-step transformations
- Segmentation with CASE WHEN
- Cohort/retention style analysis
- Multi-grain modeling via UNION ALL
- Validation and reconciliation checks

## How to run (any SQL tool)
1. Create a new database (Postgres / SQLite / DuckDB — any works)
2. Run `schema.sql`
3. Import CSV files from `data/` into the tables
4. Run queries in `queries/` in order

---

## Data dictionary (mock)

These fields are intentionally generic and **not tied to any employer implementation**.

- `country`: anonymized market code (c1..c8)
- `platform`: client type (`ios`, `android`, `web`)
- `channel`: high-level acquisition channel (`organic`, `paid`, `email`)
- `campaign`: campaign label (e.g., `summer_push`, `june_newsletter`)
- `action_origin`: entry surface where content was discovered (`home`, `search`, `notification`)
- `event_name`: generic event type (`content_view`, `play`, `watch`, `complete`)

## Notes on confidentiality
This mini lab is a personal demo using mock data and generic SQL patterns.
