import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/driver/driver_service.dart';
import '../../services/driver/driver_earnings_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/toast_helper.dart';
import './widgets/earnings_summary_card.dart';

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
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final profileFuture = DriverService.instance.getDriverProfile(userId);
      final earningsFuture =
      DriverEarningsService.instance.getDriverEarnings(userId);

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
    setState(() => _selectedIndex = index);
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

  // ---------------------------------------------------------------------------
  // DASHBOARD PAGE
  // ---------------------------------------------------------------------------
  Widget _dashboardPage() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _loadDriverData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        // 🔘 Online / Offline Status Card (Modern UI)
        Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ Status Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _isOnline
                        ? Colors.green.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isOnline ? Icons.check_circle : Icons.remove_circle_outline,
                    color: _isOnline ? Colors.green : Colors.grey,
                    size: 26,
                  ),
                ),
                SizedBox(width: 3.w),
                // Text section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isOnline ? "You're Online" : "You're Offline",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: _isOnline ? Colors.black87 : Colors.black54,
                      ),
                    ),
                    Text(
                      _isOnline
                          ? "Working for 2h 15m today"
                          : "Tap to go online and start earning",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 🟦 iOS-style Toggle
            Transform.scale(
              scale: 1.1,
              child: Switch.adaptive(
                value: _isOnline,
                onChanged: (value) async {
                  await _toggleOnlineStatus(value);
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.green,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey[400],
              ),
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

  // ---------------------------------------------------------------------------
  // EARNINGS PAGE (merged from previous design)
  // ---------------------------------------------------------------------------
  Widget _earningsPage() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = _driverEarnings ?? {};

    return RefreshIndicator(
      onRefresh: _loadDriverData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EarningsSummaryCard(earnings: data),
            SizedBox(height: 2.h),
            _buildStatsRow(data),
            SizedBox(height: 3.h),
            Text(
              "Performance Summary",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 1.h),
            _buildTripSummary(data),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem("Trips", data['trips'] ?? 0, Icons.local_taxi),
        _buildStatItem("Rating", data['averageRating'] ?? 0.0, Icons.star),
        _buildStatItem("Hours", data['hoursWorked'] ?? 0, Icons.timer),
      ],
    );
  }

  Widget _buildStatItem(String title, dynamic value, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        child: Padding(
          padding: EdgeInsets.all(2.w),
          child: Column(
            children: [
              Icon(icon, color: Colors.blueAccent),
              SizedBox(height: 1.h),
              Text(
                "$value",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: Colors.black),
              ),
              Text(title,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripSummary(Map<String, dynamic> data) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today, color: Colors.blue),
          title: const Text("Weekly Trips"),
          trailing: Text(
            "${data['weeklyTrips'] ?? 0}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.attach_money, color: Colors.green),
          title: const Text("Weekly Earnings"),
          trailing: Text(
            "G\$${(data['weeklyEarnings'] ?? 0).toStringAsFixed(0)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PROFILE PAGE
  // ---------------------------------------------------------------------------
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
              style:
              TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN SCAFFOLD
  // ---------------------------------------------------------------------------
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
