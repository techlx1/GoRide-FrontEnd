import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class EarningsSummaryCard extends StatelessWidget {
  final Map<String, dynamic> earnings;

  const EarningsSummaryCard({Key? key, required this.earnings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = (earnings['today'] ?? 0).toDouble();
    final week = (earnings['week'] ?? 0).toDouble();
    final month = (earnings['month'] ?? 0).toDouble();
    final total = (earnings['total'] ?? 0).toDouble();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Earnings Summary",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat("Today", "G\$${today.toStringAsFixed(0)}"),
              _buildStat("Week", "G\$${week.toStringAsFixed(0)}"),
              _buildStat("Month", "G\$${month.toStringAsFixed(0)}"),
              _buildStat("Total", "G\$${total.toStringAsFixed(0)}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
