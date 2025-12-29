# Analyze Dream Edge Function

## Overview
Server-side dream analysis function that securely calls OpenAI API using Supabase secrets.

## Purpose
- Verify user authentication via JWT token
- Call OpenAI API server-side with secure API key
- Return structured dream analysis JSON to Flutter client
- Prevent API key exposure in client code

## Security Features
- ✅ JWT token verification for authenticated requests only
- ✅ OpenAI API key stored in Supabase secrets (not in client)
- ✅ CORS headers for Flutter web/mobile compatibility
- ✅ Error handling with appropriate status codes

## Setup Instructions

### 1. Set OpenAI API Key in Supabase Secrets
```bash
# In Supabase Dashboard → Project Settings → Edge Functions → Secrets
# Add secret:
OPENAI_API_KEY=sk-your-openai-api-key-here
```

### 2. Deploy Edge Function
```bash
supabase functions deploy analyze_dream
```

### 3. Test Edge Function
```bash
curl -i --location --request POST 'https://YOUR_PROJECT.supabase.co/functions/v1/analyze_dream' \
  --header 'Authorization: Bearer YOUR_SUPABASE_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"dreamContent":"I was flying over mountains"}'
```

## Request Format

### Headers
- `Authorization`: Bearer token with user JWT
- `Content-Type`: application/json

### Body
```json
{
  "dreamContent": "Dream description text (required)",
  "mood": "happy|sad|anxious|peaceful|etc (optional)",
  "userTags": ["tag1", "tag2"] (optional)
}
```

## Response Format

### Success (200)
```json
{
  "success": true,
  "userId": "user-uuid",
  "analysis": {
    "interpretation": "Brief interpretation...",
    "significance": "What this dream signifies...",
    "psychological_themes": ["theme1", "theme2"],
    "ai_tags": ["tag1", "tag2", "tag3"],
    "ai_symbols": ["symbol1", "symbol2"],
    "ai_emotions": ["emotion1", "emotion2"],
    "ai_themes": ["theme1", "theme2"],
    "clarity_assessment": 8,
    "lucidity_indicators": ["indicator1"],
    "recommendations": "Suggestions...",
    "summary": "Brief summary"
  },
  "timestamp": "2025-12-29T01:32:06.000Z"
}
```

### Error Responses
- `401`: Missing or invalid JWT token
- `400`: Missing or invalid dream content
- `500`: OpenAI API error or internal server error

## Integration with Flutter

The Flutter app calls this Edge Function via:
```dart
final response = await client.functions.invoke(
  'analyze_dream',
  body: {
    'dreamContent': dreamContent,
    'mood': mood,
    'userTags': userTags,
  },
);
```

## Benefits of This Approach
1. **Security**: API keys never exposed in client code
2. **Cost Control**: Server-side rate limiting possible
3. **Flexibility**: Easy to update AI models or prompts
4. **Monitoring**: Server-side logging of all AI requests
5. **Compliance**: Centralized handling of sensitive data

## Development Notes
- Uses Deno runtime for Edge Functions
- OpenAI API key must be set in Supabase secrets
- JWT verification ensures only authenticated users can access
- Fallback analysis provided if OpenAI API fails