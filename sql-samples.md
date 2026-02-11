---
layout: page
title: SQL Code Samples
subtitle: Real-world SQL techniques from production analytics work
---

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

---

## Snippet 1 (Segmentation)

```markdown
## 1) segmentation with case when

**context:** classify users into simple segments using mock profile attributes.  
**demonstrates:** `case when`, ctes, grouping.

```sql
with base as (
  select
    user_id,
    case
      when is_student = 1 then 'student'
      when is_student = 0 and grad_year is not null and grad_year <= 2025 then 'graduate'
      else 'other'
    end as user_segment
  from users
)
select user_segment, count(*) as users
from base
group by user_segment
order by users desc;
```

---

## Snippet 2 (Window function / cohort)

```markdown
## 2) cohorting (first activity month)

**context:** assign users to cohorts based on first activity date.  
**demonstrates:** ctes, `min()`, cohort logic, date truncation.

```sql
with first_seen as (
  select
    user_id,
    min(event_date) as first_date
  from events
  group by user_id
),
cohorts as (
  select
    user_id,
    date_trunc('month', first_date) as cohort_month
  from first_seen
)
select
  cohort_month,
  count(*) as users
from cohorts
group by cohort_month
order by cohort_month;
```

---

## Snippet 3 (Data quality checks)

```markdown
## 3) data quality validation checks

**context:** quick automated checks for missing values and duplicates.  
**demonstrates:** `union all`, reconciliation checks, null handling.

```sql
select
  'users_missing_country' as check_name,
  count(*) as issue_count
from users
where country is null

union all

select
  'duplicate_user_ids' as check_name,
  count(*) - count(distinct user_id) as issue_count
from users;
```

---

## Snippet 4 (Join + conditional aggregation)

```markdown
## 4) join + conditional aggregation

**context:** summarize engagement by content provider.  
**demonstrates:** joins, conditional aggregation, distinct counts.

```sql
select
  c.provider,
  count(distinct e.user_id) as unique_viewers,
  sum(case when e.event_name = 'play' then 1 else 0 end) as plays
from events e
join content c
  on e.content_id = c.content_id
group by c.provider
order by unique_viewers desc;
```

---

## Snippet 5 (One multi-grain union all example)
```markdown
## 5) multi-grain output via union all (daily + weekly)

**context:** return daily and weekly aggregates in one result set using a grain label.  
**demonstrates:** `union all`, multi-grain modeling, labels for safe downstream use.

```sql
select
  event_date,
  country,
  'daily' as grain,
  count(distinct user_id) as active_users
from events
group by 1,2

union all

select
  date_trunc('week', event_date) as event_date,
  country,
  'weekly' as grain,
  count(distinct user_id) as active_users
from events
group by 1,2
order by event_date, country, grain;
```
---

### full runnable sql examples
✅ **[mini sql lab](mini-sql-lab/readme.md)** (schema + mock data + queries)

**Note:** Additional SQL examples from other projects will be added as documentation progresses.

[← Back to Projects](/projects.md)



