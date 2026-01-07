# Transcribe Audio Edge Function

Securely transcribes audio files from Supabase Storage using OpenAI's Whisper API.

## Features

- **JWT Authentication**: Requires valid user JWT token for security
- **Storage Integration**: Downloads audio from authenticated user's storage context
- **OpenAI Transcription**: Uses latest `gpt-4o-mini-transcribe` model
- **Server-side Security**: API key stored in Supabase secrets, never exposed to client

## Setup

1. **Configure OpenAI API Key in Supabase Secrets**:
   ```bash
   supabase secrets set OPENAI_API_KEY=your-openai-api-key-here
   ```

2. **Deploy the function**:
   ```bash
   supabase functions deploy transcribe_audio
   ```

## Usage

Call from Flutter app after uploading audio to Storage:

```dart
final response = await supabase.functions.invoke(
  'transcribe_audio',
  body: {
    'bucket': 'dream-recordings',
    'path': 'user-id/audio-file.m4a',
    'language': 'en', // Optional
  },
);

final transcription = response.data['text'];
```

## Request Parameters

- `bucket` (required): Storage bucket name (e.g., 'dream-recordings')
- `path` (required): File path in storage (e.g., 'user-id/audio.m4a')
- `language` (optional): ISO language code for transcription (e.g., 'en', 'es')

## Response

```json
{
  "text": "Transcribed audio content here...",
  "language": "en"
}
```

## Error Handling

Returns 500 status with error message if:
- Authorization header missing or invalid JWT
- Audio file not found in storage
- OpenAI API key not configured
- Transcription API error

## Security

- User JWT validated before any operations
- Audio files downloaded using authenticated user context (RLS applies)
- OpenAI API key stored server-side in Supabase secrets
- No API keys or sensitive data exposed to client