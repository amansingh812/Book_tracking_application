-- 0006_ai.sql
-- AI companion threads, quizzes, flashcards, and the free-tier usage meter.
--
-- IMPORTANT: no table here ever stores book text the user is not authorised to
-- provide. AI context is assembled from the user's own notes, highlights, ratings
-- and public metadata only. See docs/ARCHITECTURE.md > "AI and copyright".

create type public.ai_role   as enum ('system', 'user', 'assistant');
create type public.ai_scope  as enum ('book', 'library');

create table public.ai_threads (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users (id) on delete cascade,
  scope         public.ai_scope not null default 'book',
  user_book_id  uuid references public.user_books (id) on delete cascade,
  title         text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz,
  constraint ai_threads_scope_check
    check ((scope = 'book' and user_book_id is not null)
        or (scope = 'library' and user_book_id is null))
);

select public.readora_make_syncable('public.ai_threads');

create table public.ai_messages (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users (id) on delete cascade,
  thread_id     uuid not null references public.ai_threads (id) on delete cascade,
  role          public.ai_role not null,
  content       text not null,
  model         text,
  prompt_tokens integer,
  output_tokens integer,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);

create index idx_ai_messages_thread on public.ai_messages (thread_id, created_at);
select public.readora_make_syncable('public.ai_messages');

-- ---------------------------------------------------------------------------
-- quizzes
-- ---------------------------------------------------------------------------
create table public.quizzes (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users (id) on delete cascade,
  user_book_id  uuid not null references public.user_books (id) on delete cascade,
  title         text,
  generated_from text not null default 'notes',   -- notes | highlights | chapter
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);
select public.readora_make_syncable('public.quizzes');

create table public.quiz_questions (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users (id) on delete cascade,
  quiz_id       uuid not null references public.quizzes (id) on delete cascade,
  position      integer not null,
  prompt        text not null,
  options       jsonb not null default '[]'::jsonb,
  answer_index  integer,
  explanation   text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);
create unique index uq_quiz_question_position on public.quiz_questions (quiz_id, position);
select public.readora_make_syncable('public.quiz_questions');

create table public.quiz_attempts (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users (id) on delete cascade,
  quiz_id       uuid not null references public.quizzes (id) on delete cascade,
  score         integer not null check (score between 0 and 100),
  answers       jsonb not null default '[]'::jsonb,
  taken_at      timestamptz not null default now(),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);
select public.readora_make_syncable('public.quiz_attempts');

-- ---------------------------------------------------------------------------
-- flashcards : SM-2 lite spaced repetition
-- ---------------------------------------------------------------------------
create table public.flashcards (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users (id) on delete cascade,
  user_book_id  uuid references public.user_books (id) on delete cascade,
  note_id       uuid references public.notes (id) on delete set null,
  front         text not null,
  back          text not null,
  ease          numeric(4,2) not null default 2.50 check (ease >= 1.30),
  interval_days integer not null default 0 check (interval_days >= 0),
  reps          integer not null default 0,
  lapses        integer not null default 0,
  due_at        timestamptz not null default now(),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);

create index idx_flashcards_due on public.flashcards (user_id, due_at) where deleted_at is null;
select public.readora_make_syncable('public.flashcards');

-- ---------------------------------------------------------------------------
-- ai_usage : the free-tier meter. Only the service role writes it, so a user
-- cannot hand themselves unlimited AI by PATCHing the row.
-- ---------------------------------------------------------------------------
create table public.ai_usage (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users (id) on delete cascade,
  period_month  date not null,                      -- always the 1st of the month
  interactions  integer not null default 0,
  tokens_in     bigint not null default 0,
  tokens_out    bigint not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create unique index uq_ai_usage_period on public.ai_usage (user_id, period_month);

create trigger trg_ai_usage_updated_at
  before insert or update on public.ai_usage
  for each row execute function public.set_updated_at();

-- Atomically check quota and consume one credit. Called by Edge Functions only.
-- Returns the remaining allowance, or raises when the free tier is exhausted.
create or replace function public.consume_ai_credit(
  p_user uuid,
  p_free_limit integer default 5
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_month date := date_trunc('month', now())::date;
  v_used  integer;
begin
  insert into public.ai_usage (user_id, period_month, interactions)
  values (p_user, v_month, 1)
  on conflict (user_id, period_month)
    do update set interactions = public.ai_usage.interactions + 1
  returning interactions into v_used;

  if public.has_active_plus(p_user) then
    return 2147483647;                       -- unlimited for Plus
  end if;

  if v_used > p_free_limit then
    raise exception 'AI_QUOTA_EXCEEDED' using errcode = 'P0001';
  end if;

  return p_free_limit - v_used;
end;
$$;

comment on function public.consume_ai_credit is
  'Increments the monthly AI meter and enforces the free-tier limit in one atomic statement. Service role only.';
