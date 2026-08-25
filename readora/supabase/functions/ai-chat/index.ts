import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// OpenRouter model: Dynamic free model router
// Docs: https://openrouter.ai/docs/quickstart
// Model: openrouter/free
const OPENROUTER_BASE_URL = 'https://openrouter.ai/api/v1'
const MODEL = 'openrouter/free'

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { message, bookId, previousMessages } = await req.json()

    // Ensure OpenRouter API key is set
    const openRouterKey = Deno.env.get('OPENROUTER_API_KEY')
    if (!openRouterKey) {
      throw new Error('OPENROUTER_API_KEY is not set')
    }

    const systemPrompt = bookId
      ? `You are a helpful AI reading companion. The user is reading a book (id: ${bookId}). Help them understand it, answer questions, provide summaries, or generate quizzes and flashcards based on their notes.`
      : 'You are a helpful AI reading companion. Help the user discover books, get recommendations, and improve their reading habits.'

    const messages = [
      { role: 'system', content: systemPrompt },
      ...(previousMessages || []),
      { role: 'user', content: message },
    ]

    // OpenRouter uses the same request format as OpenAI.
    const response = await fetch(`${OPENROUTER_BASE_URL}/chat/completions`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openRouterKey}`,
        'Content-Type': 'application/json',
        // Optional: shows your app on OpenRouter leaderboards
        'HTTP-Referer': 'https://readora.app',
        'X-OpenRouter-Title': 'Readora',
      },
      body: JSON.stringify({
        model: MODEL,
        messages: messages,
        stream: true,
      }),
    })

    if (!response.ok) {
      const errorText = await response.text()
      console.error('OpenRouter Error:', errorText)
      throw new Error(`OpenRouter API returned an error: ${response.status} - ${errorText}`)
    }

    // Return the SSE stream directly to the client (same format as OpenAI)
    return new Response(response.body, {
      headers: {
        ...corsHeaders,
        'Content-Type': 'text/event-stream',
      },
    })
  } catch (error) {
    console.error(error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})

