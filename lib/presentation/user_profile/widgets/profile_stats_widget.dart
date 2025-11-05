import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class ProfileStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;

  const ProfileStatsWidget({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppTheme.lightTheme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Stats',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),

          // First Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Rides',
                  '${stats['total_rides'] ?? 0}',
                  Icons.directions_car,
                  colorScheme.primary,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Completed',
                  '${stats['completed_rides'] ?? 0}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Second Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Spent',
                  '\$${(stats['total_spent'] ?? 0.0).toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Avg Rating',
                  '${(stats['average_rating'] ?? 0.0).toStringAsFixed(1)}',
                  Icons.star,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22.sp, color: color),
          SizedBox(height: 1.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
