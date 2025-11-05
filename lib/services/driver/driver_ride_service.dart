import 'package:supabase_flutter/supabase_flutter.dart';

class DriverRideService {
  DriverRideService._();
  static final instance = DriverRideService._();

  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getActiveRide(String userId) async {
    final res = await supabase
        .from('rides')
        .select()
        .eq('driver_id', userId)
        .eq('status', 'active')
        .maybeSingle();
    return res;
  }

  Future<bool> acceptRide(int rideId, String userId) async {
    final res = await supabase
        .from('rides')
        .update({'status': 'accepted', 'driver_id': userId})
        .eq('id', rideId);
    return res.error == null;
  }

  Future<bool> updateRideStatus(int rideId, String newStatus) async {
    final res =
    await supabase.from('rides').update({'status': newStatus}).eq('id', rideId);
    return res.error == null;
  }

  Future<List<Map<String, dynamic>>> getPendingRideRequests({
    required double latitude,
    required double longitude,
  }) async {
    final res = await supabase.rpc('get_pending_ride_requests', params: {
      'lat': latitude,
      'lng': longitude,
    });
    return List<Map<String, dynamic>>.from(res ?? []);
  }
}
