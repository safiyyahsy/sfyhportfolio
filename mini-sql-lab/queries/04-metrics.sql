-- 04_video_depth_metrics.sql
-- goal: simple example of aggregating watch time and deriving a normalized rate
-- dataset and logic are fully mock and for learning/demo purposes only

with video_events as (
  select
    e.event_date,
    e.country,
    e.platform,
    e.user_id,
    e.content_id,
    e.event_name,
    e.watch_sec
  from events e
  join content c
    on e.content_id = c.content_id
  where c.content_type = 'video'
    and e.event_name in ('play', 'watch', 'complete')
),

video_daily as (
  select
    event_date,
    country,
    platform,
    content_id,
    count(distinct case when event_name = 'play' then user_id end) as play_uv,
    sum(case when event_name in ('watch', 'complete') then coalesce(watch_sec, 0) else 0 end) as total_watch_sec
  from video_events
  group by 1, 2, 3, 4
),

video_meta as (
  select
    content_id,
    max(duration_sec) as duration_sec
  from content
  where content_type = 'video'
  group by 1
)

select
  vd.event_date,
  vd.country,
  vd.platform,
  vd.content_id,
  vd.play_uv,
  round(vd.total_watch_sec / 60.0, 2) as watch_mins,
  round(
    (vd.total_watch_sec * 1.0) / nullif(vm.duration_sec * vd.play_uv, 0),
    4
  ) as normalized_watch_rate
from video_daily vd
join video_meta vm
  on vd.content_id = vm.content_id
order by vd.event_date, vd.country, vd.platform, vd.content_id;
