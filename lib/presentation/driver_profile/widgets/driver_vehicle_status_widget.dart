import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

/// Displays the driver’s vehicle info and quick status (fuel, mileage, year).
class DriverVehicleStatusWidget extends StatelessWidget {
  final Map<String, dynamic> driverProfile;

  const DriverVehicleStatusWidget({Key? key, required this.driverProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vehicleModel = driverProfile['vehicle_model'] ?? 'Toyota Axio';
    final licensePlate = driverProfile['license_plate'] ?? 'PXX 2345';
    final vehicleYear = driverProfile['vehicle_year'] ?? '2017';
    final fuelLevel = (driverProfile['fuel_level'] ?? 0.65).toDouble();
    final mileage = driverProfile['mileage'] ?? '85,000 km';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(Icons.directions_car, color: Colors.blueAccent, size: 22.sp),
              SizedBox(width: 3.w),
              Text(
                "Vehicle Status",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Vehicle details
          Text(
            "$vehicleModel ($licensePlate)",
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            "Year $vehicleYear",
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 2.h),

          // Fuel progress bar
          Row(
            children: [
              Text(
                "Fuel",
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: fuelLevel.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    color: Colors.blueAccent,
                    minHeight: 0.9.h,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                "${(fuelLevel * 100).toInt()}%",
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.5.h),

          // Mileage
          Row(
            children: [
              const Icon(Icons.speed, color: Colors.orangeAccent, size: 18),
              SizedBox(width: 2.w),
              Text(
                "Mileage: $mileage",
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
