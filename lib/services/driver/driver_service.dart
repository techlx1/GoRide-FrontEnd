import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverService {
  DriverService._();
  static final instance = DriverService._();

  final SupabaseClient supabase = Supabase.instance.client;

  /// Fetch driver profile data
  Future<Map<String, dynamic>> getDriverProfile(String userId) async {
    try {
      final response = await supabase
          .from('drivers')
          .select('*')
          .eq('id', userId)
          .single();

      final data = Map<String, dynamic>.from(response);
      data.putIfAbsent('is_online', () => false);
      return data;
    } on PostgrestException catch (e, st) {
      log('❌ Supabase error in getDriverProfile', error: e.message, stackTrace: st);
      throw Exception('Failed to fetch driver profile: ${e.message}');
    } catch (e, st) {
      log('❌ Unexpected error in getDriverProfile', error: e, stackTrace: st);
      throw Exception('Unexpected error fetching driver profile.');
    }
  }

  /// Update driver online/offline status
  Future<bool> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await supabase
          .from('drivers')
          .update({'is_online': isOnline})
          .eq('id', userId);
      return true;
    } on PostgrestException catch (e, st) {
      log('❌ Supabase error in updateOnlineStatus', error: e.message, stackTrace: st);
      return false;
    } catch (e, st) {
      log('❌ Unexpected error in updateOnlineStatus', error: e, stackTrace: st);
      return false;
    }
  }
}
