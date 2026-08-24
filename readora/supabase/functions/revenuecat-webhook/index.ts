// revenuecat-webhook
//
// POST (from RevenueCat) -> writes public.subscriptions with the service role.
//
// This is the ONLY writer of entitlements. The app never tells the server that a
// user is Plus; it asks. Deploy with --no-verify-jwt (RevenueCat cannot present a
// Supabase JWT) and rely on the shared-secret Authorization header instead.
//
//   supabase functions deploy revenuecat-webhook --no-verify-jwt
//   supabase secrets set REVENUECAT_WEBHOOK_SECRET=...

import { handler, HttpError, json } from '../_shared/http.ts';
import { adminClient } from '../_shared/supabase.ts';

const WEBHOOK_SECRET = Deno.env.get('REVENUECAT_WEBHOOK_SECRET') ?? '';

// RevenueCat event type -> our subscription_status
const STATUS_BY_EVENT: Record<string, string> = {
  INITIAL_PURCHASE: 'active',
  RENEWAL: 'active',
  UNCANCELLATION: 'active',
  NON_RENEWING_PURCHASE: 'active',
  PRODUCT_CHANGE: 'active',
  SUBSCRIPTION_EXTENDED: 'active',
  CANCELLATION: 'cancelled',
  EXPIRATION: 'expired',
  BILLING_ISSUE: 'in_grace_period',
  SUBSCRIPTION_PAUSED: 'paused',
};

/** Constant-time comparison so the secret cannot be probed by timing. */
function safeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

Deno.serve(handler(async (req) => {
  const provided = (req.headers.get('Authorization') ?? '').replace(/^Bearer\s+/i, '');
  if (!WEBHOOK_SECRET || !safeEqual(provided, WEBHOOK_SECRET)) {
    throw new HttpError(401, 'UNAUTHORISED', 'Bad webhook secret.');
  }

  const payload = await req.json().catch(() => ({}));
  const event = payload.event ?? {};
  const type = String(event.type ?? '');

  // app_user_id must be set to the Supabase auth uid at login:
  //   Purchases.logIn(supabase.auth.currentUser!.id)
  const userId = String(event.app_user_id ?? '');
  if (!userId) throw new HttpError(400, 'BAD_REQUEST', 'Missing app_user_id.');

  const status = STATUS_BY_EVENT[type];
  if (!status) {
    // TRANSFER, TEST, and anything new: acknowledge so RevenueCat stops retrying.
    console.log('ignoring revenuecat event', type);
    return json({ ok: true, ignored: type });
  }

  const expiresMs = event.expiration_at_ms ?? null;
  const purchasedMs = event.purchased_at_ms ?? null;

  const { error } = await adminClient().from('subscriptions').upsert(
    {
      user_id: userId,
      entitlement: (event.entitlement_ids ?? ['plus'])[0] ?? 'plus',
      status,
      product_id: event.product_id ?? null,
      store: (event.store ?? '').toLowerCase() || null,
      period_type: (event.period_type ?? '').toLowerCase() || null,
      purchased_at: purchasedMs ? new Date(purchasedMs).toISOString() : null,
      expires_at: expiresMs ? new Date(expiresMs).toISOString() : null,
      will_renew: type !== 'CANCELLATION' && type !== 'EXPIRATION',
      revenuecat_customer_id: event.original_app_user_id ?? null,
    },
    { onConflict: 'user_id' },
  );

  if (error) throw new HttpError(500, 'ENTITLEMENT_WRITE_FAILED', error.message);

  return json({ ok: true, status });
}));
