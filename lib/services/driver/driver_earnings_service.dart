import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverEarningsService {
  DriverEarningsService._();
  static final instance = DriverEarningsService._();

  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getDriverEarnings(String userId) async {
    try {
      final session = supabase.auth.currentSession;
      if (session == null) throw Exception('Session expired. Please log in.');

      final res = await supabase.rpc(
        'get_driver_earnings',
        params: {'driver_id': userId},
      );

      // Normalize and handle multiple response shapes
      Map<String, dynamic> data = {};
      if (res is List && res.isNotEmpty && res.first is Map<String, dynamic>) {
        data = Map<String, dynamic>.from(res.first);
      } else if (res is Map<String, dynamic>) {
        data = Map<String, dynamic>.from(res);
      }

      // Flatten if nested under 'earnings'
      if (data.containsKey('earnings') && data['earnings'] is Map) {
        data = Map<String, dynamic>.from(data['earnings']);
      }

      // Ensure expected fields always exist
      data.putIfAbsent('today', () => 0);
      data.putIfAbsent('trips', () => 0);
      data.putIfAbsent('total', () => 0);
      data.putIfAbsent('weeklyTrips', () => 0);
      data.putIfAbsent('weeklyEarnings', () => 0);
      data.putIfAbsent('averageRating', () => 0.0);
      data.putIfAbsent('hoursWorked', () => 0);

      return data;
    } on PostgrestException catch (e, st) {
      log('❌ Supabase RPC error in getDriverEarnings', error: e.message, stackTrace: st);
      throw Exception('Failed to load earnings: ${e.message}');
    } catch (e, st) {
      log('❌ Unexpected error in getDriverEarnings', error: e, stackTrace: st);
      throw Exception('Unexpected error fetching earnings.');
    }
  }
}
