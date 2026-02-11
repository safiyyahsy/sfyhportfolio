-- 01_segmentation.sql
-- goal: segment users into simple groups using mock profile attributes
-- note: this is toy logic for demonstration only

with base as (
  select
    u.user_id,
    u.country,
    u.platform,
    u.is_student,
    u.grad_year,
    case
      when u.is_student = 1 then 'student'
      when u.is_student = 0 and u.grad_year is not null and u.grad_year <= 2025 then 'graduate'
      else 'other'
    end as user_segment
  from users u
),
engagement as (
  select
    e.user_id,
    count(*) as total_events,
    count(distinct e.event_date) as active_days
  from events e
  group by e.user_id
)
select
  b.user_segment,
  count(distinct b.user_id) as users,
  round(avg(coalesce(en.active_days, 0)), 2) as avg_active_days
from base b
left join engagement en
  on b.user_id = en.user_id
group by b.user_segment
order by users desc;
