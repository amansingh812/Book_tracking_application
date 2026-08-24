-- 0003_library.sql
-- Profiles, the library row (user_books), and custom shelves.

create type public.reading_status as enum (
  'want_to_read', 'reading', 'finished', 'dnf', 'paused'
);

-- ---------------------------------------------------------------------------
-- profiles : 1:1 with auth.users
-- ---------------------------------------------------------------------------
create table public.profiles (
  id            uuid primary key references auth.users (id) on delete cascade,
  user_id       uuid generated always as (id) stored,   -- lets the sync helpers treat it like any other table
  display_name  text,
  avatar_url    text,
  timezone      text not null default 'Asia/Kolkata',
  onboarded_at  timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);

create trigger trg_profiles_updated_at
  before insert or update on public.profiles
  for each row execute function public.set_updated_at();

-- Auto-create a profile row the moment a user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', split_part(new.email, '@', 1)))
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger trg_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- user_books : one row per book in a user's library. The heart of the app.
-- ---------------------------------------------------------------------------
create table public.user_books (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users (id) on delete cascade,
  book_id       uuid not null references public.books (id) on delete restrict,
  status        public.reading_status not null default 'want_to_read',
  current_page  integer not null default 0 check (current_page >= 0),
  page_count_override integer check (page_count_override is null or page_count_override > 0),
  started_at    timestamptz,
  finished_at   timestamptz,
  -- rating stored in half-star steps: 1..10 == 0.5..5.0 stars
  rating        smallint check (rating is null or rating between 1 and 10),
  review        text,
  is_favorite   boolean not null default false,
  tbr_priority  integer,
  notes_count   integer not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);

-- A user may only hold one live row per book, but may re-add after deleting.
create unique index uq_user_books_live
  on public.user_books (user_id, book_id)
  where deleted_at is null;

create index idx_user_books_status on public.user_books (user_id, status) where deleted_at is null;
create index idx_user_books_tbr on public.user_books (user_id, tbr_priority) where status = 'want_to_read' and deleted_at is null;

select public.readora_make_syncable('public.user_books');

comment on column public.user_books.rating is 'Half-star steps: 1..10 maps to 0.5..5.0 stars.';
comment on column public.user_books.page_count_override is 'Set when the edition the user owns differs from the cached metadata.';

-- ---------------------------------------------------------------------------
-- shelves
-- ---------------------------------------------------------------------------
create table public.shelves (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  name        text not null,
  emoji       text,
  color       text,
  sort_order  integer not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create unique index uq_shelves_name on public.shelves (user_id, lower(name)) where deleted_at is null;
select public.readora_make_syncable('public.shelves');

create table public.shelf_items (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users (id) on delete cascade,
  shelf_id      uuid not null references public.shelves (id) on delete cascade,
  user_book_id  uuid not null references public.user_books (id) on delete cascade,
  sort_order    integer not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);

create unique index uq_shelf_items on public.shelf_items (shelf_id, user_book_id) where deleted_at is null;
select public.readora_make_syncable('public.shelf_items');
