// lib/utils/location_helper.dart

import 'package:geolocator/geolocator.dart';
import 'dart:developer';

class LocationHelper {
  /// 🔹 Get the current position (latitude, longitude, accuracy, speed)
  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('⚠️ Location services are disabled.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        log('🚫 Location permission permanently denied.');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      log('📍 Current position: '
          'lat=${position.latitude}, lng=${position.longitude}, '
          'speed=${position.speed.toStringAsFixed(2)} m/s');

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'speed': position.speed,
        'timestamp': position.timestamp.toIso8601String(),
      };
    } catch (e) {
      log('❌ Error getting current location: $e');
      return null;
    }
  }

  /// 🔁 Stream continuous position updates (every few seconds)
  static Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 5, // meters moved before update
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}
