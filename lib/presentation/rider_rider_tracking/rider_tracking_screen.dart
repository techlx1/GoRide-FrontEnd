import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/socket_service.dart';
import 'package:sizer/sizer.dart';

class RiderTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> ride;
  const RiderTrackingScreen({Key? key, required this.ride}) : super(key: key);

  @override
  State<RiderTrackingScreen> createState() => _RiderTrackingScreenState();
}

class _RiderTrackingScreenState extends State<RiderTrackingScreen> {
  GoogleMapController? _controller;
  LatLng? _pickup, _dropoff, _driverPos;
  Marker? _driverMarker;
  Set<Marker> _markers = {};
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _initMap();
    _connectSocket();
  }

  void _initMap() {
    _pickup = LatLng(widget.ride['pickup_lat'], widget.ride['pickup_lng']);
    _dropoff = LatLng(widget.ride['dropoff_lat'], widget.ride['dropoff_lng']);
    _markers.addAll([
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickup!,
        infoWindow: const InfoWindow(title: 'Pickup'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId('dropoff'),
        position: _dropoff!,
        infoWindow: const InfoWindow(title: 'Dropoff'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    ]);
  }

  void _connectSocket() {
    SocketService.connect(widget.ride['rider_id'].toString());

    SocketService.socket?.emit('join_ride_room', widget.ride['ride_id']);

    SocketService.socket?.on('driver_position', (data) {
      if (!mounted) return;
      final lat = data['latitude']?.toDouble();
      final lng = data['longitude']?.toDouble();

      if (lat == null || lng == null) return;

      setState(() {
        _driverPos = LatLng(lat, lng);
        _updateDriverMarker(_driverPos!);
      });
    });

    setState(() => _connected = true);
  }

  void _updateDriverMarker(LatLng pos) {
    final marker = Marker(
      markerId: const MarkerId('driver'),
      position: pos,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: 'Driver'),
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'driver');
      _markers.add(marker);
    });

    _controller?.animateCamera(CameraUpdate.newLatLng(pos));
  }

  @override
  void dispose() {
    SocketService.socket?.off('driver_position');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialPos = _pickup ?? const LatLng(0, 0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Driver'),
        backgroundColor: Colors.green.shade700,
      ),
      body: GoogleMap(
        onMapCreated: (c) => _controller = c,
        initialCameraPosition: CameraPosition(target: initialPos, zoom: 13),
        myLocationEnabled: true,
        markers: _markers,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(3.w),
        color: Colors.white,
        child: Text(
          _driverPos == null
              ? 'Waiting for driver to move...'
              : 'Driver Location: ${_driverPos!.latitude.toStringAsFixed(4)}, ${_driverPos!.longitude.toStringAsFixed(4)}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
