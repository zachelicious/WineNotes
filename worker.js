export default {
  async fetch(request, env, ctx) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders() });
    }
    if (request.method !== 'POST') {
      return new Response('Method Not Allowed', { status: 405, headers: corsHeaders() });
    }
    try {
      const body = await request.json();
      const system = `You are a sommelier. Write a neutral, vivid but concise 2–3 sentence tasting note (≤60 words). Avoid clichés and hype. Use UK spelling.`;
      const user = JSON.stringify(body);

      const r = await fetch('https://api.openai.com/v1/responses', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${env.OPENAI_API_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          model: 'gpt-4.1-mini',
          input: [
            { role: 'system', content: system },
            { role: 'user', content: user }
          ],
          max_output_tokens: 120
        })
      });
      if (!r.ok) {
        const t = await r.text();
        return new Response(t, { status: 500, headers: corsHeaders() });
      }
      const data = await r.json();
      const note = data.output_text ?? (data.choices?.[0]?.message?.content ?? '').toString();
      return new Response(JSON.stringify({ note }), { status: 200, headers: { ...corsHeaders(), 'Content-Type': 'application/json' } });
    } catch (e) {
      return new Response(JSON.stringify({ error: e.message || 'error' }), { status: 500, headers: corsHeaders() });
    }
  }
}

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type'
  };
}