-- 02_partner_content_views.sql
-- goal: count unique viewers of a specific provider's content by country and week

with provider_views as (
  select
    e.event_date,
    e.user_id,
    e.country,
    e.platform,
    c.provider,
    c.content_type
  from events e
  join content c
    on e.content_id = c.content_id
  where e.event_name = 'content_view'
    and c.provider = 'partner_a'
),
weekly as (
  select
    date_trunc('week', event_date) as week_start,
    country,
    platform,
    count(distinct user_id) as unique_viewers
  from provider_views
  group by 1, 2, 3
)
select *
from weekly
order by week_start, country, platform;
