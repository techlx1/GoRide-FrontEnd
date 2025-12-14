import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../edit/vehicle_edit_screen.dart';

class VehicleDetails extends StatelessWidget {
  final Map<String, dynamic>? vehicle;

  const VehicleDetails({Key? key, required this.vehicle}) : super(key: key);

  bool get hasVehicleData {
    if (vehicle == null) return false;

    return vehicle!.containsKey("vehicle_model") &&
        vehicle!["vehicle_model"] != null &&
        vehicle!["vehicle_model"].toString().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (!hasVehicleData) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VehicleEditScreen(vehicleData: {}),
              ),
            );
          },
          child: const Text("Add Vehicle"),
        ),
      );
    }

    final v = vehicle!;
    final model = v['vehicle_model'];
    final plate = v['license_plate'];
    final year = v['vehicle_year'];
    final color = v['vehicle_color'];
    final seats = v['vehicle_seats'].toString();
    final photo = v['vehicle_photo'];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "$model ($plate)",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 1.h),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (photo != null && photo.toString().isNotEmpty)
                ? Image.network(
              photo,
              height: 18.h,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container(
              height: 18.h,
              color: Colors.grey[200],
              child: const Icon(Icons.camera_alt),
            ),
          ),

          SizedBox(height: 1.h),

          Text("Year: $year"),
          Text("Color: $color"),
          Text("Seats: $seats"),

          SizedBox(height: 2.h),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VehicleEditScreen(vehicleData: v),
                ),
              );
            },
            child: const Text("Edit Vehicle"),
          ),
        ],
      ),
    );
  }
}
