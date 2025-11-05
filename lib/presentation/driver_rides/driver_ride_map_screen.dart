import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../services/socket_service.dart';
import '../../services/api_service.dart';
import '../../utils/toast_helper.dart';

class DriverRideMapScreen extends StatefulWidget {
  final Map<String, dynamic> ride;
  const DriverRideMapScreen({Key? key, required this.ride}) : super(key: key);

  @override
  State<DriverRideMapScreen> createState() => _DriverRideMapScreenState();
}

class _DriverRideMapScreenState extends State<DriverRideMapScreen> {
  GoogleMapController? _controller;
  LatLng? _driverPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  late StreamSubscription<Position> _positionStream;
  bool _rideActive = false;
  String googleApiKey = "YOUR_GOOGLE_MAPS_API_KEY"; // 👈 Replace with your key

  @override
  void initState() {
    super.initState();
    _initMapAndLocation();
  }

  Future<void> _initMapAndLocation() async {
    await _checkPermission();

    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _driverPosition = LatLng(pos.latitude, pos.longitude);
    });

    _updateDriverMarker(_driverPosition!);
    _listenLocation();
    _setPickupDropMarkers();
    _drawRoute();
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ToastHelper.showError('Location services disabled.');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ToastHelper.showError('Location permission denied.');
        return;
      }
    }
  }

  void _listenLocation() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 5),
    ).listen((pos) {
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() => _driverPosition = latLng);
      _updateDriverMarker(latLng);

      // Send to backend or socket
      SocketService.emit('driver_location', {
        'driver_id': widget.ride['driver_id'],
        'latitude': pos.latitude,
        'longitude': pos.longitude,
      });
    });
  }

  void _updateDriverMarker(LatLng pos) {
    final marker = Marker(
      markerId: const MarkerId('driver'),
      position: pos,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: 'You'),
    );
    setState(() => _markers.add(marker));
  }

  void _setPickupDropMarkers() {
    final pickup = LatLng(widget.ride['pickup_lat'], widget.ride['pickup_lng']);
    final dropoff =
    LatLng(widget.ride['dropoff_lat'], widget.ride['dropoff_lng']);

    _markers.addAll([
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      ),
      Marker(
        markerId: const MarkerId('dropoff'),
        position: dropoff,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Dropoff Location'),
      ),
    ]);
  }

  Future<void> _drawRoute() async {
    final pickup = LatLng(widget.ride['pickup_lat'], widget.ride['pickup_lng']);
    final dropoff =
    LatLng(widget.ride['dropoff_lat'], widget.ride['dropoff_lng']);

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${pickup.latitude},${pickup.longitude}&destination=${dropoff.latitude},${dropoff.longitude}&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['routes'].isEmpty) return;

    final polylinePoints = PolylinePoints();
    final route = data['routes'][0]['overview_polyline']['points'];
    final result = polylinePoints.decodePolyline(route);

    setState(() {
      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: result
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList(),
        color: Colors.green,
        width: 5,
      ));
    });
  }

  Future<void> _handleRideStart() async {
    setState(() => _rideActive = true);
    SocketService.emit('ride_started', widget.ride);
    ToastHelper.showInfo('Ride started');
  }

  Future<void> _handleRideComplete() async {
    setState(() => _rideActive = false);
    SocketService.emit('ride_completed', widget.ride);
    await ApiService.updateDriverLocation({
      'driver_id': widget.ride['driver_id'],
      'latitude': _driverPosition?.latitude,
      'longitude': _driverPosition?.longitude,
    });
    ToastHelper.showSuccess('Ride completed');
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _driverPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _controller = controller,
            initialCameraPosition: CameraPosition(
                target: _driverPosition!, zoom: 14),
            myLocationEnabled: true,
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                _rideActive ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed:
              _rideActive ? _handleRideComplete : _handleRideStart,
              child: Text(
                _rideActive ? 'Complete Ride' : 'Start Ride',
                style:
                const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
