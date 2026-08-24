-- 0008_knowledge.sql
-- The V2 moat: concepts extracted from the user's own notes, the links between
-- them, and the embeddings that power "Ask My Library".
--
-- Shipped in the schema from day one even though the UI lands in V2, so that
-- notes written during V1 are already embeddable when the feature arrives.

create table public.concepts (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  name        text not null,
  slug        text not null,
  ai_summary  text,
  book_count  integer not null default 0,
  note_count  integer not null default 0,
  embedding   vector(1536),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create unique index uq_concepts_slug on public.concepts (user_id, slug) where deleted_at is null;
select public.readora_make_syncable('public.concepts');

create type public.concept_target as enum ('note', 'user_book', 'concept');
create type public.concept_relation as enum ('supports', 'contradicts', 'extends', 'mentions');

create table public.concept_links (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users (id) on delete cascade,
  concept_id   uuid not null references public.concepts (id) on delete cascade,
  target_type  public.concept_target not null,
  target_id    uuid not null,
  relation     public.concept_relation not null default 'mentions',
  confidence   numeric(3,2) check (confidence is null or confidence between 0 and 1),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  deleted_at   timestamptz
);

create unique index uq_concept_links on public.concept_links (concept_id, target_type, target_id) where deleted_at is null;
create index idx_concept_links_target on public.concept_links (user_id, target_type, target_id);
select public.readora_make_syncable('public.concept_links');

-- ---------------------------------------------------------------------------
-- note_embeddings : never synced to the device. Server-side only, rebuilt by
-- the knowledge-extract Edge Function whenever a note changes.
-- ---------------------------------------------------------------------------
create table public.note_embeddings (
  note_id     uuid primary key references public.notes (id) on delete cascade,
  user_id     uuid not null references auth.users (id) on delete cascade,
  model       text not null default 'text-embedding-3-small',
  embedding   vector(1536) not null,
  content_hash text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index idx_note_embeddings_user on public.note_embeddings (user_id);
create index idx_note_embeddings_vec on public.note_embeddings
  using hnsw (embedding vector_cosine_ops);

create trigger trg_note_embeddings_updated_at
  before insert or update on public.note_embeddings
  for each row execute function public.set_updated_at();

-- Semantic search over the caller's own notes. Powers "Ask My Library".
create or replace function public.match_notes(
  p_user       uuid,
  p_embedding  vector(1536),
  p_limit      integer default 12,
  p_threshold  double precision default 0.25
)
returns table (
  note_id      uuid,
  user_book_id uuid,
  content      text,
  page         integer,
  similarity   double precision
)
language sql
stable
security definer
set search_path = public
as $$
  select n.id, n.user_book_id, n.content, n.page,
         1 - (e.embedding <=> p_embedding) as similarity
  from public.note_embeddings e
  join public.notes n on n.id = e.note_id
  where e.user_id = p_user
    and n.deleted_at is null
    and 1 - (e.embedding <=> p_embedding) > p_threshold
  order by e.embedding <=> p_embedding
  limit p_limit;
$$;

comment on function public.match_notes is
  'Cosine-similarity search restricted to one user''s notes. Called only from Edge Functions with an explicit p_user taken from the verified JWT.';
