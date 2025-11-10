-- Location: supabase/migrations/20241231005000_subscription_payments_system.sql
-- Schema Analysis: Existing user_profiles table with id, email, full_name, timezone columns
-- Integration Type: Addition - Adding subscription and payment tables
-- Dependencies: user_profiles (existing table)

-- 1. Subscription & Payment Types
CREATE TYPE public.subscription_status AS ENUM ('trialing', 'active', 'canceled', 'incomplete', 'incomplete_expired', 'past_due', 'unpaid');
CREATE TYPE public.payment_status AS ENUM ('pending', 'succeeded', 'failed', 'canceled', 'refunded');
CREATE TYPE public.disclaimer_type AS ENUM ('terms_of_service', 'privacy_policy', 'medical_disclaimer', 'data_usage', 'liability_waiver');

-- 2. Subscription Plans Table
CREATE TABLE public.subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    price_amount DECIMAL(10,2) NOT NULL,
    price_currency TEXT DEFAULT 'usd',
    billing_interval TEXT DEFAULT 'month',
    stripe_price_id TEXT UNIQUE,
    is_active BOOLEAN DEFAULT true,
    features JSONB DEFAULT '[]'::JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. User Subscriptions Table
CREATE TABLE public.user_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES public.subscription_plans(id) ON DELETE SET NULL,
    stripe_subscription_id TEXT UNIQUE,
    stripe_customer_id TEXT,
    status public.subscription_status DEFAULT 'incomplete',
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    cancel_at_period_end BOOLEAN DEFAULT false,
    canceled_at TIMESTAMPTZ,
    trial_start TIMESTAMPTZ,
    trial_end TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Payment Records Table
CREATE TABLE public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    subscription_id UUID REFERENCES public.user_subscriptions(id) ON DELETE SET NULL,
    stripe_payment_intent_id TEXT UNIQUE,
    stripe_payment_method_id TEXT,
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'usd',
    status public.payment_status DEFAULT 'pending',
    description TEXT,
    metadata JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMPTZ
);

-- 5. Legal Disclaimers Table
CREATE TABLE public.legal_disclaimers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type public.disclaimer_type NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    effective_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. User Disclaimer Acceptances Table
CREATE TABLE public.user_disclaimer_acceptances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    disclaimer_id UUID REFERENCES public.legal_disclaimers(id) ON DELETE CASCADE,
    accepted_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ip_address TEXT,
    user_agent TEXT,
    UNIQUE(user_id, disclaimer_id)
);

-- 7. Essential Indexes
CREATE INDEX idx_subscription_plans_active ON public.subscription_plans(is_active);
CREATE INDEX idx_subscription_plans_stripe_price ON public.subscription_plans(stripe_price_id);
CREATE INDEX idx_user_subscriptions_user_id ON public.user_subscriptions(user_id);
CREATE INDEX idx_user_subscriptions_stripe_subscription ON public.user_subscriptions(stripe_subscription_id);
CREATE INDEX idx_user_subscriptions_status ON public.user_subscriptions(status);
CREATE INDEX idx_payments_user_id ON public.payments(user_id);
CREATE INDEX idx_payments_subscription_id ON public.payments(subscription_id);
CREATE INDEX idx_payments_stripe_payment_intent ON public.payments(stripe_payment_intent_id);
CREATE INDEX idx_payments_status ON public.payments(status);
CREATE INDEX idx_legal_disclaimers_type_active ON public.legal_disclaimers(type, is_active);
CREATE INDEX idx_user_disclaimer_acceptances_user_id ON public.user_disclaimer_acceptances(user_id);

-- 8. Functions for Subscription Management
CREATE OR REPLACE FUNCTION public.get_active_subscription(user_uuid UUID)
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT id FROM public.user_subscriptions 
WHERE user_id = user_uuid 
AND status = 'active'::public.subscription_status 
AND (current_period_end IS NULL OR current_period_end > CURRENT_TIMESTAMP)
LIMIT 1
$$;

CREATE OR REPLACE FUNCTION public.has_active_subscription(user_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_subscriptions us
    WHERE us.user_id = user_uuid 
    AND us.status = 'active'::public.subscription_status 
    AND (us.current_period_end IS NULL OR us.current_period_end > CURRENT_TIMESTAMP)
)
$$;

-- 8.1. Admin role function (MOVED BEFORE RLS POLICIES)
CREATE OR REPLACE FUNCTION public.is_admin_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'admin' 
         OR au.raw_app_meta_data->>'role' = 'admin')
)
$$;

CREATE OR REPLACE FUNCTION public.update_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- 9. Enable RLS
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_disclaimers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_disclaimer_acceptances ENABLE ROW LEVEL SECURITY;

-- 10. RLS Policies
-- Pattern 4: Public read, private write for subscription plans
CREATE POLICY "public_can_read_subscription_plans"
ON public.subscription_plans
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "admin_manage_subscription_plans"
ON public.subscription_plans
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Pattern 2: Simple user ownership for user subscriptions
CREATE POLICY "users_manage_own_subscriptions"
ON public.user_subscriptions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for payments
CREATE POLICY "users_manage_own_payments"
ON public.payments
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 4: Public read for legal disclaimers
CREATE POLICY "public_can_read_legal_disclaimers"
ON public.legal_disclaimers
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "admin_manage_legal_disclaimers"
ON public.legal_disclaimers
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Pattern 2: Simple user ownership for disclaimer acceptances
CREATE POLICY "users_manage_own_disclaimer_acceptances"
ON public.user_disclaimer_acceptances
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 11. Triggers for updated_at
CREATE TRIGGER update_subscription_plans_timestamp
    BEFORE UPDATE ON public.subscription_plans
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER update_user_subscriptions_timestamp
    BEFORE UPDATE ON public.user_subscriptions
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

CREATE TRIGGER update_legal_disclaimers_timestamp
    BEFORE UPDATE ON public.legal_disclaimers
    FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

-- 12. Initial Data Setup
DO $$
DECLARE
    pro_plan_id UUID := gen_random_uuid();
    terms_disclaimer_id UUID := gen_random_uuid();
    privacy_disclaimer_id UUID := gen_random_uuid();
    medical_disclaimer_id UUID := gen_random_uuid();
    liability_disclaimer_id UUID := gen_random_uuid();
BEGIN
    -- Insert single subscription plan ($8/month)
    INSERT INTO public.subscription_plans (id, name, description, price_amount, price_currency, billing_interval, features)
    VALUES (
        pro_plan_id,
        'DreamKeeper Pro',
        'Full access to all dream analysis features, unlimited dream entries, AI insights, and advanced analytics.',
        8.00,
        'usd',
        'month',
        '["Unlimited dream entries", "AI-powered dream analysis", "Advanced pattern recognition", "Export capabilities", "Therapeutic insights", "Premium support"]'::JSONB
    );

    -- Insert legal disclaimers
    INSERT INTO public.legal_disclaimers (id, type, title, content, version, is_active) VALUES
    (terms_disclaimer_id, 'terms_of_service', 'Terms of Service', 
     'By using DreamKeeper, you agree to our terms and conditions. This service is provided as-is for personal use only. You are responsible for the accuracy of your dream entries and personal data. We reserve the right to modify these terms at any time with notice.', 
     1, true),
    
    (privacy_disclaimer_id, 'privacy_policy', 'Privacy Policy', 
     'DreamKeeper respects your privacy. We collect and store your dream entries, usage data, and personal information to provide our services. Your data is encrypted and never shared with third parties without consent. You may request data deletion at any time.', 
     1, true),
    
    (medical_disclaimer_id, 'medical_disclaimer', 'Medical Disclaimer', 
     'DreamKeeper is not a medical device or diagnostic tool. The AI insights and analysis provided are for entertainment and self-reflection purposes only. Do not use this app as a substitute for professional medical, psychological, or psychiatric advice, diagnosis, or treatment. Always consult qualified healthcare professionals for medical concerns.', 
     1, true),
    
    (liability_disclaimer_id, 'liability_waiver', 'Liability Waiver', 
     'By using DreamKeeper, you acknowledge that dream analysis and interpretation carry inherent risks of misunderstanding or misinterpretation. You use this service at your own risk. DreamKeeper and its creators are not liable for any decisions, actions, or outcomes based on app-generated insights or interpretations.', 
     1, true);

    RAISE NOTICE 'Subscription and legal system initialized successfully';
END $$;