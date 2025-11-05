import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MapWidget extends StatefulWidget {
  final LatLng userLocation;
  final LatLng driverLocation;
  final List<LatLng> routePoints;
  final Function(GoogleMapController) onMapCreated;

  const MapWidget({
    Key? key,
    required this.userLocation,
    required this.driverLocation,
    required this.routePoints,
    required this.onMapCreated,
  }) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
    _createPolylines();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.driverLocation != widget.driverLocation ||
        oldWidget.userLocation != widget.userLocation) {
      _createMarkers();
      _updateCameraPosition();
    }
    if (oldWidget.routePoints != widget.routePoints) {
      _createPolylines();
    }
  }

  void _createMarkers() {
    _markers = {
      Marker(
        markerId: MarkerId('user'),
        position: widget.userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: 'Pickup point',
        ),
      ),
      Marker(
        markerId: MarkerId('driver'),
        position: widget.driverLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Driver',
          snippet: 'On the way',
        ),
      ),
    };
  }

  void _createPolylines() {
    if (widget.routePoints.isNotEmpty) {
      _polylines = {
        Polyline(
          polylineId: PolylineId('route'),
          points: widget.routePoints,
          color: AppTheme.lightTheme.primaryColor,
          width: 4,
          patterns: [],
        ),
      };
    }
  }

  void _updateCameraPosition() {
    if (_mapController != null) {
      LatLngBounds bounds = _calculateBounds();
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    }
  }

  LatLngBounds _calculateBounds() {
    double minLat = widget.userLocation.latitude;
    double maxLat = widget.userLocation.latitude;
    double minLng = widget.userLocation.longitude;
    double maxLng = widget.userLocation.longitude;

    if (widget.driverLocation.latitude < minLat)
      minLat = widget.driverLocation.latitude;
    if (widget.driverLocation.latitude > maxLat)
      maxLat = widget.driverLocation.latitude;
    if (widget.driverLocation.longitude < minLng)
      minLng = widget.driverLocation.longitude;
    if (widget.driverLocation.longitude > maxLng)
      maxLng = widget.driverLocation.longitude;

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          widget.onMapCreated(controller);
          _updateCameraPosition();
        },
        initialCameraPosition: CameraPosition(
          target: widget.userLocation,
          zoom: 15.0,
        ),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: true,
        trafficEnabled: false,
        buildingsEnabled: true,
        indoorViewEnabled: false,
        mapType: MapType.normal,
      ),
    );
  }
}
