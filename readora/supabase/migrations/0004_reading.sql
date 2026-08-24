-- 0004_reading.sql
-- Reading sessions, the day log that powers streaks, and goals.

-- ---------------------------------------------------------------------------
-- reading_sessions : APPEND-ONLY. Two devices can never conflict on a session,
-- because each device writes its own rows and nothing ever edits an old one.
-- ---------------------------------------------------------------------------
create table public.reading_sessions (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references auth.users (id) on delete cascade,
  user_book_id     uuid not null references public.user_books (id) on delete cascade,
  started_at       timestamptz not null,
  ended_at         timestamptz not null,
  duration_seconds integer not null check (duration_seconds > 0),
  start_page       integer check (start_page >= 0),
  end_page         integer check (end_page >= 0),
  pages_read       integer generated always as (
                     case when end_page is not null and start_page is not null
                          then greatest(end_page - start_page, 0)
                          else null end
                   ) stored,
  device_id        text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  deleted_at       timestamptz,
  constraint reading_sessions_time_order check (ended_at >= started_at)
);

create index idx_sessions_book on public.reading_sessions (user_id, user_book_id, started_at desc);
select public.readora_make_syncable('public.reading_sessions');

-- ---------------------------------------------------------------------------
-- reading_days : one row per day the user read anything.
-- Streaks are DERIVED from this, never stored as a counter - a stored counter
-- cannot survive offline edits, timezone changes, or backfilled sessions.
-- ---------------------------------------------------------------------------
create table public.reading_days (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  day         date not null,
  minutes     integer not null default 0 check (minutes >= 0),
  pages       integer not null default 0 check (pages >= 0),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create unique index uq_reading_days on public.reading_days (user_id, day);
select public.readora_make_syncable('public.reading_days');

-- Current + longest streak, computed with the classic "date minus row_number" grouping.
create or replace function public.reading_streak(p_user uuid default auth.uid())
returns table (current_streak integer, longest_streak integer, last_read_day date)
language sql
stable
security definer
set search_path = public
as $$
  with days as (
    select day
    from public.reading_days
    where user_id = p_user and deleted_at is null and (minutes > 0 or pages > 0)
  ),
  grouped as (
    select day, day - (row_number() over (order by day))::integer as grp
    from days
  ),
  runs as (
    select min(day) as run_start, max(day) as run_end, count(*)::integer as len
    from grouped group by grp
  )
  select
    coalesce((select len from runs
              where run_end >= (current_date - 1)
              order by run_end desc limit 1), 0) as current_streak,
    coalesce((select max(len) from runs), 0)     as longest_streak,
    (select max(run_end) from runs)              as last_read_day;
$$;

comment on function public.reading_streak is
  'Derives current and longest streak from reading_days. A streak survives "yesterday" so the user has all of today to keep it alive.';

-- ---------------------------------------------------------------------------
-- goals
-- ---------------------------------------------------------------------------
create type public.goal_period as enum ('daily', 'weekly', 'monthly', 'yearly');
create type public.goal_metric as enum ('minutes', 'pages', 'books');

create table public.goals (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  period      public.goal_period not null,
  metric      public.goal_metric not null,
  target      integer not null check (target > 0),
  active_from date not null default current_date,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create unique index uq_goals_active
  on public.goals (user_id, period, metric)
  where is_active and deleted_at is null;

select public.readora_make_syncable('public.goals');
