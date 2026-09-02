// delete-account
//
// POST (empty body, just the caller's own bearer token) -> { deleted: true }
//
// Self-service account deletion. Required by Apple (App Store Review Guideline
// 5.1.1(v)) and Google Play (Account Deletion policy) for any app that lets
// people create an account — non-negotiable before a public listing on either
// store, and worth having correct well before that.
//
// Every per-user table is declared `references auth.users (id) on delete
// cascade` (see supabase/migrations/000{3..8}_*.sql), so deleting the auth
// user is genuinely enough: library, notes, quizzes, flashcards, reading
// history, and the subscription row all go with it in one transaction. The
// one exception is `client_errors.user_id`, which is `on delete set null` by
// design — a crash report shouldn't vanish just because the reporter deleted
// their account.
//
// service_role is required here (only the admin API can delete an auth user),
// but it is used only after requireUser() has established the caller's own
// identity from their JWT — nobody can delete an account that isn't theirs.

import { handler, HttpError, json } from '../_shared/http.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

Deno.serve(handler(async (req) => {
  if (req.method !== 'POST') {
    throw new HttpError(405, 'METHOD_NOT_ALLOWED', 'Use POST.');
  }

  const caller = await requireUser(req);

  const { error } = await adminClient().auth.admin.deleteUser(caller.userId);
  if (error) {
    console.error('delete-account failed', { userId: caller.userId, message: error.message });
    throw new HttpError(500, 'DELETE_FAILED', 'Could not delete your account. Try again.');
  }

  console.log(JSON.stringify({ event: 'account_deleted', userId: caller.userId }));
  return json({ deleted: true });
}));
