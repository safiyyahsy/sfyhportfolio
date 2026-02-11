# Mini SQL Lab (Mock Data)

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

> Note: This is intentionally a toy dataset designed for demonstration.
