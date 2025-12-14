import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_providers.dart';
import '../providers/driver_providers.dart';
import '../services/socket_service.dart';
import '../routes/app_routes.dart';

class LogoutHelper {
  static Future<void> logout(BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();

    // Clear saved login data
    await prefs.remove("auth_token");
    await prefs.remove("user_type");
    await prefs.remove("user_id");

    // Reset Riverpod state
    ref.read(authTokenProvider.notifier).state = null;
    ref.read(userTypeProvider.notifier).state = null;
    ref.read(driverIdProvider.notifier).state = null;
    ref.read(driverOnlineProvider.notifier).state = false;

    // Close socket connection
    SocketService().disconnect();

    // Navigate to login - clear back stack
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }
}
