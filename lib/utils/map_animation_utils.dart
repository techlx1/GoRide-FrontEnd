import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

double _toRadians(double degree) => degree * pi / 180;

double calculateBearing(LatLng start, LatLng end) {
  final lat1 = _toRadians(start.latitude);
  final lng1 = _toRadians(start.longitude);
  final lat2 = _toRadians(end.latitude);
  final lng2 = _toRadians(end.longitude);

  final dLng = lng2 - lng1;

  final y = sin(dLng) * cos(lat2);
  final x = cos(lat1) * sin(lat2) -
      sin(lat1) * cos(lat2) * cos(dLng);

  double bearing = atan2(y, x);
  bearing = bearing * 180 / pi;
  return (bearing + 360) % 360;
}
