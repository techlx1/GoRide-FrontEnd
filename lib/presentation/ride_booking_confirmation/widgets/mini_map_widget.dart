import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MiniMapWidget extends StatefulWidget {
  final Map<String, dynamic> rideDetails;

  const MiniMapWidget({
    Key? key,
    required this.rideDetails,
  }) : super(key: key);

  @override
  State<MiniMapWidget> createState() => _MiniMapWidgetState();
}

class _MiniMapWidgetState extends State<MiniMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMapData();
  }

  void _setupMapData() {
    final pickupLat =
        widget.rideDetails['pickupLatitude'] as double? ?? -6.8014;
    final pickupLng =
        widget.rideDetails['pickupLongitude'] as double? ?? -58.1552;
    final dropoffLat =
        widget.rideDetails['dropoffLatitude'] as double? ?? -6.7834;
    final dropoffLng =
        widget.rideDetails['dropoffLongitude'] as double? ?? -58.1234;

    _markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(pickupLat, pickupLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Pickup Location',
          snippet: widget.rideDetails['pickupAddress'] as String? ??
              'Georgetown, Guyana',
        ),
      ),
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(dropoffLat, dropoffLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: widget.rideDetails['dropoffAddress'] as String? ??
              'Stabroek Market, Georgetown',
        ),
      ),
    };

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [
          LatLng(pickupLat, pickupLng),
          LatLng(dropoffLat, dropoffLng),
        ],
        color: AppTheme.lightTheme.primaryColor,
        width: 3,
        patterns: [],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final pickupLat =
        widget.rideDetails['pickupLatitude'] as double? ?? -6.8014;
    final pickupLng =
        widget.rideDetails['pickupLongitude'] as double? ?? -58.1552;

    return Container(
      width: double.infinity,
      height: 25.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(pickupLat, pickupLng),
            zoom: 13.0,
          ),
          markers: _markers,
          polylines: _polylines,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          mapType: MapType.normal,
          style: '''
            [
              {
                "featureType": "poi",
                "elementType": "labels",
                "stylers": [{"visibility": "off"}]
              }
            ]
          ''',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
