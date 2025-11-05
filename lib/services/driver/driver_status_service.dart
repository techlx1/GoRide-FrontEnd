import 'package:supabase_flutter/supabase_flutter.dart';

class DriverStatusService {
  DriverStatusService._();
  static final instance = DriverStatusService._();

  final supabase = Supabase.instance.client;

  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    await supabase
        .from('drivers')
        .update({'is_online': isOnline})
        .eq('user_id', userId);
  }
}
