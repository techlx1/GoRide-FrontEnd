-- Location: supabase/migrations/20250104080019_rideguyana_with_auth.sql
-- Schema Analysis: Fresh project with no existing schema
-- Integration Type: Complete ride-sharing system with auth
-- Dependencies: New database schema for ride-sharing app

-- 1. Types and Enums
CREATE TYPE public.user_role AS ENUM ('rider', 'driver', 'admin');
CREATE TYPE public.ride_status AS ENUM ('requested', 'accepted', 'in_progress', 'completed', 'cancelled');
CREATE TYPE public.vehicle_type AS ENUM ('economy', 'comfort', 'premium', 'suv');
CREATE TYPE public.payment_method AS ENUM ('cash', 'card', 'mobile_money');

-- 2. Core Tables

-- Critical intermediary table for PostgREST compatibility
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone_number TEXT UNIQUE,
    role public.user_role DEFAULT 'rider'::public.user_role,
    profile_picture_url TEXT,
    date_of_birth DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Driver specific information
CREATE TABLE public.driver_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    license_number TEXT NOT NULL UNIQUE,
    license_expiry DATE NOT NULL,
    vehicle_registration TEXT NOT NULL,
    vehicle_model TEXT NOT NULL,
    vehicle_color TEXT NOT NULL,
    vehicle_type public.vehicle_type DEFAULT 'economy'::public.vehicle_type,
    is_verified BOOLEAN DEFAULT false,
    is_online BOOLEAN DEFAULT false,
    current_latitude DOUBLE PRECISION,
    current_longitude DOUBLE PRECISION,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_rides INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Ride requests and management
CREATE TABLE public.rides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rider_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    driver_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    pickup_latitude DOUBLE PRECISION NOT NULL,
    pickup_longitude DOUBLE PRECISION NOT NULL,
    pickup_address TEXT NOT NULL,
    destination_latitude DOUBLE PRECISION NOT NULL,
    destination_longitude DOUBLE PRECISION NOT NULL,
    destination_address TEXT NOT NULL,
    vehicle_type public.vehicle_type DEFAULT 'economy'::public.vehicle_type,
    status public.ride_status DEFAULT 'requested'::public.ride_status,
    fare_amount DECIMAL(10,2),
    payment_method public.payment_method DEFAULT 'cash'::public.payment_method,
    requested_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- OTP verification table
CREATE TABLE public.otp_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    phone_number TEXT NOT NULL,
    otp_code TEXT NOT NULL,
    purpose TEXT NOT NULL, -- 'registration', 'login', 'password_reset'
    expires_at TIMESTAMPTZ NOT NULL,
    verified_at TIMESTAMPTZ,
    attempts INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Ride ratings and feedback
CREATE TABLE public.ride_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id UUID REFERENCES public.rides(id) ON DELETE CASCADE,
    rater_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    ratee_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_phone ON public.user_profiles(phone_number);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_driver_profiles_user_id ON public.driver_profiles(user_id);
CREATE INDEX idx_driver_profiles_is_online ON public.driver_profiles(is_online);
CREATE INDEX idx_driver_profiles_location ON public.driver_profiles(current_latitude, current_longitude);
CREATE INDEX idx_rides_rider_id ON public.rides(rider_id);
CREATE INDEX idx_rides_driver_id ON public.rides(driver_id);
CREATE INDEX idx_rides_status ON public.rides(status);
CREATE INDEX idx_rides_requested_at ON public.rides(requested_at);
CREATE INDEX idx_otp_verifications_phone ON public.otp_verifications(phone_number);
CREATE INDEX idx_otp_verifications_expires_at ON public.otp_verifications(expires_at);
CREATE INDEX idx_ride_ratings_ride_id ON public.ride_ratings(ride_id);

-- 4. Functions (MUST BE BEFORE RLS POLICIES)

-- Function for automatic user profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, phone_number, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    NEW.raw_user_meta_data->>'phone_number',
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'rider'::public.user_role)
  );
  RETURN NEW;
END;
$$;

-- Function to update driver rating
CREATE OR REPLACE FUNCTION public.update_driver_rating()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
    avg_rating DECIMAL(3,2);
    total_ratings INTEGER;
BEGIN
    -- Calculate new average rating for the driver
    SELECT AVG(rating)::DECIMAL(3,2), COUNT(*)
    INTO avg_rating, total_ratings
    FROM public.ride_ratings
    WHERE ratee_id = NEW.ratee_id;
    
    -- Update driver profile
    UPDATE public.driver_profiles
    SET rating = COALESCE(avg_rating, 0.00),
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = NEW.ratee_id;
    
    RETURN NEW;
END;
$$;

-- Function to generate OTP
CREATE OR REPLACE FUNCTION public.generate_otp_code()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0');
END;
$$;

-- 5. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.otp_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ride_ratings ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies (Using Correct Patterns)

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for driver_profiles
CREATE POLICY "users_manage_own_driver_profiles"
ON public.driver_profiles
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 3: Operation-specific for rides (riders can create, both can view)
CREATE POLICY "riders_can_create_rides"
ON public.rides
FOR INSERT
TO authenticated
WITH CHECK (rider_id = auth.uid());

CREATE POLICY "users_can_view_own_rides"
ON public.rides
FOR SELECT
TO authenticated
USING (rider_id = auth.uid() OR driver_id = auth.uid());

CREATE POLICY "drivers_can_accept_rides"
ON public.rides
FOR UPDATE
TO authenticated
USING (driver_id = auth.uid() OR (driver_id IS NULL AND status = 'requested'));

-- Pattern 2: Simple user ownership for OTP verifications
CREATE POLICY "users_manage_own_otp_verifications"
ON public.otp_verifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for ride ratings
CREATE POLICY "users_manage_own_ride_ratings"
ON public.ride_ratings
FOR ALL
TO authenticated
USING (rater_id = auth.uid())
WITH CHECK (rater_id = auth.uid());

-- 7. Triggers
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER on_ride_rating_created
    AFTER INSERT ON public.ride_ratings
    FOR EACH ROW EXECUTE FUNCTION public.update_driver_rating();

-- 8. Mock Data with Complete Auth Users
DO $$
DECLARE
    rider_uuid UUID := gen_random_uuid();
    driver_uuid UUID := gen_random_uuid();
    admin_uuid UUID := gen_random_uuid();
    sample_ride_uuid UUID := gen_random_uuid();
    sample_otp_uuid UUID := gen_random_uuid();
BEGIN
    -- Create complete auth users with all required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (rider_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'rider@rideguyana.com', crypt('rider123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Rider", "phone_number": "+5921234567", "role": "rider"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (driver_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'driver@rideguyana.com', crypt('driver123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Sarah Driver", "phone_number": "+5927654321", "role": "driver"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@rideguyana.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "phone_number": "+5920000000", "role": "admin"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create driver profile for the driver user
    INSERT INTO public.driver_profiles (
        user_id, license_number, license_expiry, vehicle_registration, 
        vehicle_model, vehicle_color, vehicle_type, is_verified, is_online,
        current_latitude, current_longitude, rating, total_rides
    ) VALUES (
        driver_uuid, 'GY123456789', '2025-12-31', 'GHH1234', 
        'Toyota Camry', 'White', 'comfort', true, true,
        6.8013, -58.1551, 4.5, 25
    );

    -- Create sample ride
    INSERT INTO public.rides (
        id, rider_id, driver_id, pickup_latitude, pickup_longitude, pickup_address,
        destination_latitude, destination_longitude, destination_address,
        vehicle_type, status, fare_amount, payment_method, requested_at, accepted_at
    ) VALUES (
        sample_ride_uuid, rider_uuid, driver_uuid, 
        6.8013, -58.1551, 'Georgetown, Main Street',
        6.8206, -58.1624, 'Stabroek Market, Water Street',
        'comfort', 'accepted', 15.00, 'cash', 
        CURRENT_TIMESTAMP - INTERVAL '10 minutes', 
        CURRENT_TIMESTAMP - INTERVAL '5 minutes'
    );

    -- Create sample OTP verification
    INSERT INTO public.otp_verifications (
        id, user_id, phone_number, otp_code, purpose, expires_at
    ) VALUES (
        sample_otp_uuid, rider_uuid, '+5921234567', '123456', 
        'registration', CURRENT_TIMESTAMP + INTERVAL '10 minutes'
    );

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;