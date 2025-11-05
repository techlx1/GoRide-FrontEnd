import 'package:supabase_flutter/supabase_flutter.dart';

class DriverProfileService {
  DriverProfileService._();
  static final instance = DriverProfileService._();

  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getDriverProfile(String userId) async {
    final res = await supabase
        .from('drivers')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return res;
  }
}
