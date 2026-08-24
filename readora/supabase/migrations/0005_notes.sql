-- 0005_notes.sql
-- Notes and highlights: the user's own words. This is the data that makes the
-- AI layer worth paying for, so it is treated as the most precious table in the app.
-- Nothing here is ever hard-deleted by the client.

create type public.note_kind as enum ('note', 'highlight');

create table public.notes (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users (id) on delete cascade,
  user_book_id  uuid not null references public.user_books (id) on delete cascade,
  kind          public.note_kind not null default 'note',
  content       text not null check (length(content) > 0),
  page          integer check (page is null or page >= 0),
  chapter       text,
  color         text,
  tags          text[] not null default '{}',
  is_favorite   boolean not null default false,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);

create index idx_notes_book on public.notes (user_id, user_book_id, page);
create index idx_notes_tags on public.notes using gin (tags);
create index idx_notes_fts on public.notes using gin (to_tsvector('english', content));
select public.readora_make_syncable('public.notes');

-- Keep user_books.notes_count honest without the client having to maintain it.
create or replace function public.sync_notes_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  target uuid := coalesce(new.user_book_id, old.user_book_id);
begin
  update public.user_books ub
     set notes_count = (
       select count(*) from public.notes n
       where n.user_book_id = target and n.deleted_at is null
     )
   where ub.id = target;
  return null;
end;
$$;

create trigger trg_notes_count
  after insert or update or delete on public.notes
  for each row execute function public.sync_notes_count();

-- ---------------------------------------------------------------------------
-- actions : "turn this book into practical actions"
-- ---------------------------------------------------------------------------
create table public.actions (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users (id) on delete cascade,
  user_book_id  uuid references public.user_books (id) on delete cascade,
  title         text not null,
  detail        text,
  due_week      date,
  completed_at  timestamptz,
  sort_order    integer not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);

create index idx_actions_open on public.actions (user_id, completed_at) where deleted_at is null;
select public.readora_make_syncable('public.actions');
