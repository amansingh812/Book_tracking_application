-- 0001_extensions_and_helpers.sql
-- Foundations shared by every other migration.
--
-- Readora sync contract (see docs/DATA_MODEL.md):
--   * every syncable table has  id uuid pk (client-generated), created_at, updated_at, deleted_at
--   * updated_at is ALWAYS stamped server-side by a trigger, never trusted from the client
--   * deletes are soft (deleted_at); clients pull tombstones so deletes propagate offline
--   * clients PATCH only the fields they changed -> field-level last-write-wins for free

create extension if not exists "pgcrypto";   -- gen_random_uuid()
create extension if not exists "vector";     -- pgvector, for note embeddings (V2)

-- ---------------------------------------------------------------------------
-- updated_at stamping
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

comment on function public.set_updated_at is
  'BEFORE INSERT OR UPDATE trigger: stamps updated_at with server time. Client clocks are never trusted for sync cursors.';

-- Convenience: attach the trigger + the standard sync columns index to a table.
create or replace function public.readora_make_syncable(p_table regclass)
returns void
language plpgsql
as $$
declare
  t text := p_table::text;
  n text := replace(replace(t, 'public.', ''), '"', '');
begin
  execute format('drop trigger if exists trg_%s_updated_at on %s', n, t);
  execute format(
    'create trigger trg_%s_updated_at before insert or update on %s
       for each row execute function public.set_updated_at()', n, t);
  execute format(
    'create index if not exists idx_%s_sync on %s (user_id, updated_at desc)', n, t);
end;
$$;

comment on function public.readora_make_syncable is
  'Attaches the updated_at trigger and the (user_id, updated_at) pull index. Call once per per-user table.';

-- NOTE: the entitlement helper public.has_active_plus() lives in 0007_billing.sql,
-- because it reads the subscriptions table and SQL function bodies are validated
-- at creation time.
