import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../services/api/driver_api.dart';
import '../../utils/toast_helper.dart';
import 'trip_detail_screen.dart';

class RecentTripsScreen extends StatefulWidget {
  const RecentTripsScreen({Key? key}) : super(key: key);

  @override
  State<RecentTripsScreen> createState() => _RecentTripsScreenState();
}

class _RecentTripsScreenState extends State<RecentTripsScreen> {
  bool _loading = true;
  List<dynamic> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);

    final res = await DriverApi.getDriverRecentTrips();
    if (res["success"] == true) {
      setState(() => _trips = res["trips"] ?? []);
    } else {
      ToastHelper.showError(res["message"] ?? "Failed to load trips");
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent Trips"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadTrips,
        child: ListView.separated(
          padding: EdgeInsets.all(5.w),
          itemCount: _trips.length,
          separatorBuilder: (_, __) => SizedBox(height: 2.h),
          itemBuilder: (_, index) {
            final trip = _trips[index];

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripDetailScreen(trip: trip),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: Colors.black12,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      child: Icon(Icons.local_taxi,
                          color: Colors.blueAccent),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${trip['pickup_address']}",
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            trip["dropoff_address"] ?? "",
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              color: theme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            "GYD ${trip['price']}",
                            style: GoogleFonts.inter(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 14.sp, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
