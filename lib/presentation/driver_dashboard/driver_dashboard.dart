import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';

// API
import '../../services/api/driver_api.dart';

// Screens
import '../driver_profile/driver_profile.dart';
import '../notifications/notifications_screen.dart';

// Providers
import '../../providers/driver_providers.dart';
import '../../providers/location_providers.dart';
import '../../providers/trip_radar_providers.dart';
import '../../providers/auth_providers.dart';

// Services
import '../../services/socket_service.dart';

// Widgets
import 'widgets/trip_radar_panel.dart';
import 'widgets/online_status_toggle.dart';

class DriverDashboard extends ConsumerStatefulWidget {
  const DriverDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends ConsumerState<DriverDashboard> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _locationSub;

  LatLng? _lastLatLng;
  double _lastHeading = 0.0;

  Set<Marker> _markers = {};
  BitmapDescriptor? driverMarkerIcon;

  static const LatLng defaultLocation = LatLng(6.8013, -58.1551);

  // 🔔 Notifications
  int _unreadCount = 0;
  bool _isFetchingNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadDriverMarker();
    _initSocket(ref);
    _getInitialLocation();
    _subscribeToLocation();
    _fetchUnreadNotifications();
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    SocketService().disconnect();
    super.dispose();
  }

  // ------------------------------------------------------------
  // INITIAL LOCATION
  // ------------------------------------------------------------
  Future<void> _getInitialLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) await Geolocator.openLocationSettings();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _lastLatLng = LatLng(pos.latitude, pos.longitude);

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_lastLatLng!, 17),
    );
  }

  // ------------------------------------------------------------
  // LOAD MARKER ICON
  // ------------------------------------------------------------
  Future<void> _loadDriverMarker() async {
    driverMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/car_topq.png',
    );
    setState(() {});
  }

  // ------------------------------------------------------------
  // INIT SOCKET (WITH DRIVER ID)
  // ------------------------------------------------------------
  void _initSocket(WidgetRef ref) {
    final driverId = ref.read(driverIdProvider);
    if (driverId == null) {
      print("❌ driverId missing, cannot open socket");
      return;
    }

    SocketService().connect(driverId);

    // Listen for real-time notifications
    SocketService().onNotificationReceived = (data) {
      print("🔔 REAL-TIME NOTIFICATION: $data");
      _fetchUnreadNotifications(); // update badge instantly
    };
  }

  // ------------------------------------------------------------
  // SUBSCRIBE TO GPS LOCATION
  // ------------------------------------------------------------
  void _subscribeToLocation() {
    _locationSub = ref.read(liveLocationProvider.stream).listen((pos) {
      final driverId = ref.read(driverIdProvider);

      if (driverId != null) {
        SocketService().emitDriverLocation(
          driverId: driverId,
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
      }

      _lastHeading = pos.heading;
      _animateMarker(LatLng(pos.latitude, pos.longitude));
    });
  }

  // ------------------------------------------------------------
  // NOTIFICATION BADGE
  // ------------------------------------------------------------
  Future<void> _fetchUnreadNotifications() async {
    try {
      if (_isFetchingNotifications) return;
      setState(() => _isFetchingNotifications = true);

      final result = await DriverApi.getUnreadNotifications();

      if (result["success"] == true) {
        setState(() {
          _unreadCount = result["unreadCount"] ?? 0;
        });
      }
    } catch (e) {
      print("Unread notifications error: $e");
    } finally {
      if (mounted) {
        setState(() => _isFetchingNotifications = false);
      }
    }
  }


  // ------------------------------------------------------------
  // SMOOTH MARKER ANIMATION
  // ------------------------------------------------------------
  void _animateMarker(LatLng newPos) {
    if (driverMarkerIcon == null) return;

    _lastLatLng ??= newPos;

    const animationDuration = Duration(milliseconds: 900);
    const tick = Duration(milliseconds: 16);
    int elapsed = 0;

    final start = _lastLatLng!;
    final end = newPos;

    Timer.periodic(tick, (timer) {
      elapsed += tick.inMilliseconds;

      double t = elapsed / animationDuration.inMilliseconds;
      if (t > 1) t = 1;

      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lng = start.longitude + (end.longitude - start.longitude) * t;

      final animatedPos = LatLng(lat, lng);

      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId("driver"),
            position: animatedPos,
            rotation: _lastHeading,
            flat: true,
            anchor: const Offset(0.5, 0.5),
            icon: driverMarkerIcon!,
          ),
        };
      });

      if (t == 1) {
        timer.cancel();
        _lastLatLng = newPos;
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(animatedPos),
        );
      }
    });
  }

  // ------------------------------------------------------------
  // BUILD UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(driverOnlineProvider);
    final locationAsync = ref.watch(liveLocationProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildMap(locationAsync),
          _buildMenuButton(context),
          _buildNotificationsButton(context),
          _buildCenterButton(),
          _buildTripRadarButton(),
          const TripRadarPanel(),

          Positioned(
            left: 0,
            right: 0,
            bottom: 25,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: OnlineStatusToggle(
                isOnline: isOnline,
                workingHours: "2h 15m",
                onToggle: () {
                  ref.read(driverOnlineProvider.notifier).state = !isOnline;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MAP WIDGET
  // ------------------------------------------------------------
  Widget _buildMap(AsyncValue<Position> locationAsync) {
    return locationAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      error: (_, __) => const Center(
        child: Text("Unable to get location",
            style: TextStyle(color: Colors.white)),
      ),
      data: (pos) {
        final actual = LatLng(pos.latitude, pos.longitude);

        return GoogleMap(
          initialCameraPosition: CameraPosition(target: actual, zoom: 16),
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          markers: _markers,
          onMapCreated: (controller) {
            _mapController = controller;
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(actual, 17),
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // MENU BUTTON
  // ------------------------------------------------------------
  Widget _buildMenuButton(BuildContext context) {
    return Positioned(
      top: 50,
      left: 18,
      child: _roundButton(
        icon: Icons.menu,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DriverProfile()),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // NOTIFICATION BUTTON
  // ------------------------------------------------------------
  Widget _buildNotificationsButton(BuildContext context) {
    return Positioned(
      top: 50,
      right: 80,
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
          _fetchUnreadNotifications();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications, color: Colors.black),
            ),
            if (_unreadCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _unreadCount > 9 ? '9+' : '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CENTER MAP BUTTON
  // ------------------------------------------------------------
  Widget _buildCenterButton() {
    return Positioned(
      top: 50,
      right: 18,
      child: _roundButton(
        icon: Icons.my_location,
        onTap: () {
          final target = _lastLatLng ?? defaultLocation;
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(target, 17),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // TRIP RADAR BUTTON
  // ------------------------------------------------------------
  Widget _buildTripRadarButton() {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: () => ref.read(showTripRadarProvider.notifier).state = true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.radar, size: 20, color: Colors.black),
                SizedBox(width: 6),
                Text(
                  'Trip Radar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ROUND BUTTON
  // ------------------------------------------------------------
  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 28, color: Colors.black),
      ),
    );
  }
}
