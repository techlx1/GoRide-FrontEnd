import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Driver online/offline toggle
final driverOnlineProvider = StateProvider<bool>((ref) => false);

/// Show/hide Trip Radar bottom sheet
final showTripRadarProvider = StateProvider<bool>((ref) => false);
