-- Fix RLS policies to allow proper registration flow

-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;

-- Create more appropriate policies for registration
CREATE POLICY "Allow authenticated users to read all profiles"
ON profiles FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Allow authenticated users to insert their own profile"
ON profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

CREATE POLICY "Allow users to update their own profile"
ON profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id);

-- Allow service role full access for registration process
CREATE POLICY "Allow service role full access"
ON profiles FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Create a function to handle new user registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    full_name,
    email,
    phone,
    user_type,
    email_verified,
    phone_verified,
    is_active
  )
  VALUES (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.email,
    new.raw_user_meta_data->>'phone',
    COALESCE(new.raw_user_meta_data->>'user_type', 'Rider'),
    false,
    false,
    true
  );
  RETURN new;
END;
$$ language plpgsql security definer;

-- Create trigger to automatically create profile when user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language plpgsql security definer;

-- Create trigger for updated_at
DROP TRIGGER IF EXISTS profiles_updated_at ON profiles;
CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();