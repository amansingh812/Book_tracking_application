// ai-chat
//
// POST { threadId: string, userBookId?: string, message: string }
// -> text/event-stream (OpenAI SSE, proxied)
//
// The AI Companion. Context is the user's own notes and highlights for the book
// plus public metadata - never the book's text. See _shared/context.ts.

import { handler, HttpError, corsHeaders } from '../_shared/http.ts';
import { adminClient, consumeAiCredit, requireUser } from '../_shared/supabase.ts';
import { loadBookContext, renderContext, READORA_SYSTEM_PROMPT } from '../_shared/context.ts';
import { CHAT_MODEL, stream, type ChatMessage } from '../_shared/openai.ts';

const MAX_HISTORY = 12;

Deno.serve(handler(async (req) => {
  const caller = await requireUser(req);
  const body = await req.json().catch(() => ({}));

  const threadId = String(body.threadId ?? '');
  const message = String(body.message ?? '').trim();
  if (!threadId || !message) {
    throw new HttpError(400, 'BAD_REQUEST', 'threadId and message are required.');
  }
  if (message.length > 4000) {
    throw new HttpError(400, 'MESSAGE_TOO_LONG', 'Keep questions under 4000 characters.');
  }

  // RLS-scoped read: fails closed if the thread is not the caller's.
  const { data: thread } = await caller.db
    .from('ai_threads')
    .select('id, scope, user_book_id')
    .eq('id', threadId)
    .is('deleted_at', null)
    .maybeSingle();
  if (!thread) throw new HttpError(404, 'THREAD_NOT_FOUND', 'Conversation not found.');

  await consumeAiCredit(caller.userId);

  const messages: ChatMessage[] = [{ role: 'system', content: READORA_SYSTEM_PROMPT }];

  if (thread.user_book_id) {
    const ctx = await loadBookContext(caller.db, thread.user_book_id);
    messages.push({ role: 'system', content: renderContext(ctx) });
  }

  const { data: history } = await caller.db
    .from('ai_messages')
    .select('role, content')
    .eq('thread_id', threadId)
    .is('deleted_at', null)
    .order('created_at', { ascending: false })
    .limit(MAX_HISTORY);

  for (const m of (history ?? []).reverse()) {
    messages.push({ role: m.role as ChatMessage['role'], content: m.content });
  }
  messages.push({ role: 'user', content: message });

  const admin = adminClient();
  await admin.from('ai_messages').insert({
    user_id: caller.userId,
    thread_id: threadId,
    role: 'user',
    content: message,
  });

  const upstream = await stream(messages);

  // Tee the stream: the client gets tokens as they arrive, and we persist the
  // finished assistant turn so the conversation survives an app restart.
  let assembled = '';
  const decoder = new TextDecoder();

  const out = new TransformStream<Uint8Array, Uint8Array>({
    transform(chunk, controller) {
      const text = decoder.decode(chunk, { stream: true });
      for (const line of text.split('\n')) {
        if (!line.startsWith('data: ') || line.includes('[DONE]')) continue;
        try {
          const delta = JSON.parse(line.slice(6))?.choices?.[0]?.delta?.content;
          if (typeof delta === 'string') assembled += delta;
        } catch {
          // partial JSON across chunk boundaries - safe to skip, we only use
          // this copy for persistence, the client sees the raw stream.
        }
      }
      controller.enqueue(chunk);
    },
    async flush() {
      if (assembled.length === 0) return;
      await admin.from('ai_messages').insert({
        user_id: caller.userId,
        thread_id: threadId,
        role: 'assistant',
        content: assembled,
        model: CHAT_MODEL,
      });
    },
  });

  return new Response(upstream.body!.pipeThrough(out), {
    headers: {
      ...corsHeaders,
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      Connection: 'keep-alive',
    },
  });
}));
