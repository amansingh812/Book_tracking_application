// Shared HTTP helpers: CORS, JSON responses, and typed errors.

export const corsHeaders: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

export class HttpError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message?: string,
  ) {
    super(message ?? code);
  }
}

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

/**
 * Wraps a handler with CORS preflight and uniform error shaping.
 * Errors are returned as { error: { code, message } } so the Flutter side can
 * switch on `code` (e.g. AI_QUOTA_EXCEEDED) instead of parsing prose.
 */
export function handler(
  fn: (req: Request) => Promise<Response>,
): (req: Request) => Promise<Response> {
  return async (req: Request) => {
    if (req.method === 'OPTIONS') {
      return new Response('ok', { headers: corsHeaders });
    }
    try {
      return await fn(req);
    } catch (err) {
      if (err instanceof HttpError) {
        return json({ error: { code: err.code, message: err.message } }, err.status);
      }
      console.error('unhandled', err);
      return json(
        { error: { code: 'INTERNAL', message: 'Something went wrong.' } },
        500,
      );
    }
  };
}
