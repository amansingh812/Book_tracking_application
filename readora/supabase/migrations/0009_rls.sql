-- 0009_rls.sql
-- Row Level Security. Every table in `public` is locked down here.
--
-- Three tiers:
--   1. OWNED      - user reads/writes only their own rows (auth.uid() = user_id)
--   2. READ-ONLY  - user reads, never writes (books, subscriptions, ai_usage, note_embeddings)
--   3. WRITE-ONLY - user inserts, never reads back (client_errors)
--
-- Anything written by an Edge Function bypasses RLS via the service role key.
-- The service role key must NEVER be shipped in the Flutter app.

-- ---------------------------------------------------------------------------
-- Tier 1: owned tables - generated so no table is ever forgotten
-- ---------------------------------------------------------------------------
do $$
declare
  t text;
  owned text[] := array[
    'user_books', 'shelves', 'shelf_items',
    'reading_sessions', 'reading_days', 'goals',
    'notes', 'actions',
    'ai_threads', 'ai_messages',
    'quizzes', 'quiz_questions', 'quiz_attempts', 'flashcards',
    'concepts', 'concept_links'
  ];
begin
  foreach t in array owned loop
    execute format('alter table public.%I enable row level security', t);
    execute format('alter table public.%I force row level security', t);

    execute format('drop policy if exists %I on public.%I', t || '_select_own', t);
    execute format($p$create policy %I on public.%I
                      for select to authenticated
                      using (auth.uid() = user_id)$p$, t || '_select_own', t);

    execute format('drop policy if exists %I on public.%I', t || '_insert_own', t);
    execute format($p$create policy %I on public.%I
                      for insert to authenticated
                      with check (auth.uid() = user_id)$p$, t || '_insert_own', t);

    execute format('drop policy if exists %I on public.%I', t || '_update_own', t);
    execute format($p$create policy %I on public.%I
                      for update to authenticated
                      using (auth.uid() = user_id)
                      with check (auth.uid() = user_id)$p$, t || '_update_own', t);

    -- Hard delete is allowed so the client can purge locally-created rows that
    -- never synced. Normal deletion is a soft delete (an UPDATE of deleted_at).
    execute format('drop policy if exists %I on public.%I', t || '_delete_own', t);
    execute format($p$create policy %I on public.%I
                      for delete to authenticated
                      using (auth.uid() = user_id)$p$, t || '_delete_own', t);
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- profiles : keyed on id, not user_id
-- ---------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.profiles force row level security;

create policy profiles_select_own on public.profiles
  for select to authenticated using (auth.uid() = id);
create policy profiles_update_own on public.profiles
  for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);
create policy profiles_insert_own on public.profiles
  for insert to authenticated with check (auth.uid() = id);

-- ---------------------------------------------------------------------------
-- Tier 2: read-only to clients
-- ---------------------------------------------------------------------------
alter table public.books enable row level security;
create policy books_select_all on public.books
  for select to authenticated using (true);
-- no insert/update/delete policy => only the service role can write books

alter table public.subscriptions enable row level security;
alter table public.subscriptions force row level security;
create policy subscriptions_select_own on public.subscriptions
  for select to authenticated using (auth.uid() = user_id);
-- no write policy => entitlements can only come from the RevenueCat webhook

alter table public.ai_usage enable row level security;
alter table public.ai_usage force row level security;
create policy ai_usage_select_own on public.ai_usage
  for select to authenticated using (auth.uid() = user_id);
-- no write policy => the meter can only move via consume_ai_credit()

alter table public.note_embeddings enable row level security;
alter table public.note_embeddings force row level security;
create policy note_embeddings_select_own on public.note_embeddings
  for select to authenticated using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- Tier 3: write-only diagnostics
-- ---------------------------------------------------------------------------
alter table public.client_errors enable row level security;
create policy client_errors_insert_own on public.client_errors
  for insert to authenticated
  with check (user_id is null or auth.uid() = user_id);
-- deliberately no select policy: users cannot read the error stream

-- ---------------------------------------------------------------------------
-- Function execution grants
-- ---------------------------------------------------------------------------
revoke execute on function public.consume_ai_credit(uuid, integer) from public, anon, authenticated;
revoke execute on function public.match_notes(uuid, vector, integer, double precision) from public, anon, authenticated;
revoke execute on function public.readora_make_syncable(regclass) from public, anon, authenticated;

grant execute on function public.reading_streak(uuid) to authenticated;
grant execute on function public.has_active_plus(uuid) to authenticated;
