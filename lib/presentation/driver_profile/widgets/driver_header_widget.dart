import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class DriverHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> driverProfile;
  final VoidCallback? onEditPhoto;

  const DriverHeaderWidget({
    Key? key,
    required this.driverProfile,
    this.onEditPhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = driverProfile['name'] ?? 'Driver Name';
    final email = driverProfile['email'] ?? 'driver@email.com';
    final role = driverProfile['role'] ?? 'Driver';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
              if (onEditPhoto != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onEditPhoto,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(name,
              style: GoogleFonts.inter(
                  fontSize: 17.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 0.5.h),
          Text(email,
              style:
              GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[600])),
          SizedBox(height: 0.5.h),
          Text(role,
              style: GoogleFonts.inter(
                  fontSize: 11.sp, color: Colors.blueAccent)),
        ],
      ),
    );
  }
}
