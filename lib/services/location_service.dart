import 'package:geolocator/geolocator.dart';

class LocationService {
  Stream<Position> get locationStream {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }
}
