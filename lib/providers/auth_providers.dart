import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🔐 Logged-in driver ID
final driverIdProvider = StateProvider<String?>((ref) => null);

/// 🔐 Stored JWT token
final authTokenProvider = StateProvider<String?>((ref) => null);

/// 👤 User type (driver / rider)
final userTypeProvider = StateProvider<String?>((ref) => null);

/// 👤 Optional: Store Driver Name (UI uses this)
final driverNameProvider = StateProvider<String?>((ref) => null);

/// 📞 Optional: Store Driver Phone (UI uses this)
final driverPhoneProvider = StateProvider<String?>((ref) => null);

/// 🔔 Notifications count can also be stored globally if needed
final unreadNotificationsProvider = StateProvider<int>((ref) => 0);
