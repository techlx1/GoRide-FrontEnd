import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

/// Displays the driver’s key document statuses:
/// Fitness Certificate, Insurance, and Driver Licence.
class DriverDocumentsWidget extends StatelessWidget {
  final Map<String, dynamic>? documents;

  const DriverDocumentsWidget({Key? key, this.documents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final docs = documents ?? {
      'fitness': {'status': 'valid', 'expiry': '2026-01-12'},
      'insurance': {'status': 'expiring', 'expiry': '2025-12-10'},
      'licence': {'status': 'expired', 'expiry': '2025-10-30'},
    };

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Driver Document Status",
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 1.5.h),

          _buildDocStatusRow(
            "Fitness Certificate",
            docs['fitness']?['expiry'] ?? 'Unknown',
            docs['fitness']?['status'] ?? 'pending',
          ),
          _buildDocStatusRow(
            "Insurance",
            docs['insurance']?['expiry'] ?? 'Unknown',
            docs['insurance']?['status'] ?? 'pending',
          ),
          _buildDocStatusRow(
            "Driver Licence",
            docs['licence']?['expiry'] ?? 'Unknown',
            docs['licence']?['status'] ?? 'pending',
          ),
        ],
      ),
    );
  }

  /// Builds a color-coded row for each document
  Widget _buildDocStatusRow(String title, String expiry, String status) {
    IconData icon;
    Color color;
    String subtitle;

    switch (status.toLowerCase()) {
      case 'valid':
        icon = Icons.check_circle;
        color = Colors.green;
        subtitle = "Valid until $expiry";
        break;
      case 'expiring':
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        subtitle = "Expiring soon $expiry";
        break;
      case 'expired':
        icon = Icons.cancel_rounded;
        color = Colors.red;
        subtitle = "Expired $expiry";
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
        subtitle = "Status unknown";
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
