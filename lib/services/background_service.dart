import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'socket_service.dart';
import 'api_service.dart';

class BackgroundServiceHandler {
  /// Initialize background tracking service
  static Future<void> initializeService(int driverId) async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'g_ride_channel',
        initialNotificationTitle: 'G-Ride Active',
        initialNotificationContent: 'Tracking your location...',
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    await service.startService();
    log('🚀 Background service started for driver: $driverId');
  }
}

/// iOS background handler
@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  return true;
}

/// Android + iOS service entry point
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Stop service listener
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  final prefs = await SharedPreferences.getInstance();
  final driverId = prefs.getInt('driver_id') ?? 0;

  if (driverId == 0) {
    log('⚠️ No driver ID found. Stopping service.');
    service.stopSelf();
    return;
  }

  // ✅ Ensure permissions
  await _ensureLocationPermission();

  // ✅ Connect socket
  await SocketService.connect(
    baseUrl: 'https://g-ride-backend.onrender.com',
    token: driverId.toString(),
  );

  // ✅ Update driver status to online
  await ApiService.updateDriverStatus(driverId, true);

  // ✅ Start periodic GPS tracking
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (!(await Geolocator.isLocationServiceEnabled())) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 🔥 Emit live location to backend
      SocketService.emitDriverLocation(
        driverId: driverId,
        rideId: 0, // Change when active ride starts
        latitude: position.latitude,
        longitude: position.longitude,
      );

      log('📡 Location sent → lat=${position.latitude}, lng=${position.longitude}');
    } catch (e) {
      log('❌ Error getting location: $e');
    }
  });

  // ✅ Foreground mode for Android
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: 'G-Ride Active',
      content: 'Sharing location in background...',
    );
  }
}

/// 🔐 Ensure location permission granted
Future<void> _ensureLocationPermission() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    log('⚠️ Location permissions permanently denied.');
  }
}
