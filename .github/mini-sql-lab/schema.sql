-- Mini SQL Lab schema (mock data)
-- Domain: content platform analytics

create table users (
  user_id        integer primary key,
  country        text not null,
  platform       text not null,      -- 'ios', 'android', 'web'
  signup_date    date not null,
  is_student     integer not null,   -- 0/1 (mock profile attribute)
  grad_year      integer        -- nullable
);

create table content (
  content_id     integer primary key,
  content_type   text not null,      -- 'video', 'article', 'thread'
  provider       text not null,      -- e.g., 'partner_a', 'partner_b'
  title          text not null,
  duration_sec   integer             -- for videos only, nullable otherwise
);

create table events (
  event_id       integer primary key,
  event_ts       timestamp not null,
  event_date     date not null,
  user_id        integer not null,
  country        text not null,
  platform       text not null,
  channel        text,               -- marketing channel (mock)
  campaign       text,               -- utm campaign (mock)
  action_origin  text,               -- discovery path (mock)
  event_name     text not null,      -- 'content_view', 'play', 'complete', etc.
  content_id     integer,
  watch_sec      integer,            -- for video watch events
  foreign key (user_id) references users(user_id),
  foreign key (content_id) references content(content_id)
);
