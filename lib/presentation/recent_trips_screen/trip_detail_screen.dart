import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class TripDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trip;
  const TripDetailScreen({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rider = trip["rider"] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trip Details"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detail("Pickup", trip["pickup_address"]),
            _detail("Dropoff", trip["dropoff_address"]),
            _detail("Price", "GYD ${trip["price"]}"),
            _detail("Distance", "${trip["distance_km"]} km"),
            _detail("Duration", "${trip["duration_minutes"]} min"),
            _detail("Date",
                trip["created_at"].toString().replaceAll("T", " ").split(".")[0]),
            SizedBox(height: 2.h),
            Divider(),
            SizedBox(height: 2.h),
            Text(
              "Rider Information",
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 1.h),
            _detail("Name", rider["full_name"] ?? "Unknown"),
            _detail("Phone", rider["phone"] ?? "N/A"),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: Colors.grey,
            ),
          ),
          Text(
            value.toString(),
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
