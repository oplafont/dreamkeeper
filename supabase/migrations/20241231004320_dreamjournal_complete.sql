-- Location: supabase/migrations/20241231004320_dreamjournal_complete.sql
-- Schema Analysis: Fresh project - no existing tables
-- Integration Type: Complete new schema with authentication and dream management
-- Dependencies: None - creating complete new system

-- 1. Types and Enums
CREATE TYPE public.sleep_quality AS ENUM ('poor', 'fair', 'good', 'excellent');
CREATE TYPE public.dream_type AS ENUM ('lucid', 'nightmare', 'recurring', 'normal', 'prophetic');
CREATE TYPE public.mood_type AS ENUM ('happy', 'sad', 'anxious', 'peaceful', 'confused', 'excited', 'fearful');

-- 2. Core Tables

-- Critical intermediary table for PostgREST compatibility
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    preferred_name TEXT,
    timezone TEXT DEFAULT 'UTC',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Dream entries table
CREATE TABLE public.dreams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT,
    content TEXT NOT NULL,
    dream_date DATE NOT NULL DEFAULT CURRENT_DATE,
    sleep_quality public.sleep_quality,
    dream_type public.dream_type DEFAULT 'normal'::public.dream_type,
    mood public.mood_type,
    tags TEXT[],
    is_lucid BOOLEAN DEFAULT false,
    is_nightmare BOOLEAN DEFAULT false,
    is_recurring BOOLEAN DEFAULT false,
    clarity_score INTEGER CHECK (clarity_score >= 1 AND clarity_score <= 10),
    audio_recording_path TEXT,
    ai_analysis JSONB,
    ai_tags TEXT[],
    ai_symbols TEXT[],
    ai_emotions TEXT[],
    ai_themes TEXT[],
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Dream insights and patterns table
CREATE TABLE public.dream_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    insight_type TEXT NOT NULL,
    insight_title TEXT NOT NULL,
    insight_content TEXT NOT NULL,
    related_dreams UUID[] DEFAULT ARRAY[]::UUID[],
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
    date_generated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_favorite BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Dream images and attachments table  
CREATE TABLE public.dream_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dream_id UUID NOT NULL REFERENCES public.dreams(id) ON DELETE CASCADE,
    file_path TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size INTEGER,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Sleep tracking table
CREATE TABLE public.sleep_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    sleep_date DATE NOT NULL DEFAULT CURRENT_DATE,
    bedtime_at TIMESTAMPTZ,
    sleep_at TIMESTAMPTZ,
    wake_at TIMESTAMPTZ,
    sleep_duration_minutes INTEGER,
    sleep_quality public.sleep_quality,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_dreams_user_id ON public.dreams(user_id);
CREATE INDEX idx_dreams_dream_date ON public.dreams(dream_date);
CREATE INDEX idx_dreams_tags ON public.dreams USING GIN(tags);
CREATE INDEX idx_dreams_ai_tags ON public.dreams USING GIN(ai_tags);
CREATE INDEX idx_dreams_user_date ON public.dreams(user_id, dream_date DESC);
CREATE INDEX idx_dream_insights_user_id ON public.dream_insights(user_id);
CREATE INDEX idx_dream_insights_type ON public.dream_insights(insight_type);
CREATE INDEX idx_dream_attachments_dream_id ON public.dream_attachments(dream_id);
CREATE INDEX idx_sleep_sessions_user_id ON public.sleep_sessions(user_id);
CREATE INDEX idx_sleep_sessions_date ON public.sleep_sessions(sleep_date);

-- 4. Storage Buckets for Dream Assets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'dream-recordings',
    'dream-recordings',
    false,
    52428800, -- 50MB limit for audio recordings
    ARRAY['audio/mpeg', 'audio/wav', 'audio/m4a', 'audio/webm']
);

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'dream-images',
    'dream-images', 
    false,
    10485760, -- 10MB limit for images
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
);

-- 5. RLS Setup
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dreams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dream_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dream_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sleep_sessions ENABLE ROW LEVEL SECURITY;

-- 6. Functions (Must be created BEFORE RLS policies)

-- Function for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, preferred_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'preferred_name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$;

-- Function to update timestamps
CREATE OR REPLACE FUNCTION public.update_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;

-- Function to get dream statistics
CREATE OR REPLACE FUNCTION public.get_dream_statistics(user_uuid UUID)
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT jsonb_build_object(
  'total_dreams', COALESCE(COUNT(*), 0),
  'dreams_this_month', COALESCE(SUM(CASE WHEN dream_date >= date_trunc('month', CURRENT_DATE) THEN 1 ELSE 0 END), 0),
  'lucid_dreams', COALESCE(SUM(CASE WHEN is_lucid = true THEN 1 ELSE 0 END), 0),
  'nightmares', COALESCE(SUM(CASE WHEN is_nightmare = true THEN 1 ELSE 0 END), 0),
  'recurring_dreams', COALESCE(SUM(CASE WHEN is_recurring = true THEN 1 ELSE 0 END), 0),
  'avg_clarity', COALESCE(ROUND(AVG(clarity_score), 2), 0),
  'current_streak', (
    SELECT COUNT(*)
    FROM generate_series(CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE, '1 day'::interval) AS day_series(day)
    WHERE EXISTS (
      SELECT 1 FROM public.dreams d2 
      WHERE d2.user_id = user_uuid 
      AND d2.dream_date = day_series.day::date
    )
  )
)
FROM public.dreams d
WHERE d.user_id = user_uuid;
$$;

-- 7. RLS Policies (Pattern 1: Core User Tables)

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for dreams
CREATE POLICY "users_manage_own_dreams"
ON public.dreams
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for dream insights
CREATE POLICY "users_manage_own_dream_insights"
ON public.dream_insights
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for sleep sessions
CREATE POLICY "users_manage_own_sleep_sessions"
ON public.sleep_sessions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 7: Complex relationship for dream attachments (function queries different table)
CREATE OR REPLACE FUNCTION public.can_access_dream_attachment(attachment_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.dreams d
    JOIN public.dream_attachments da ON d.id = da.dream_id
    WHERE da.id = attachment_id 
    AND d.user_id = auth.uid()
)
$$;

CREATE POLICY "users_manage_dream_attachments_via_dream_ownership"
ON public.dream_attachments
FOR ALL
TO authenticated
USING (public.can_access_dream_attachment(id))
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.dreams d 
        WHERE d.id = dream_id 
        AND d.user_id = auth.uid()
    )
);

-- 8. Storage RLS Policies

-- Dream recordings bucket policies
CREATE POLICY "users_view_own_dream_recordings"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'dream-recordings' AND owner = auth.uid());

CREATE POLICY "users_upload_own_dream_recordings"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'dream-recordings' 
    AND owner = auth.uid()
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "users_update_own_dream_recordings"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'dream-recordings' AND owner = auth.uid())
WITH CHECK (bucket_id = 'dream-recordings' AND owner = auth.uid());

CREATE POLICY "users_delete_own_dream_recordings"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'dream-recordings' AND owner = auth.uid());

-- Dream images bucket policies
CREATE POLICY "users_view_own_dream_images"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'dream-images' AND owner = auth.uid());

CREATE POLICY "users_upload_own_dream_images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'dream-images' 
    AND owner = auth.uid()
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "users_update_own_dream_images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'dream-images' AND owner = auth.uid())
WITH CHECK (bucket_id = 'dream-images' AND owner = auth.uid());

CREATE POLICY "users_delete_own_dream_images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'dream-images' AND owner = auth.uid());

-- 9. Triggers
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_user_profiles_timestamp
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER update_dreams_timestamp
  BEFORE UPDATE ON public.dreams
  FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER update_sleep_sessions_timestamp
  BEFORE UPDATE ON public.sleep_sessions
  FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

-- 10. Mock Data for Development and Testing
DO $$
DECLARE
    dreamer_uuid UUID := gen_random_uuid();
    analyst_uuid UUID := gen_random_uuid();
    dream1_uuid UUID := gen_random_uuid();
    dream2_uuid UUID := gen_random_uuid();
    dream3_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (dreamer_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'dreamer@example.com', crypt('dreampass123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Dream Explorer", "preferred_name": "Explorer"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (analyst_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'analyst@example.com', crypt('analyzepass123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Dream Analyst", "preferred_name": "Analyst"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create sample dream entries
    INSERT INTO public.dreams (id, user_id, title, content, dream_date, sleep_quality, dream_type, mood, tags, is_lucid, clarity_score, ai_analysis, ai_tags, ai_symbols, ai_emotions, ai_themes) VALUES
        (dream1_uuid, dreamer_uuid, 'Flying Over Mountains', 
         'I found myself soaring high above snow-capped mountains. The feeling was incredible - complete freedom and weightlessness. I could control my direction just by thinking about where I wanted to go.',
         CURRENT_DATE - INTERVAL '1 day', 'good'::public.sleep_quality, 'lucid'::public.dream_type, 'excited'::public.mood_type,
         ARRAY['flying', 'mountains', 'freedom', 'control'],
         true, 8,
         '{"interpretation": "Flying dreams often represent desire for freedom and escape from limitations", "significance": "High clarity lucid dream indicates strong self-awareness", "psychological_themes": ["liberation", "control", "transcendence"]}'::jsonb,
         ARRAY['freedom', 'elevation', 'control', 'nature'],
         ARRAY['mountains', 'sky', 'wings', 'height'],
         ARRAY['excitement', 'joy', 'empowerment', 'peace'],
         ARRAY['liberation', 'spiritual_ascension', 'overcoming_obstacles']),
         
        (dream2_uuid, dreamer_uuid, 'Lost in a Maze', 
         'I was wandering through an endless maze made of tall hedges. Every path seemed to lead to a dead end. I felt anxious and frustrated, trying to find my way out.',
         CURRENT_DATE - INTERVAL '2 days', 'fair'::public.sleep_quality, 'normal'::public.dream_type, 'anxious'::public.mood_type,
         ARRAY['maze', 'lost', 'hedges', 'confusion'],
         false, 6,
         '{"interpretation": "Maze dreams often reflect feeling lost or confused in waking life", "significance": "May indicate need for clearer direction or decision-making", "psychological_themes": ["confusion", "searching", "obstacles"]}'::jsonb,
         ARRAY['confusion', 'obstacles', 'searching', 'complexity'],
         ARRAY['maze', 'walls', 'paths', 'dead_ends'],
         ARRAY['anxiety', 'frustration', 'confusion', 'determination'],
         ARRAY['life_direction', 'problem_solving', 'perseverance']),

        (dream3_uuid, analyst_uuid, 'Ocean of Memories',
         'I was diving deep into a crystal-clear ocean. As I descended, I saw scenes from my childhood floating like bubbles around me. Each bubble contained a vivid memory.',
         CURRENT_DATE - INTERVAL '1 day', 'excellent'::public.sleep_quality, 'normal'::public.dream_type, 'peaceful'::public.mood_type,
         ARRAY['ocean', 'memories', 'childhood', 'diving'],
         false, 9,
         '{"interpretation": "Water dreams often represent emotions and the unconscious mind", "significance": "Childhood memories suggest processing past experiences", "psychological_themes": ["nostalgia", "emotional_depth", "self_reflection"]}'::jsonb,
         ARRAY['memories', 'emotions', 'past', 'clarity'],
         ARRAY['ocean', 'bubbles', 'water', 'depth'],
         ARRAY['nostalgia', 'peace', 'reflection', 'curiosity'],
         ARRAY['self_discovery', 'emotional_processing', 'inner_wisdom']);

    -- Create sample dream insights
    INSERT INTO public.dream_insights (user_id, insight_type, insight_title, insight_content, related_dreams, confidence_score) VALUES
        (dreamer_uuid, 'pattern_analysis', 'Recurring Freedom Themes',
         'Your recent dreams show a strong pattern of seeking freedom and escape from constraints. Flying and movement dreams suggest a desire for more autonomy in your waking life.',
         ARRAY[dream1_uuid], 0.85),
        (dreamer_uuid, 'emotional_analysis', 'Processing Life Transitions',
         'The contrast between your flying dream (excitement) and maze dream (anxiety) suggests you are processing both the excitement and challenges of a major life transition.',
         ARRAY[dream1_uuid, dream2_uuid], 0.78);

    -- Create sample sleep sessions
    INSERT INTO public.sleep_sessions (user_id, sleep_date, bedtime_at, sleep_at, wake_at, sleep_duration_minutes, sleep_quality, notes) VALUES
        (dreamer_uuid, CURRENT_DATE - INTERVAL '1 day', 
         (CURRENT_DATE - INTERVAL '1 day' + TIME '22:30:00')::timestamptz,
         (CURRENT_DATE - INTERVAL '1 day' + TIME '23:15:00')::timestamptz,
         (CURRENT_DATE + TIME '07:00:00')::timestamptz,
         465, 'good'::public.sleep_quality, 
         'Had vivid flying dream. Felt refreshed upon waking.'),
        (dreamer_uuid, CURRENT_DATE - INTERVAL '2 days',
         (CURRENT_DATE - INTERVAL '2 days' + TIME '23:00:00')::timestamptz,
         (CURRENT_DATE - INTERVAL '2 days' + TIME '23:45:00')::timestamptz,
         (CURRENT_DATE - INTERVAL '1 day' + TIME '06:30:00')::timestamptz,
         405, 'fair'::public.sleep_quality,
         'Restless sleep. Maze dream left me feeling unsettled.');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 11. Cleanup Function for Development
CREATE OR REPLACE FUNCTION public.cleanup_dream_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user_ids_to_delete UUID[];
BEGIN
    -- Get auth user IDs first
    SELECT ARRAY_AGG(id) INTO auth_user_ids_to_delete
    FROM auth.users
    WHERE email LIKE '%@example.com';

    -- Delete in dependency order (children first, then auth.users last)
    DELETE FROM public.dream_attachments WHERE dream_id IN (
        SELECT id FROM public.dreams WHERE user_id = ANY(auth_user_ids_to_delete)
    );
    DELETE FROM public.dream_insights WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.sleep_sessions WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.dreams WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.user_profiles WHERE id = ANY(auth_user_ids_to_delete);

    -- Delete auth.users last (after all references are removed)
    DELETE FROM auth.users WHERE id = ANY(auth_user_ids_to_delete);
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;