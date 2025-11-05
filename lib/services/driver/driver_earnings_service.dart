import 'package:supabase_flutter/supabase_flutter.dart';

class DriverEarningsService {
  DriverEarningsService._();
  static final instance = DriverEarningsService._();

  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getDriverEarnings(String userId) async {
    final res = await supabase
        .rpc('get_driver_earnings', params: {'driver_id': userId});
    return (res as Map<String, dynamic>?) ?? {};
  }
}
