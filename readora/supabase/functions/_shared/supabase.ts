// Supabase clients + JWT verification for Edge Functions.
//
// Rule: the service-role client is only ever used AFTER the caller's identity has
// been established from their JWT. Never accept a user id from the request body.

import { createClient, type SupabaseClient } from 'npm:@supabase/supabase-js@2';
import { HttpError } from './http.ts';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

/** Bypasses RLS. Only for writes the user is not allowed to make themselves. */
export function adminClient(): SupabaseClient {
  return createClient(SUPABASE_URL, SERVICE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

export interface Caller {
  userId: string;
  email: string | null;
  /** Client scoped to the caller - every query still passes through RLS. */
  db: SupabaseClient;
}

/** Verifies the Authorization bearer token and returns the caller. */
export async function requireUser(req: Request): Promise<Caller> {
  const authHeader = req.headers.get('Authorization') ?? '';
  if (!authHeader.startsWith('Bearer ')) {
    throw new HttpError(401, 'UNAUTHENTICATED', 'Missing bearer token.');
  }

  const db = createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data, error } = await db.auth.getUser();
  if (error || !data.user) {
    throw new HttpError(401, 'UNAUTHENTICATED', 'Invalid or expired session.');
  }

  return { userId: data.user.id, email: data.user.email ?? null, db };
}

/**
 * Increments the monthly AI meter and enforces the free-tier limit.
 * Throws HttpError(402, 'AI_QUOTA_EXCEEDED') when a free user is out of credits,
 * which the app turns into the paywall.
 */
export async function consumeAiCredit(userId: string): Promise<number> {
  const freeLimit = Number(Deno.env.get('AI_FREE_MONTHLY_LIMIT') ?? '5');
  const { data, error } = await adminClient().rpc('consume_ai_credit', {
    p_user: userId,
    p_free_limit: freeLimit,
  });

  if (error) {
    if (error.message.includes('AI_QUOTA_EXCEEDED')) {
      throw new HttpError(
        402,
        'AI_QUOTA_EXCEEDED',
        `You have used all ${freeLimit} free AI interactions this month.`,
      );
    }
    throw new HttpError(500, 'QUOTA_CHECK_FAILED', error.message);
  }
  return data as number;
}
