import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../services/ride_service.dart';
import './widgets/active_ride_widget.dart';
import './widgets/app_drawer_widget.dart';
import './widgets/location_search_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/ride_type_selector_widget.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({Key? key}) : super(key: key);

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  final RideService _rideService = RideService();

  // Map and location state
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // UI state
  bool _isLoading = true;
  bool _isLocationPermissionGranted = false;
  int _selectedTabIndex = 0;
  TabController? _tabController;

  // Ride state
  Map<String, dynamic>? _activeRide;
  List<Map<String, dynamic>> _nearbyDrivers = [];

  // Search state
  String? _selectedPickupAddress;
  String? _selectedDestinationAddress;
  LatLng? _selectedPickupLocation;
  LatLng? _selectedDestinationLocation;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(6.8013, -58.1551), // Georgetown, Guyana
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeScreen();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    await _requestLocationPermission();
    await _getCurrentLocation();
    await _loadActiveRide();
    await _loadNearbyDrivers();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _requestLocationPermission() async {
    final permission = await Permission.location.request();
    setState(() {
      _isLocationPermissionGranted = permission.isGranted;
    });
  }

  Future<void> _getCurrentLocation() async {
    if (!_isLocationPermissionGranted) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Update map camera to current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }

      // Add current location marker
      _updateCurrentLocationMarker();
    } catch (error) {
      debugPrint('Error getting location: $error');
    }
  }

  void _updateCurrentLocationMarker() {
    if (_currentPosition == null) return;

    setState(() {
      _markers
          .removeWhere((marker) => marker.markerId.value == 'current_location');
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    });
  }

  Future<void> _loadActiveRide() async {
    try {
      final activeRide = await _rideService.getActiveRide();
      setState(() {
        _activeRide = activeRide;
      });

      if (activeRide != null) {
        _addRideMarkers(activeRide);
      }
    } catch (error) {
      debugPrint('Error loading active ride: $error');
    }
  }

  Future<void> _loadNearbyDrivers() async {
    if (_currentPosition == null) return;

    try {
      final drivers = await _rideService.getNearbyDrivers(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
      );

      setState(() {
        _nearbyDrivers = drivers;
      });

      _addDriverMarkers(drivers);
    } catch (error) {
      debugPrint('Error loading nearby drivers: $error');
    }
  }

  void _addDriverMarkers(List<Map<String, dynamic>> drivers) {
    setState(() {
      // Remove existing driver markers
      _markers
          .removeWhere((marker) => marker.markerId.value.startsWith('driver_'));

      // Add new driver markers
      for (final driver in drivers) {
        final lat = driver['current_latitude'] as double?;
        final lng = driver['current_longitude'] as double?;

        if (lat != null && lng != null) {
          _markers.add(
            Marker(
              markerId: MarkerId('driver_${driver['id']}'),
              position: LatLng(lat, lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
              infoWindow: InfoWindow(
                title:
                    '${driver['vehicle_model']} - ${driver['vehicle_color']}',
                snippet: 'Rating: ${driver['rating'] ?? 0.0}',
              ),
            ),
          );
        }
      }
    });
  }

  void _addRideMarkers(Map<String, dynamic> ride) {
    setState(() {
      // Add pickup marker
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(
            ride['pickup_latitude'] as double,
            ride['pickup_longitude'] as double,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: 'Pickup: ${ride['pickup_address']}'),
        ),
      );

      // Add destination marker
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(
            ride['destination_latitude'] as double,
            ride['destination_longitude'] as double,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow:
              InfoWindow(title: 'Destination: ${ride['destination_address']}'),
        ),
      );
    });
  }

  void _onPickupLocationSelected(String address, LatLng location) {
    setState(() {
      _selectedPickupAddress = address;
      _selectedPickupLocation = location;
    });
  }

  void _onDestinationLocationSelected(String address, LatLng location) {
    setState(() {
      _selectedDestinationAddress = address;
      _selectedDestinationLocation = location;
    });
  }

  void _onRideTypeSelected(String vehicleType) {
    if (_selectedPickupLocation != null &&
        _selectedDestinationLocation != null) {
      _requestRide(vehicleType);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select pickup and destination locations')),
      );
    }
  }

  Future<void> _requestRide(String vehicleType) async {
    if (_selectedPickupLocation == null ||
        _selectedDestinationLocation == null) {
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final ride = await _rideService.requestRide(
        pickupLatitude: _selectedPickupLocation!.latitude,
        pickupLongitude: _selectedPickupLocation!.longitude,
        pickupAddress: _selectedPickupAddress ?? 'Selected Location',
        destinationLatitude: _selectedDestinationLocation!.latitude,
        destinationLongitude: _selectedDestinationLocation!.longitude,
        destinationAddress:
            _selectedDestinationAddress ?? 'Selected Destination',
        vehicleType: vehicleType,
      );

      Navigator.pop(context); // Close loading dialog

      setState(() {
        _activeRide = ride;
      });

      _addRideMarkers(ride);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride requested successfully!')),
      );
    } catch (error) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting ride: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
      ),
      drawer: const AppDrawerWidget(),
      body: Column(
        children: [
          // Location Search Bar
          LocationSearchWidget(
            onPickupLocationSelected: _onPickupLocationSelected,
            onDestinationLocationSelected: _onDestinationLocationSelected,
          ),

          // Map Container
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    if (_currentPosition != null) {
                      controller.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(_currentPosition!.latitude,
                              _currentPosition!.longitude),
                        ),
                      );
                    }
                  },
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: _isLocationPermissionGranted,
                  myLocationButtonEnabled: true,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                  onTap: (LatLng location) {
                    // Handle map tap for location selection
                  },
                ),

                // Active Ride Widget Overlay
                if (_activeRide != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: ActiveRideWidget(
                      rideData: _activeRide!,
                      onCancelRide: () async {
                        await _rideService.cancelRide(_activeRide!['id']);
                        setState(() {
                          _activeRide = null;
                        });
                        await _loadNearbyDrivers();
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Panel
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.w),
                  topRight: Radius.circular(20.w),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.w,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25.w),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Home'),
                        Tab(text: 'Activity'),
                        Tab(text: 'Saved'),
                        Tab(text: 'Account'),
                      ],
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[600],
                      indicator: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(25.w),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Home Tab
                        Column(
                          children: [
                            QuickActionsWidget(
                              currentLocation: _currentPosition,
                              onLocationSelected:
                                  _onDestinationLocationSelected,
                            ),
                            SizedBox(height: 16.h),
                            if (_activeRide == null)
                              RideTypeSelectorWidget(
                                onRideTypeSelected: _onRideTypeSelected,
                                pickupLocation: _selectedPickupLocation,
                                destinationLocation:
                                    _selectedDestinationLocation,
                              ),
                          ],
                        ),

                        // Activity Tab
                        Center(
                          child: Text(
                            'Recent rides will appear here',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16.sp,
                            ),
                          ),
                        ),

                        // Saved Tab
                        Center(
                          child: Text(
                            'Saved locations will appear here',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16.sp,
                            ),
                          ),
                        ),

                        // Account Tab
                        Center(
                          child: Text(
                            'Account settings will appear here',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _activeRide == null
          ? FloatingActionButton.extended(
              onPressed: () {
                // Navigate to ride booking screens
                Navigator.pushNamed(context, '/ride-booking-confirmation');
              },
              backgroundColor: Theme.of(context).primaryColor,
              icon: const Icon(Icons.local_taxi),
              label: const Text('Book Ride'),
            )
          : null,
    );
  }
}
