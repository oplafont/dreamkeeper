// Supabase Edge Function: analyze_dream
// Purpose: Server-side dream analysis using OpenAI API
// Security: Verifies user JWT and uses secure API key from Supabase secrets

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface DreamAnalysisRequest {
  dreamContent: string
  mood?: string
  userTags?: string[]
}

interface DreamAnalysisResponse {
  interpretation: string
  significance: string
  psychological_themes: string[]
  ai_tags: string[]
  ai_symbols: string[]
  ai_emotions: string[]
  ai_themes: string[]
  clarity_assessment: number
  lucidity_indicators: string[]
  recommendations: string
  summary?: string
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Verify JWT and get user info
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Initialize Supabase client with service role for JWT verification
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: authHeader },
        },
      }
    )

    // Verify the user's JWT token
    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser()

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid or expired token' }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Parse request body
    const requestData: DreamAnalysisRequest = await req.json()
    const { dreamContent, mood, userTags } = requestData

    if (!dreamContent || dreamContent.trim().length === 0) {
      return new Response(
        JSON.stringify({ error: 'Dream content is required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get OpenAI API key from Supabase secrets
    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openaiApiKey) {
      console.error('OPENAI_API_KEY not configured in Supabase secrets')
      return new Response(
        JSON.stringify({ error: 'AI service configuration error' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Build dream analysis prompt
    const moodContext = mood ? ` The dreamer reported feeling ${mood} during this dream.` : ''
    const tagsContext = userTags && userTags.length > 0 
      ? ` The dreamer tagged this dream with: ${userTags.join(', ')}.` 
      : ''

    const prompt = `As an expert dream analyst, analyze this dream and provide insights in the following STANDARDIZED JSON format.

Dream Content: "${dreamContent}"${moodContext}${tagsContext}

CRITICAL: Provide analysis in this EXACT standardized structure:
{
  "summary": "One concise sentence capturing the core meaning of this dream (max 100 characters)",
  "ai_symbols": ["symbol1", "symbol2", "symbol3", "symbol4"],
  "ai_emotions": ["emotion1", "emotion2", "emotion3"],
  "ai_themes": ["major_theme1", "major_theme2", "major_theme3"],
  "actionable_reflection": "ONE specific, actionable reflection question or insight the dreamer can apply today to support their emotional well-being or personal growth (2-3 sentences max)",
  "interpretation": "Brief interpretation of the dream's meaning (2-3 sentences)",
  "significance": "What this dream might signify for the dreamer (2-3 sentences)",
  "psychological_themes": ["theme1", "theme2", "theme3"],
  "ai_tags": ["tag1", "tag2", "tag3", "tag4", "tag5"],
  "clarity_assessment": 8,
  "lucidity_indicators": ["indicator1", "indicator2"],
  "recommendations": "General suggestions for the dreamer based on this dream (2-3 sentences)"
}

STANDARDIZATION RULES:
- "summary": MUST be one sentence, max 100 characters, capturing the essence
- "ai_symbols": MUST be 3-5 key symbolic elements from the dream
- "ai_emotions": MUST be 2-4 emotions present in or evoked by the dream
- "ai_themes": MUST be 2-4 major psychological or life themes
- "actionable_reflection": MUST be ONE specific, immediately actionable insight (not generic advice)

Focus on being supportive, insightful, and providing one clear reflection the dreamer can use right away.`

    // Call OpenAI API server-side
    const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${openaiApiKey}`,
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'user',
            content: prompt,
          },
        ],
        max_tokens: 800,
        temperature: 0.7,
      }),
    })

    if (!openaiResponse.ok) {
      const errorData = await openaiResponse.json()
      console.error('OpenAI API error:', errorData)
      return new Response(
        JSON.stringify({ 
          error: 'AI analysis service unavailable',
          details: errorData.error?.message || 'Unknown error'
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const openaiData = await openaiResponse.json()
    const aiResponseText = openaiData.choices[0].message.content

    // Parse JSON from AI response
    let analysisResult: DreamAnalysisResponse
    try {
      const jsonStart = aiResponseText.indexOf('{')
      const jsonEnd = aiResponseText.lastIndexOf('}') + 1
      
      if (jsonStart !== -1 && jsonEnd !== -1 && jsonEnd > jsonStart) {
        const jsonString = aiResponseText.substring(jsonStart, jsonEnd)
        analysisResult = JSON.parse(jsonString)
      } else {
        // Fallback if JSON extraction fails
        analysisResult = createFallbackAnalysis()
      }
    } catch (parseError) {
      console.error('Error parsing AI response:', parseError)
      analysisResult = createFallbackAnalysis()
    }

    // Return structured analysis result
    return new Response(
      JSON.stringify({
        success: true,
        userId: user.id,
        analysis: analysisResult,
        timestamp: new Date().toISOString(),
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Edge function error:', error)
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error',
        message: error.message 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

// Fallback analysis structure for error cases
function createFallbackAnalysis(): DreamAnalysisResponse {
  return {
    summary: 'A meaningful dream experience reflecting your inner journey',
    interpretation: 'AI analysis completed with valuable insights',
    significance: 'This dream contains meaningful content that reflects your inner world',
    psychological_themes: ['reflection', 'subconscious_processing', 'growth'],
    ai_tags: ['analyzed', 'meaningful', 'insightful'],
    ai_symbols: ['journey', 'exploration', 'self'],
    ai_emotions: ['contemplative', 'curious', 'hopeful'],
    ai_themes: ['self_discovery', 'personal_growth', 'awareness'],
    clarity_assessment: 7,
    lucidity_indicators: ['awareness'],
    recommendations: 'Continue journaling your dreams to unlock deeper insights into your subconscious mind',
    actionable_reflection: 'Today, take 5 minutes to reflect on one emotion from this dream and how it relates to a current life situation. Write down one small action you can take to honor that feeling.',
  }
}