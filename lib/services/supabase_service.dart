import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Initialize Supabase - call this in main()
  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be defined using --dart-define.',
      );
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  // Get Supabase client
  SupabaseClient get client => Supabase.instance.client;

  // Auth methods
  Future<User?> getCurrentUser() async {
    return client.auth.currentUser;
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Supabase signInWithEmail error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );

      print('Supabase signUp response: ${response.user?.id}');
      return response;
    } catch (e) {
      print('Supabase signUpWithEmail error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // User Profile methods
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response =
          await client.from('profiles').select().eq('id', userId).maybeSingle();
      return response;
    } catch (e) {
      print('Supabase getUserProfile error: $e');
      rethrow;
    }
  }

  Future<void> createUserProfile({
    required String userId,
    required String fullName,
    required String email,
    required String phone,
    required String userType,
  }) async {
    try {
      // Ensure user type is lowercase for consistency
      final normalizedUserType = userType.toLowerCase();

      final profileData = {
        'id': userId,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'user_type': normalizedUserType,
        'email_verified': false,
        'phone_verified': false,
        'is_active': true,
        'avatar_url': null,
      };

      print('Creating profile with data: $profileData');

      await client.from('profiles').insert(profileData);
      print('Profile created successfully for user: $userId');
    } catch (e) {
      print('Supabase createUserProfile error: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await client.from('profiles').update(data).eq('id', userId);
    } catch (e) {
      print('Supabase updateUserProfile error: $e');
      rethrow;
    }
  }

  // Check if user exists by email or phone
  Future<bool> checkUserExists({String? email, String? phone}) async {
    try {
      // Only check profiles table since we can't access auth.users with anon key
      if (email != null) {
        final emailResponse =
            await client
                .from('profiles')
                .select('id')
                .eq('email', email)
                .maybeSingle();
        if (emailResponse != null) return true;
      }

      if (phone != null) {
        final phoneResponse =
            await client
                .from('profiles')
                .select('id')
                .eq('phone', phone)
                .maybeSingle();
        if (phoneResponse != null) return true;
      }

      return false;
    } catch (e) {
      print('Supabase checkUserExists error: $e');
      // If we can't check, allow registration to proceed
      return false;
    }
  }

  // Enhanced error handling helper
  String getReadableError(dynamic error) {
    if (error == null) return 'Unknown error occurred';

    String errorString = error.toString();

    if (errorString.contains('User already registered')) {
      return 'This email is already registered. Please use a different email or try signing in.';
    }

    if (errorString.contains('Invalid email') ||
        errorString.contains('Unable to validate email address')) {
      return 'Please enter a valid email address.';
    }

    if (errorString.contains('Password should be at least 6 characters')) {
      return 'Password must be at least 6 characters long.';
    }

    if (errorString.contains('Signup requires a valid password')) {
      return 'Please enter a valid password.';
    }

    if (errorString.contains('Email rate limit exceeded')) {
      return 'Too many registration attempts. Please wait a few minutes and try again.';
    }

    if (errorString.contains('Invalid phone number')) {
      return 'Please enter a valid phone number.';
    }

    if (errorString.contains(
      'duplicate key value violates unique constraint',
    )) {
      if (errorString.contains('profiles_email_key')) {
        return 'This email address is already registered.';
      }
      if (errorString.contains('profiles_phone_key')) {
        return 'This phone number is already registered.';
      }
      return 'Account already exists. Please try signing in instead.';
    }

    if (errorString.contains('JWT expired') ||
        errorString.contains('invalid JWT')) {
      return 'Session expired. Please try again.';
    }

    if (errorString.contains('Network request failed') ||
        errorString.contains('Failed to fetch') ||
        errorString.contains('NetworkError')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    if (errorString.contains('row-level security') ||
        errorString.contains('RLS')) {
      return 'Access denied. Please try again or contact support.';
    }

    if (errorString.contains('Email not confirmed')) {
      return 'Please check your email and click the confirmation link before proceeding.';
    }

    // Extract specific PostgreSQL error messages
    if (errorString.contains('violates check constraint')) {
      return 'Invalid data format. Please check your input and try again.';
    }

    return 'Registration failed. Please try again or contact support if the problem persists.';
  }

  // Real-time subscriptions
  RealtimeChannel subscribeToChanges(
    String table,
    Function(List<Map<String, dynamic>>) callback,
  ) {
    return client
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: (payload) {
            callback([payload.newRecord]);
          },
        )
        .subscribe();
  }

  // Generic CRUD operations
  Future<List<Map<String, dynamic>>> select(
    String table, {
    String? columns,
  }) async {
    final response = await client.from(table).select(columns ?? '*');
    return response;
  }

  Future<List<Map<String, dynamic>>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await client.from(table).insert(data).select();
    return response;
  }

  Future<List<Map<String, dynamic>>> update(
    String table,
    Map<String, dynamic> data,
    String column,
    dynamic value,
  ) async {
    final response =
        await client.from(table).update(data).eq(column, value).select();
    return response;
  }

  Future<void> delete(String table, String column, dynamic value) async {
    await client.from(table).delete().eq(column, value);
  }
}
