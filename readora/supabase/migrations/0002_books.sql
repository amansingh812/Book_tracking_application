-- 0002_books.sql
-- Shared, de-duplicated book metadata cache.
--
-- This table is NOT per-user. It is written only by the `book-search` Edge Function
-- (service role) after normalising a Google Books or Open Library result. Every user
-- who scans the same ISBN reuses the cached row, so external API quota is spent once.

create type public.book_source as enum ('google', 'openlibrary', 'manual');

create table public.books (
  id            uuid primary key default gen_random_uuid(),
  source        public.book_source not null,
  source_id     text not null,                  -- volumeId / OL work key / local uuid for manual
  isbn10        text,
  isbn13        text,
  title         text not null,
  subtitle      text,
  authors       text[] not null default '{}',
  description   text,
  publisher     text,
  published_date text,                          -- free-form: sources give '2018', '2018-10', '2018-10-16'
  page_count    integer check (page_count is null or page_count > 0),
  categories    text[] not null default '{}',
  language      text,
  cover_url     text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint books_source_unique unique (source, source_id)
);

create index idx_books_isbn13 on public.books (isbn13) where isbn13 is not null;
create index idx_books_isbn10 on public.books (isbn10) where isbn10 is not null;
create index idx_books_title_trgm on public.books using gin (to_tsvector('simple', title));
create index idx_books_updated_at on public.books (updated_at desc);

create trigger trg_books_updated_at
  before insert or update on public.books
  for each row execute function public.set_updated_at();

comment on table public.books is
  'Global book metadata cache. Read-only to clients; written by the book-search Edge Function using the service role.';
