import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';


import '../../services/api/driver_api.dart';
import '../driver_profile/widgets/driver_header_widget.dart';
import '../driver_profile/widgets/driver_vehicle_status_widget.dart';
import '../driver_profile/widgets/driver_documents_widget.dart';
import '../driver_profile/widgets/driver_stats_widget.dart';
import '../driver_profile/widgets/driver_logout_button.dart';

class DriverProfile extends StatefulWidget {
  const DriverProfile({Key? key}) : super(key: key);

  @override
  State<DriverProfile> createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  bool _isLoading = true;
  Map<String, dynamic>? driverProfile;
  Map<String, dynamic>? driverDocs;
  Map<String, dynamic>? driverStats;

  @override
  void initState() {
    super.initState();
    _loadDriverProfile();
  }

  Future<void> _loadDriverProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing token. Please log in again.')),
        );
        return;
      }

      // ✅ Fetch all driver info
      final profileRes = await DriverApi.getDriverProfile(token);
      final docsRes = await DriverApi.getDriverDocuments(token);

      setState(() {
        driverProfile = profileRes['profile'] ?? {};
        driverDocs = docsRes['documents'] ?? {};
        driverStats = profileRes['stats'] ??
            {
              'tripsCompleted': 0,
              'hoursWorked': 0,
              'todayEarnings': 0,
              'averageRating': 0.0,
            };
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error loading driver profile: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Driver Profile'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadDriverProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 Driver header (photo + info)
              DriverHeaderWidget(driverProfile: driverProfile ?? {}),

              SizedBox(height: 2.h),

              // 🚗 Vehicle status
              DriverVehicleStatusWidget(
                driverProfile: driverProfile ?? {},
              ),

              SizedBox(height: 2.h),

              // 📄 Driver documents
              const DriverDocumentsWidget(),

              SizedBox(height: 2.h),

              // 📊 Performance stats
              DriverStatsWidget(stats: driverStats ?? {}),

              SizedBox(height: 3.h),

              // 🔴 Logout button
              Center(child: const DriverLogoutButton()),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
