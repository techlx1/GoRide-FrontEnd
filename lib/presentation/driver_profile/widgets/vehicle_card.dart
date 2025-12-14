import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../edit/vehicle_edit_screen.dart';

class VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback? onEditCompleted;

  const VehicleCard({
    Key? key,
    required this.vehicle,
    this.onEditCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = vehicle['model'] ?? 'N/A';
    final plate = vehicle['plate_number'] ?? 'N/A';
    final color = vehicle['color'] ?? 'N/A';
    final seats = vehicle['seats']?.toString() ?? 'N/A';
    final year = vehicle['year'] ?? 'N/A';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Vehicle Details",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 1.h),

            _infoRow("Model:", model),
            _infoRow("Plate:", plate),
            _infoRow("Color:", color),
            _infoRow("Year:", year),
            _infoRow("Seats:", seats),

            SizedBox(height: 2.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VehicleEditScreen(
                        vehicleData: vehicle,
                      ),
                    ),
                  );

                  if (updated == true && onEditCompleted != null) {
                    onEditCompleted!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Edit Vehicle",
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              )),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
