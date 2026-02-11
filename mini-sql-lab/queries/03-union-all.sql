-- 03_multigrain_union_all.sql
-- goal: demonstrate combining multiple aggregation levels with union all + a grain label
-- dataset and logic are fully mock and for learning/demo purposes only

with base as (
  select
    e.event_date,
    e.country,
    e.platform,
    e.channel,
    e.campaign,
    e.action_origin,
    e.user_id,
    e.content_id
  from events e
  where e.event_name in ('content_view', 'play')
),

overall_daily as (
  select
    event_date,
    country,
    platform,
    null as channel,
    null as campaign,
    null as action_origin,
    null as content_id,
    count(distinct user_id) as active_users,
    'overall_daily' as grain
  from base
  group by 1, 2, 3
),

channel_daily as (
  select
    event_date,
    country,
    platform,
    channel,
    campaign,
    null as action_origin,
    null as content_id,
    count(distinct user_id) as active_users,
    'channel_daily' as grain
  from base
  where channel is not null
  group by 1, 2, 3, 4, 5
),

origin_daily as (
  select
    event_date,
    country,
    platform,
    null as channel,
    null as campaign,
    action_origin,
    null as content_id,
    count(distinct user_id) as active_users,
    'origin_daily' as grain
  from base
  where action_origin is not null
  group by 1, 2, 3, 6
),

content_daily as (
  select
    event_date,
    country,
    platform,
    null as channel,
    null as campaign,
    null as action_origin,
    content_id,
    count(distinct user_id) as active_users,
    'content_daily' as grain
  from base
  where content_id is not null
  group by 1, 2, 3, 7
)

select * from overall_daily
union all
select * from channel_daily
union all
select * from origin_daily
union all
select * from content_daily
order by event_date, country, platform, grain;
