import 'package:supabase_flutter/supabase_flutter.dart';

class DriverLocationService {
  DriverLocationService._();
  static final instance = DriverLocationService._();

  final supabase = Supabase.instance.client;

  Future<void> updateDriverLocation(
      String userId, double latitude, double longitude) async {
    await supabase.from('drivers').update({
      'latitude': latitude,
      'longitude': longitude,
    }).eq('user_id', userId);
  }
}
