import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/driver/driver_service.dart';
import '../../utils/toast_helper.dart';
import './widgets/earnings_summary_card.dart';
import '../../theme/app_theme.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({Key? key}) : super(key: key);

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  bool _isOnline = false;
  bool _isLoading = true;
  Map<String, dynamic>? _driverProfile;
  Map<String, dynamic>? _driverEarnings;
  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(6.8013, -58.1551);

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        ToastHelper.showError('Missing user session. Please log in again.');
        return;
      }

      final profileFuture = DriverService.instance.getDriverProfile(userId);
      final earningsFuture = DriverService.instance.getDriverEarnings(userId);

      final results = await Future.wait([profileFuture, earningsFuture]);

      setState(() {
        _driverProfile = results[0] as Map<String, dynamic>?;
        _driverEarnings = results[1] as Map<String, dynamic>?;
        _isOnline = _driverProfile?['is_online'] ?? false;
      });
    } catch (e) {
      ToastHelper.showError('Failed to load driver data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onBottomNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _toggleOnlineStatus(bool value) async {
    setState(() => _isOnline = value);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId != null) {
      await DriverService.instance.updateOnlineStatus(userId, value);
      ToastHelper.showSuccess(
        value
            ? "You're Online 🚗 — Ready for rides!"
            : "You're Offline 💤 — Take a break!",
      );
    }
  }

  // --- Pages ---

  Widget _dashboardPage() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDriverData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔘 Online / Offline Toggle
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _isOnline ? Colors.green : Colors.grey,
                        radius: 4.w,
                      ),
                      SizedBox(width: 3.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOnline ? "You're Online" : "You're Offline",
                            style: AppTheme.lightTheme.textTheme.titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _isOnline
                                ? "Tap to go offline"
                                : "Tap to go online and start earning",
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: _isOnline,
                    onChanged: _toggleOnlineStatus,
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // 💰 Earnings Summary
            if (_driverEarnings != null)
              EarningsSummaryCard(earnings: _driverEarnings!),

            SizedBox(height: 2.h),

            // 🗺️ Google Map
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 40.h,
                child: GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 13.0,
                  ),
                  markers: _buildDriverMarkers(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Set<Marker> _buildDriverMarkers() {
    return {
      Marker(
        markerId: const MarkerId('driver'),
        position: _center,
        infoWindow: const InfoWindow(title: 'You'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
      ),
    };
  }

  Widget _earningsPage() {
    return RefreshIndicator(
      onRefresh: _loadDriverData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: _driverEarnings != null
            ? Column(
          children: [
            EarningsSummaryCard(earnings: _driverEarnings!),
            SizedBox(height: 3.h),
            Text(
              "Recent Trips",
              style: AppTheme.lightTheme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "Detailed trip earnings history coming soon...",
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ],
        )
            : const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No earnings data available."),
          ),
        ),
      ),
    );
  }

  Widget _profilePage() {
    if (_driverProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 12.w,
            backgroundColor: Colors.blueAccent.withOpacity(0.2),
            child: const Icon(Icons.person, size: 50, color: Colors.blueAccent),
          ),
          SizedBox(height: 2.h),
          Text(
            _driverProfile?['full_name'] ?? "Unknown Driver",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _driverProfile?['email'] ?? _driverProfile?['phone'] ?? "",
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 3.h),

          // Vehicle Info
          Container(
            padding: EdgeInsets.all(4.w),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Vehicle Details",
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                _buildInfoRow("Model", _driverProfile?['vehicle_model'] ?? "-"),
                _buildInfoRow(
                    "License Plate", _driverProfile?['license_plate'] ?? "-"),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Logout
          ElevatedButton.icon(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 10.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey[700], fontSize: 12.sp)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13.sp)),
        ],
      ),
    );
  }

  // --- Main Scaffold ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RideGuyana Driver"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          _dashboardPage(),
          _earningsPage(),
          _profilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Earnings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
