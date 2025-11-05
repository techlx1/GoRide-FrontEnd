// lib/utils/permission_helper.dart

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PermissionHelper {
  /// 🛰️ Request and verify location permissions
  static Future<void> ensurePermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(
        msg: "Please enable Location Services.",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
        msg: "Location permission permanently denied. Please enable manually.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      await Geolocator.openAppSettings();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Fluttertoast.showToast(
        msg: "✅ Location access granted.",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }
}
