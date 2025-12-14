import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../services/api/driver_api.dart';
import '../../../utils/toast_helper.dart';

class RecentOrdersScreen extends StatefulWidget {
  const RecentOrdersScreen({Key? key}) : super(key: key);

  @override
  State<RecentOrdersScreen> createState() => _RecentOrdersScreenState();
}

class _RecentOrdersScreenState extends State<RecentOrdersScreen> {
  bool _loading = true;
  List<dynamic> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);

    final res = await DriverApi.getRecentOrders();

    if (res['success'] == true) {
      setState(() {
        _trips = res['rides'] ?? [];
        _loading = false;
      });
    } else {
      ToastHelper.showError(res['message'] ?? "Failed to load recent orders");
      setState(() => _loading = false);
    }
  }

  /* --------------------------------------------------------------
     SHOW TRIP DETAILS — bottom sheet
  -------------------------------------------------------------- */
  void _showTripDetails(Map<String, dynamic> trip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 20.w,
                  height: 0.8.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              Text(
                "Trip Details",
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 2.h),

              _detailRow("Pickup", trip['pickup_address']),
              _detailRow("Dropoff", trip['dropoff_address']),
              _detailRow("Distance", "${trip['distance_km']} km"),
              _detailRow("Duration", "${trip['duration_min']} min"),
              _detailRow("Price", "GYD ${trip['fare_amount']}"),
              _detailRow("Date", trip['created_at']
                  .toString()
                  .replaceAll("T", " ")
                  .split(".")
                  .first),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        children: [
          SizedBox(
            width: 28.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "",
              style: GoogleFonts.inter(fontSize: 11.sp),
            ),
          )
        ],
      ),
    );
  }

  /* --------------------------------------------------------------
     STATUS BADGE
  -------------------------------------------------------------- */
  Widget _statusBadge(String status) {
    Color bg, text;

    switch (status) {
      case "completed":
        bg = Colors.green.withOpacity(0.15);
        text = Colors.green;
        break;

      case "cancelled":
        bg = Colors.red.withOpacity(0.15);
        text = Colors.red;
        break;

      default:
        bg = Colors.orange.withOpacity(0.15);
        text = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  /* --------------------------------------------------------------
     MAIN UI
  -------------------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent Orders"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadTrips,
        child: _trips.isEmpty
            ? Center(
          child: Text(
            "No recent trips yet.",
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: theme.onSurfaceVariant,
            ),
          ),
        )
            : ListView.separated(
          padding: EdgeInsets.all(4.w),
          itemCount: _trips.length,
          separatorBuilder: (_, __) => Divider(),
          itemBuilder: (_, index) {
            final trip = _trips[index];
            return InkWell(
              onTap: () => _showTripDetails(trip),
              child: Row(
                children: [
                  // Icon
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                    Colors.blueAccent.withOpacity(0.1),
                    child: Icon(
                      Icons.local_taxi,
                      size: 22.sp,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(width: 4.w),

                  // Main text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip['pickup_address'] ?? "Unknown pickup",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.6.h),
                        Text(
                          trip['dropoff_address'] ??
                              "Unknown dropoff",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: theme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 2.w),

                  // Fare + status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "GYD ${trip['fare_amount']}",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 0.6.h),
                      _statusBadge(trip['status']),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
