import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_providers.dart';

/// Loads saved login session on app startup
final authInitProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();

  final token = prefs.getString("auth_token");
  final userType = prefs.getString("user_type");
  final driverId = prefs.getString("user_id");

  if (token != null) {
    ref.read(authTokenProvider.notifier).state = token;
  }

  if (userType != null) {
    ref.read(userTypeProvider.notifier).state = userType;
  }

  /// Only set driverId if the user is really a driver
  if (userType == "driver" && driverId != null) {
    ref.read(driverIdProvider.notifier).state = driverId;
  }
});
