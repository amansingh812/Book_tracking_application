-- 0007_billing.sql
-- Readora Plus entitlements and lightweight client error capture.
--
-- subscriptions is the ONLY source of truth for paid access, and it is written
-- exclusively by the revenuecat-webhook Edge Function using the service role.
-- No client policy grants insert/update/delete here - that is deliberate: a user
-- must never be able to PATCH themselves into Plus.

create type public.subscription_status as enum (
  'active', 'trialing', 'in_grace_period', 'cancelled', 'expired', 'paused'
);

create table public.subscriptions (
  user_id                uuid primary key references auth.users (id) on delete cascade,
  entitlement            text not null default 'plus',
  status                 public.subscription_status not null default 'expired',
  product_id             text,
  store                  text,                       -- play_store | app_store | promotional
  period_type            text,                       -- normal | trial | intro
  purchased_at           timestamptz,
  expires_at             timestamptz,
  will_renew             boolean not null default false,
  revenuecat_customer_id text,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);

create index idx_subscriptions_expiry on public.subscriptions (expires_at);

create trigger trg_subscriptions_updated_at
  before insert or update on public.subscriptions
  for each row execute function public.set_updated_at();

create or replace function public.has_active_plus(p_user uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.subscriptions s
    where s.user_id = p_user
      and s.status in ('active', 'in_grace_period', 'trialing')
      and (s.expires_at is null or s.expires_at > now())
  );
$$;

comment on function public.has_active_plus is
  'True when the user holds a live Readora Plus entitlement. Source of truth is the RevenueCat webhook, never the client.';

-- ---------------------------------------------------------------------------
-- client_errors : we ship without Firebase/Sentry, so the app keeps a local
-- ring buffer and flushes it here on next launch. Insert-only from the client.
-- ---------------------------------------------------------------------------
create table public.client_errors (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users (id) on delete set null,
  occurred_at timestamptz not null,
  flavor      text,
  app_version text,
  platform    text,
  os_version  text,
  message     text not null,
  stack       text,
  context     jsonb not null default '{}'::jsonb,
  created_at  timestamptz not null default now()
);

create index idx_client_errors_time on public.client_errors (occurred_at desc);

comment on table public.client_errors is
  'Crash/error sink flushed from the on-device ring buffer. Replace with Sentry before public launch (see docs/ROADMAP.md).';
