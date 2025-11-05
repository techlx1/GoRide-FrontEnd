import 'dart:async';
import 'dart:developer';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'socket_service.dart';
import '../utils/toast_helper.dart';

class BackgroundLocationService {
  static bool _isInitialized = false;
  static StreamSubscription<ServiceStatus>? _serviceStatusStream;

  /// 🔹 Initialize background tracking (only once)
  static Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await Geolocator.requestPermission();
    await Geolocator.isLocationServiceEnabled();

    await BackgroundLocator.initialize();
    log('🛰️ BackgroundLocator initialized');

    _serviceStatusStream =
        Geolocator.getServiceStatusStream().listen((status) {
          log('📍 Location service status: $status');
        });
  }

  /// 🔹 Start background location updates
  static Future<void> startTracking({
    required int driverId,
    required int rideId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('driver_id', driverId);
      await prefs.setInt('ride_id', rideId);

      await BackgroundLocator.registerLocationUpdate(
        callback,
        initCallback: initCallback,
        disposeCallback: disposeCallback,
        autoStop: false,
        iosSettings: const IOSSettings(
          accuracy: LocationAccuracy.NAVIGATION,
          distanceFilter: 5,
        ),
        androidSettings: const AndroidSettings(
          accuracy: LocationAccuracy.NAVIGATION,
          interval: 5000, // every 5 seconds
          distanceFilter: 5,
          client: LocationClient.google,
          androidNotificationSettings: AndroidNotificationSettings(
            notificationChannelName: 'G-Ride Driver Tracking',
            notificationTitle: 'G-Ride is tracking your location',
            notificationMsg: 'Your live location is being shared.',
            notificationBigMsg:
            'G-Ride is updating your trip location in the background.',
            notificationIcon: '',
            notificationTapCallback: notificationCallback,
          ),
        ),
      );

      log('✅ Background tracking started for ride_$rideId');
      ToastHelper.showInfo('Driver location tracking started.');
    } catch (e) {
      log('❌ Failed to start background tracking: $e');
    }
  }

  /// 🔹 Stop background tracking
  static Future<void> stopTracking() async {
    try {
      await BackgroundLocator.unRegisterLocationUpdate();
      log('🛑 Background location tracking stopped');
    } catch (e) {
      log('❌ Error stopping background tracking: $e');
    }
  }

  // 📡 Location update callback (runs even when app is closed)
  static void callback(LocationDto locationDto) async {
    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getInt('driver_id');
    final rideId = prefs.getInt('ride_id');

    if (driverId != null && rideId != null) {
      final latitude = locationDto.latitude;
      final longitude = locationDto.longitude;

      SocketService.emitDriverLocation(
        driverId: driverId,
        rideId: rideId,
        latitude: latitude,
        longitude: longitude,
      );

      if (kDebugMode) {
        log('📍 BG Update → ride_$rideId | $latitude, $longitude');
      }
    }
  }

  static void initCallback(Map<dynamic, dynamic> params) {
    log('📲 Background locator init callback');
  }

  static void disposeCallback() {
    log('🧹 Background locator disposed');
  }

  static void notificationCallback() {
    log('🔔 Notification tapped');
  }
}
