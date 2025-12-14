import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> driverProfile;

  const DriverHeaderWidget({required this.driverProfile, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final photo = driverProfile['photo_url'] ?? "";
    final name = driverProfile['full_name'] ?? "Driver Name";
    final email = driverProfile['email'] ?? "driver@email.com";

    return Column(
      children: [
        SizedBox(height: 2.h),

        // ✔ Avatar
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[300],
          backgroundImage: photo.isNotEmpty
              ? NetworkImage(photo)
              : const AssetImage("assets/images/default_driver.png")
          as ImageProvider,
        ),

        SizedBox(height: 1.5.h),

        // ✔ Centered Name
        Text(
          name,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 0.5.h),

        // ✔ Centered Email
        Text(
          email,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: Colors.grey[600],
          ),
        ),

        SizedBox(height: 2.h),
      ],
    );
  }
}
