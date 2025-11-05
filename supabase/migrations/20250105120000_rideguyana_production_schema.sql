-- Location: supabase/migrations/20250105120000_rideguyana_production_schema.sql
-- Schema Analysis: Existing profiles table with basic user data
-- Integration Type: Extension of existing schema for ride-hailing functionality
-- Dependencies: Existing profiles table

-- 1. Create enums for ride-hailing functionality
CREATE TYPE public.ride_status AS ENUM ('requested', 'accepted', 'in_progress', 'completed', 'cancelled');
CREATE TYPE public.vehicle_type AS ENUM ('economy', 'comfort', 'premium', 'suv', 'motorcycle');
CREATE TYPE public.payment_method AS ENUM ('cash', 'card', 'mobile_money');

-- 2. Extend existing profiles table for driver functionality
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS current_latitude DECIMAL(10, 8);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS current_longitude DECIMAL(11, 8);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT false;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS vehicle_model TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS vehicle_color TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS vehicle_plate_number TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS rating DECIMAL(3, 2) DEFAULT 5.0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS total_rides INTEGER DEFAULT 0;

-- 3. Create rides table (main functionality)
CREATE TABLE public.rides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rider_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    driver_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    pickup_latitude DECIMAL(10, 8) NOT NULL,
    pickup_longitude DECIMAL(11, 8) NOT NULL,
    pickup_address TEXT NOT NULL,
    destination_latitude DECIMAL(10, 8) NOT NULL,
    destination_longitude DECIMAL(11, 8) NOT NULL,
    destination_address TEXT NOT NULL,
    status public.ride_status DEFAULT 'requested'::public.ride_status,
    vehicle_type public.vehicle_type NOT NULL,
    payment_method public.payment_method DEFAULT 'cash'::public.payment_method,
    fare_amount DECIMAL(10, 2),
    distance_km DECIMAL(6, 2),
    duration_minutes INTEGER,
    requested_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    cancellation_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create OTP verifications table
CREATE TABLE public.otp_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    phone_number TEXT NOT NULL,
    otp_code TEXT NOT NULL,
    purpose TEXT NOT NULL, -- 'registration', 'login', 'password_reset'
    attempts INTEGER DEFAULT 0,
    verified_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Create ride ratings table
CREATE TABLE public.ride_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ride_id UUID REFERENCES public.rides(id) ON DELETE CASCADE,
    rater_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    ratee_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. Create indexes for performance
CREATE INDEX idx_profiles_user_type ON public.profiles(user_type);
CREATE INDEX idx_profiles_location ON public.profiles(current_latitude, current_longitude) WHERE is_online = true;
CREATE INDEX idx_profiles_online_drivers ON public.profiles(is_online, user_type) WHERE user_type = 'driver';

CREATE INDEX idx_rides_rider_id ON public.rides(rider_id);
CREATE INDEX idx_rides_driver_id ON public.rides(driver_id);
CREATE INDEX idx_rides_status ON public.rides(status);
CREATE INDEX idx_rides_requested_at ON public.rides(requested_at);
CREATE INDEX idx_rides_location_pickup ON public.rides(pickup_latitude, pickup_longitude);

CREATE INDEX idx_otp_phone_purpose ON public.otp_verifications(phone_number, purpose);
CREATE INDEX idx_otp_expires_at ON public.otp_verifications(expires_at);

CREATE INDEX idx_ride_ratings_ride_id ON public.ride_ratings(ride_id);
CREATE INDEX idx_ride_ratings_ratee_id ON public.ride_ratings(ratee_id);

-- 7. Enable RLS on all tables
ALTER TABLE public.rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.otp_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ride_ratings ENABLE ROW LEVEL SECURITY;

-- 8. Create RLS policies following Pattern 1 for profiles (existing table)
-- Profiles table already has RLS enabled, keep existing policies

-- 9. Create RLS policies for rides (Pattern 2: Simple User Ownership)
CREATE POLICY "users_manage_own_rides_as_rider"
ON public.rides
FOR ALL
TO authenticated
USING (rider_id = auth.uid())
WITH CHECK (rider_id = auth.uid());

CREATE POLICY "drivers_manage_assigned_rides"
ON public.rides
FOR ALL
TO authenticated
USING (driver_id = auth.uid())
WITH CHECK (driver_id = auth.uid());

-- 10. Create RLS policies for OTP verifications
CREATE POLICY "users_manage_own_otp_verifications"
ON public.otp_verifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Allow reading OTP by phone number for verification (service role only)
CREATE POLICY "service_role_otp_access"
ON public.otp_verifications
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- 11. Create RLS policies for ride ratings
CREATE POLICY "users_manage_own_ride_ratings_as_rater"
ON public.ride_ratings
FOR ALL
TO authenticated
USING (rater_id = auth.uid())
WITH CHECK (rater_id = auth.uid());

-- Allow reading ratings for rides users are involved in
CREATE POLICY "users_can_view_relevant_ride_ratings"
ON public.ride_ratings
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.rides r 
        WHERE r.id = ride_id 
        AND (r.rider_id = auth.uid() OR r.driver_id = auth.uid())
    )
);

-- 12. Create updated_at trigger function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$;

-- Add updated_at trigger to rides table
CREATE TRIGGER rides_updated_at
    BEFORE UPDATE ON public.rides
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 13. Create sample production data
DO $$
DECLARE
    rider_id UUID;
    driver_id UUID;
    sample_ride_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user from profiles table
    SELECT id INTO rider_id FROM public.profiles WHERE user_type = 'rider' OR user_type = 'user' LIMIT 1;
    SELECT id INTO driver_id FROM public.profiles WHERE user_type = 'driver' LIMIT 1;
    
    -- If we have users, create sample data
    IF rider_id IS NOT NULL AND driver_id IS NOT NULL THEN
        -- Update driver with location and vehicle info
        UPDATE public.profiles 
        SET 
            current_latitude = 6.8013,
            current_longitude = -58.1551,
            is_online = true,
            is_verified = true,
            vehicle_model = 'Toyota Corolla',
            vehicle_color = 'White',
            vehicle_plate_number = 'GYY-1234',
            rating = 4.8
        WHERE id = driver_id;
        
        -- Create sample ride
        INSERT INTO public.rides (
            id, rider_id, driver_id, pickup_latitude, pickup_longitude, 
            pickup_address, destination_latitude, destination_longitude, 
            destination_address, status, vehicle_type, payment_method, 
            fare_amount, distance_km, duration_minutes, requested_at, 
            accepted_at, completed_at
        ) VALUES (
            sample_ride_id, rider_id, driver_id, 6.8028, -58.1551,
            'Georgetown Public Hospital, Georgetown, Guyana',
            6.8046, -58.1558,
            'Stabroek Market, Georgetown, Guyana',
            'completed'::public.ride_status,
            'economy'::public.vehicle_type,
            'cash'::public.payment_method,
            850.00, 2.1, 12,
            CURRENT_TIMESTAMP - INTERVAL '1 hour',
            CURRENT_TIMESTAMP - INTERVAL '55 minutes',
            CURRENT_TIMESTAMP - INTERVAL '43 minutes'
        );
        
        -- Create sample rating
        INSERT INTO public.ride_ratings (ride_id, rater_id, ratee_id, rating, comment)
        VALUES (sample_ride_id, rider_id, driver_id, 5, 'Excellent service, very professional driver!');
        
        RAISE NOTICE 'Sample ride data created successfully';
    ELSE
        RAISE NOTICE 'No existing users found. Create users first through the app registration.';
    END IF;
END $$;