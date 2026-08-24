// Thin OpenAI wrapper. The API key lives only here, as a Supabase secret.
//
// The provider is deliberately isolated behind these two functions so swapping
// to another vendor later touches one file, not every AI feature.

import { HttpError } from './http.ts';

const OPENAI_KEY = Deno.env.get('OPENAI_API_KEY')!;
const BASE = 'https://api.openai.com/v1';

export const CHAT_MODEL = Deno.env.get('OPENAI_CHAT_MODEL') ?? 'gpt-4o-mini';
export const EMBED_MODEL = Deno.env.get('OPENAI_EMBED_MODEL') ?? 'text-embedding-3-small';

export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

async function post(path: string, body: unknown): Promise<Response> {
  const res = await fetch(`${BASE}${path}`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${OPENAI_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const detail = await res.text();
    console.error('openai error', res.status, detail);
    throw new HttpError(502, 'AI_PROVIDER_ERROR', 'The AI service is unavailable right now.');
  }
  return res;
}

/** Non-streaming completion. Use `schema` to force structured JSON output. */
export async function complete(
  messages: ChatMessage[],
  opts: { schema?: Record<string, unknown>; schemaName?: string; temperature?: number } = {},
): Promise<{ text: string; promptTokens: number; outputTokens: number }> {
  const res = await post('/chat/completions', {
    model: CHAT_MODEL,
    messages,
    temperature: opts.temperature ?? 0.4,
    ...(opts.schema
      ? {
          response_format: {
            type: 'json_schema',
            json_schema: {
              name: opts.schemaName ?? 'result',
              strict: true,
              schema: opts.schema,
            },
          },
        }
      : {}),
  });

  const data = await res.json();
  return {
    text: data.choices?.[0]?.message?.content ?? '',
    promptTokens: data.usage?.prompt_tokens ?? 0,
    outputTokens: data.usage?.completion_tokens ?? 0,
  };
}

/** Streaming completion, proxied straight through as SSE. */
export async function stream(messages: ChatMessage[]): Promise<Response> {
  return await post('/chat/completions', {
    model: CHAT_MODEL,
    messages,
    stream: true,
    temperature: 0.5,
  });
}

export async function embed(input: string): Promise<number[]> {
  const res = await post('/embeddings', { model: EMBED_MODEL, input });
  const data = await res.json();
  return data.data[0].embedding as number[];
}
