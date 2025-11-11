import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

/// Displays summarized driver performance stats such as
/// completed trips, working hours, daily earnings, and average rating.
class DriverStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;

  const DriverStatsWidget({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppTheme.lightTheme.colorScheme;

    final trips = stats['tripsCompleted'] ?? 0;
    final hours = stats['hoursWorked'] ?? 0;
    final earnings = stats['todayEarnings'] ?? 0.0;
    final rating = stats['averageRating'] ?? 0.0;

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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Stats',
            style: GoogleFonts.inter(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),

          // Row 1: Trips & Hours
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Trips Completed',
                  '$trips',
                  Icons.local_taxi,
                  Colors.blueAccent,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildStatCard(
                  'Hours Worked',
                  '${hours}h',
                  Icons.timer_outlined,
                  Colors.orangeAccent,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Row 2: Earnings & Rating
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Today Earnings',
                  'GYD ${earnings.toStringAsFixed(0)}',
                  Icons.attach_money_rounded,
                  Colors.green,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildStatCard(
                  'Avg Rating',
                  rating.toStringAsFixed(1),
                  Icons.star_rounded,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Individual card UI for each stat
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.sp, color: color),
          SizedBox(height: 1.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
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
