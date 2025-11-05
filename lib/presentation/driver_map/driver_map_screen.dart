import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/socket_service.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({Key? key}) : super(key: key);

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  GoogleMapController? _controller;
  LatLng? _currentPos;
  Marker? _driverMarker;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() => _currentPos = LatLng(position.latitude, position.longitude));
    _updateDriverMarker(_currentPos!);
  }

  void _updateDriverMarker(LatLng pos) {
    setState(() {
      _driverMarker = Marker(
        markerId: const MarkerId('driver'),
        position: pos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'You'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPos == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: (controller) => _controller = controller,
        initialCameraPosition:
        CameraPosition(target: _currentPos!, zoom: 15),
        markers: _driverMarker != null ? {_driverMarker!} : {},
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
