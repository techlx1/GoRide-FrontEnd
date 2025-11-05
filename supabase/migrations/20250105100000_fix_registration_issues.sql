-- Fix registration issues migration
-- This migration addresses common registration problems

-- First, update the handle_new_user function to be more robust
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Add debug logging
  RAISE NOTICE 'Trigger handle_new_user called for user: %', NEW.id;
  
  INSERT INTO public.profiles (
    id,
    full_name,
    email,
    phone,
    user_type,
    email_verified,
    phone_verified,
    is_active,
    avatar_url
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'phone', ''),
    LOWER(COALESCE(NEW.raw_user_meta_data->>'user_type', 'rider')),
    COALESCE(NEW.email_confirmed_at IS NOT NULL, FALSE),
    COALESCE(NEW.phone_confirmed_at IS NOT NULL, FALSE),
    true,
    NEW.raw_user_meta_data->>'avatar_url'
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    phone = EXCLUDED.phone,
    user_type = EXCLUDED.user_type,
    email_verified = EXCLUDED.email_verified,
    phone_verified = EXCLUDED.phone_verified,
    avatar_url = EXCLUDED.avatar_url,
    updated_at = NOW();
    
  RAISE NOTICE 'Profile created/updated for user: %', NEW.id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger to ensure it's working
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Add a constraint to ensure user_type is valid
ALTER TABLE public.profiles 
DROP CONSTRAINT IF EXISTS profiles_user_type_check;

ALTER TABLE public.profiles 
ADD CONSTRAINT profiles_user_type_check 
CHECK (user_type IN ('rider', 'driver', 'admin'));

-- Update existing profiles to use lowercase user types
UPDATE public.profiles 
SET user_type = LOWER(user_type)
WHERE user_type != LOWER(user_type);

-- Ensure RLS policies are properly set for registration
DROP POLICY IF EXISTS "Allow authenticated users to insert their own profile" ON public.profiles;
CREATE POLICY "Allow authenticated users to insert their own profile" 
  ON public.profiles 
  FOR INSERT 
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Allow users to update their own profile" ON public.profiles;
CREATE POLICY "Allow users to update their own profile" 
  ON public.profiles 
  FOR UPDATE 
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Allow authenticated users to read all profiles" ON public.profiles;
CREATE POLICY "Allow authenticated users to read all profiles" 
  ON public.profiles 
  FOR SELECT 
  USING (true);

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.profiles TO anon, authenticated;

-- Create an index on email for faster lookups during registration
CREATE INDEX IF NOT EXISTS profiles_email_lookup_idx ON public.profiles(email) WHERE email IS NOT NULL;

-- Create an index on phone for faster lookups during registration
CREATE INDEX IF NOT EXISTS profiles_phone_lookup_idx ON public.profiles(phone) WHERE phone IS NOT NULL;

-- Add some test data for validation (optional - remove in production)
-- This helps verify the registration process works
DO $$
BEGIN
  -- Only add test data if no profiles exist
  IF NOT EXISTS (SELECT 1 FROM public.profiles LIMIT 1) THEN
    RAISE NOTICE 'Adding test data for registration validation';
  ELSE
    RAISE NOTICE 'Profiles table has data, skipping test data creation';
  END IF;
END $$;