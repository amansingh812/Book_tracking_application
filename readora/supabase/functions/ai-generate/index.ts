// ai-generate
//
// POST { task: 'quiz' | 'flashcards' | 'actions' | 'key_ideas', userBookId: string, count?: number }
// -> { quiz?, flashcards?, actions?, keyIdeas? }
//
// One function for every structured (non-chat) AI output, because they share the
// same context assembly, quota check, and JSON-schema plumbing. Adding a new
// structured feature means adding a schema + prompt here, not a new function.

import { handler, HttpError, json } from '../_shared/http.ts';
import { consumeAiCredit, requireUser } from '../_shared/supabase.ts';
import { loadBookContext, renderContext, READORA_SYSTEM_PROMPT } from '../_shared/context.ts';
import { complete } from '../_shared/openai.ts';

type Task = 'quiz' | 'flashcards' | 'actions' | 'key_ideas';

const SCHEMAS: Record<Task, Record<string, unknown>> = {
  quiz: {
    type: 'object',
    additionalProperties: false,
    required: ['title', 'questions'],
    properties: {
      title: { type: 'string' },
      questions: {
        type: 'array',
        items: {
          type: 'object',
          additionalProperties: false,
          required: ['prompt', 'options', 'answerIndex', 'explanation'],
          properties: {
            prompt: { type: 'string' },
            options: { type: 'array', items: { type: 'string' } },
            answerIndex: { type: 'integer' },
            explanation: { type: 'string' },
          },
        },
      },
    },
  },
  flashcards: {
    type: 'object',
    additionalProperties: false,
    required: ['cards'],
    properties: {
      cards: {
        type: 'array',
        items: {
          type: 'object',
          additionalProperties: false,
          required: ['front', 'back'],
          properties: { front: { type: 'string' }, back: { type: 'string' } },
        },
      },
    },
  },
  actions: {
    type: 'object',
    additionalProperties: false,
    required: ['actions'],
    properties: {
      actions: {
        type: 'array',
        items: {
          type: 'object',
          additionalProperties: false,
          required: ['title', 'detail'],
          properties: { title: { type: 'string' }, detail: { type: 'string' } },
        },
      },
    },
  },
  key_ideas: {
    type: 'object',
    additionalProperties: false,
    required: ['ideas'],
    properties: {
      ideas: {
        type: 'array',
        items: {
          type: 'object',
          additionalProperties: false,
          required: ['idea', 'why'],
          properties: { idea: { type: 'string' }, why: { type: 'string' } },
        },
      },
    },
  },
};

const PROMPTS: Record<Task, (n: number) => string> = {
  quiz: (n) =>
    `Write ${n} multiple-choice questions that test whether the reader truly understood the ideas in their own notes above. Four options each, exactly one correct. Test comprehension and application, not trivia or wording recall. The explanation should teach, in one or two sentences.`,
  flashcards: (n) =>
    `Turn the reader's notes above into ${n} spaced-repetition flashcards. Front is a question or cue; back is a tight answer in the reader's own framing. One idea per card. Skip anything too vague to test.`,
  actions: (n) =>
    `Turn the ideas in the reader's notes into ${n} concrete actions they could start this week. Each must be small enough to do in under 20 minutes a day and observable enough that they will know if they did it. No vague advice like "be more mindful".`,
  key_ideas: (n) =>
    `Distil the reader's notes into the ${n} ideas that matter most. For each, say why it matters to this particular reader, based on what they chose to highlight.`,
};

const DEFAULT_COUNT: Record<Task, number> = {
  quiz: 8,
  flashcards: 10,
  actions: 3,
  key_ideas: 5,
};

Deno.serve(handler(async (req) => {
  const caller = await requireUser(req);
  const body = await req.json().catch(() => ({}));

  const task = String(body.task ?? '') as Task;
  const userBookId = String(body.userBookId ?? '');
  if (!SCHEMAS[task]) throw new HttpError(400, 'BAD_REQUEST', `Unknown task "${task}".`);
  if (!userBookId) throw new HttpError(400, 'BAD_REQUEST', 'userBookId is required.');

  const ctx = await loadBookContext(caller.db, userBookId);
  if (ctx.notes.length === 0) {
    throw new HttpError(
      422,
      'NO_NOTES',
      'Save a few notes or highlights from this book first — Readora builds this from your own words.',
    );
  }

  await consumeAiCredit(caller.userId);

  const count = Math.min(Math.max(Number(body.count ?? DEFAULT_COUNT[task]), 1), 20);
  const { text, promptTokens, outputTokens } = await complete(
    [
      { role: 'system', content: READORA_SYSTEM_PROMPT },
      { role: 'system', content: renderContext(ctx) },
      { role: 'user', content: PROMPTS[task](count) },
    ],
    { schema: SCHEMAS[task], schemaName: task, temperature: 0.6 },
  );

  // Token accounting: logged now, rolled into ai_usage.tokens_in/out once we
  // have enough real traffic to care about per-user cost. Keeping it out of the
  // request path avoids a second round trip on every generation.
  console.log(JSON.stringify({ event: 'ai_generate', task, promptTokens, outputTokens }));

  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch {
    throw new HttpError(502, 'AI_BAD_OUTPUT', 'The AI returned something unreadable. Try again.');
  }

  return json({ task, result: parsed });
}));
