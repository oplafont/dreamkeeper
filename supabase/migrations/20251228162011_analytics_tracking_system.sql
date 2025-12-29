-- Location: supabase/migrations/20251228162011_analytics_tracking_system.sql
-- Schema Analysis: Existing tables include dreams, user_profiles, sleep_sessions
-- Integration Type: New analytics module addition
-- Dependencies: user_profiles (existing), dreams (existing)

-- ============================================================================
-- 1. CUSTOM TYPES
-- ============================================================================

CREATE TYPE public.analytics_event_type AS ENUM (
    'dream_created',
    'dream_viewed',
    'dream_edited',
    'dream_deleted',
    'feed_view',
    'feed_dream_viewed',
    'feed_symbol_filtered',
    'search_performed',
    'insight_generated',
    'calendar_viewed',
    'export_created',
    'settings_updated',
    'notification_interacted',
    'subscription_viewed',
    'sleep_session_logged',
    'app_opened',
    'screen_viewed'
);

CREATE TYPE public.analytics_metric_type AS ENUM (
    'daily_active_users',
    'dream_submissions',
    'feed_engagement',
    'feature_usage',
    'retention_rate',
    'avg_session_duration'
);

-- ============================================================================
-- 2. CORE TABLES
-- ============================================================================

-- Analytics events table - tracks all user interactions
CREATE TABLE public.analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    event_type public.analytics_event_type NOT NULL,
    event_data JSONB DEFAULT '{}'::jsonb,
    screen_name TEXT,
    session_id UUID,
    device_info JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Aggregate analytics table - pre-computed metrics
CREATE TABLE public.analytics_aggregates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_type public.analytics_metric_type NOT NULL,
    metric_date DATE NOT NULL,
    metric_value NUMERIC NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- User engagement summary table
CREATE TABLE public.user_engagement_summary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    total_dreams INTEGER DEFAULT 0,
    total_feed_views INTEGER DEFAULT 0,
    total_insights INTEGER DEFAULT 0,
    last_active_at TIMESTAMPTZ,
    streak_days INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- ============================================================================
-- 3. INDEXES
-- ============================================================================

CREATE INDEX idx_analytics_events_user_id ON public.analytics_events(user_id);
CREATE INDEX idx_analytics_events_event_type ON public.analytics_events(event_type);
CREATE INDEX idx_analytics_events_created_at ON public.analytics_events(created_at DESC);
CREATE INDEX idx_analytics_events_session_id ON public.analytics_events(session_id);

CREATE INDEX idx_analytics_aggregates_metric_type ON public.analytics_aggregates(metric_type);
CREATE INDEX idx_analytics_aggregates_metric_date ON public.analytics_aggregates(metric_date DESC);

CREATE INDEX idx_user_engagement_user_id ON public.user_engagement_summary(user_id);
CREATE INDEX idx_user_engagement_last_active ON public.user_engagement_summary(last_active_at DESC);

-- ============================================================================
-- 4. FUNCTIONS
-- ============================================================================

-- Function to update engagement summary
CREATE OR REPLACE FUNCTION public.update_user_engagement_summary()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    INSERT INTO public.user_engagement_summary (user_id, last_active_at)
    VALUES (NEW.user_id, NEW.created_at)
    ON CONFLICT (user_id) DO UPDATE SET
        last_active_at = EXCLUDED.last_active_at,
        updated_at = CURRENT_TIMESTAMP;
    
    RETURN NEW;
END;
$func$;

-- Function to get user analytics overview
CREATE OR REPLACE FUNCTION public.get_user_analytics_overview(target_user_id UUID)
RETURNS TABLE(
    total_events BIGINT,
    dream_count BIGINT,
    feed_views BIGINT,
    last_active TIMESTAMPTZ,
    current_streak INTEGER
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
    SELECT 
        COUNT(*) as total_events,
        COUNT(*) FILTER (WHERE ae.event_type IN ('dream_created'::public.analytics_event_type)) as dream_count,
        COUNT(*) FILTER (WHERE ae.event_type IN ('feed_view'::public.analytics_event_type, 'feed_dream_viewed'::public.analytics_event_type)) as feed_views,
        MAX(ae.created_at) as last_active,
        COALESCE(ues.streak_days, 0) as current_streak
    FROM public.analytics_events ae
    LEFT JOIN public.user_engagement_summary ues ON ues.user_id = ae.user_id
    WHERE ae.user_id = target_user_id
    GROUP BY ues.streak_days;
$func$;

-- Function to get daily active users
CREATE OR REPLACE FUNCTION public.get_daily_active_users(target_date DATE)
RETURNS BIGINT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
    SELECT COUNT(DISTINCT user_id)
    FROM public.analytics_events
    WHERE DATE(created_at) = target_date;
$func$;

-- Function to track event
CREATE OR REPLACE FUNCTION public.track_analytics_event(
    p_user_id UUID,
    p_event_type TEXT,
    p_event_data JSONB DEFAULT '{}'::jsonb,
    p_screen_name TEXT DEFAULT NULL,
    p_session_id UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    new_event_id UUID;
BEGIN
    INSERT INTO public.analytics_events (
        user_id,
        event_type,
        event_data,
        screen_name,
        session_id
    ) VALUES (
        p_user_id,
        p_event_type::public.analytics_event_type,
        p_event_data,
        p_screen_name,
        p_session_id
    ) RETURNING id INTO new_event_id;
    
    RETURN new_event_id;
END;
$func$;

-- ============================================================================
-- 5. TRIGGERS
-- ============================================================================

CREATE TRIGGER update_engagement_summary_trigger
    AFTER INSERT ON public.analytics_events
    FOR EACH ROW
    EXECUTE FUNCTION public.update_user_engagement_summary();

-- ============================================================================
-- 6. ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics_aggregates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_engagement_summary ENABLE ROW LEVEL SECURITY;

-- Pattern 2: Simple user ownership for analytics events
CREATE POLICY "users_manage_own_analytics_events"
ON public.analytics_events
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 4: Public read for aggregates, private write
CREATE POLICY "public_can_read_analytics_aggregates"
ON public.analytics_aggregates
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "admin_can_manage_analytics_aggregates"
ON public.analytics_aggregates
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin')
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.id = auth.uid() 
        AND (au.raw_user_meta_data->>'role' = 'admin')
    )
);

-- Pattern 2: Simple user ownership for engagement summary
CREATE POLICY "users_view_own_engagement_summary"
ON public.user_engagement_summary
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- ============================================================================
-- 7. MOCK DATA
-- ============================================================================

DO $$
DECLARE
    existing_user_id UUID;
    session_uuid UUID := gen_random_uuid();
BEGIN
    -- Get existing user from user_profiles
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    IF existing_user_id IS NOT NULL THEN
        -- Create sample analytics events
        -- Note: The trigger will automatically create/update user_engagement_summary
        INSERT INTO public.analytics_events (user_id, event_type, screen_name, session_id, event_data) VALUES
            (existing_user_id, 'app_opened'::public.analytics_event_type, 'main_navigation', session_uuid, '{"timestamp": "2025-12-28T08:00:00Z"}'::jsonb),
            (existing_user_id, 'dream_created'::public.analytics_event_type, 'dream_entry_creation', session_uuid, '{"dream_type": "lucid", "word_count": 250}'::jsonb),
            (existing_user_id, 'feed_view'::public.analytics_event_type, 'public_dreams_feed', session_uuid, '{"scroll_depth": 75}'::jsonb),
            (existing_user_id, 'feed_symbol_filtered'::public.analytics_event_type, 'public_dreams_feed', session_uuid, '{"symbol": "flying", "results_count": 12}'::jsonb),
            (existing_user_id, 'insight_generated'::public.analytics_event_type, 'dream_insights_dashboard', session_uuid, '{"insight_type": "pattern", "confidence": 0.85}'::jsonb),
            (existing_user_id, 'calendar_viewed'::public.analytics_event_type, 'calendar_view', session_uuid, '{"view_type": "month"}'::jsonb);
        
        -- Create sample aggregate metrics
        INSERT INTO public.analytics_aggregates (metric_type, metric_date, metric_value, metadata) VALUES
            ('daily_active_users'::public.analytics_metric_type, CURRENT_DATE, 142, '{"platform": "mobile"}'::jsonb),
            ('dream_submissions'::public.analytics_metric_type, CURRENT_DATE, 87, '{"avg_length": 245}'::jsonb),
            ('feed_engagement'::public.analytics_metric_type, CURRENT_DATE, 356, '{"avg_time": 180}'::jsonb),
            ('feature_usage'::public.analytics_metric_type, CURRENT_DATE, 89, '{"feature": "insights_dashboard"}'::jsonb);
        
        -- Manual engagement summary insert removed - trigger handles this automatically
        RAISE NOTICE 'Analytics mock data created successfully';
    ELSE
        RAISE NOTICE 'No existing users found. Create users first before adding analytics data.';
    END IF;
END $$;

-- ============================================================================
-- 8. CLEANUP FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION public.cleanup_analytics_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    DELETE FROM public.analytics_events 
    WHERE created_at < (CURRENT_TIMESTAMP - INTERVAL '90 days');
    
    DELETE FROM public.analytics_aggregates 
    WHERE metric_date < (CURRENT_DATE - INTERVAL '365 days');
    
    RAISE NOTICE 'Analytics test data cleaned successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Analytics cleanup failed: %', SQLERRM;
END;
$func$;