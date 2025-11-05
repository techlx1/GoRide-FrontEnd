import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RideFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final String selectedSort;
  final Function(String) onFilterChanged;
  final Function(String) onSortChanged;

  const RideFilterWidget({
    Key? key,
    required this.selectedFilter,
    required this.selectedSort,
    required this.onFilterChanged,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Filter Dropdown
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilter,
                icon: Icon(Icons.keyboard_arrow_down, size: 20.sp),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'all',
                    child: Row(
                      children: [
                        Icon(Icons.list, size: 16.sp, color: Colors.grey[600]),
                        SizedBox(width: 8.w),
                        const Text('All Rides'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'completed',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 16.sp, color: Colors.green),
                        SizedBox(width: 8.w),
                        const Text('Completed'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, size: 16.sp, color: Colors.red),
                        SizedBox(width: 8.w),
                        const Text('Cancelled'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'in_progress',
                    child: Row(
                      children: [
                        Icon(Icons.directions_car,
                            size: 16.sp, color: Colors.blue),
                        SizedBox(width: 8.w),
                        const Text('In Progress'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onFilterChanged(value);
                  }
                },
              ),
            ),
          ),
        ),

        SizedBox(width: 12.w),

        // Sort Dropdown
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSort,
                icon: Icon(Icons.keyboard_arrow_down, size: 20.sp),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'newest',
                    child: Row(
                      children: [
                        Icon(Icons.schedule,
                            size: 16.sp, color: Colors.grey[600]),
                        SizedBox(width: 8.w),
                        const Text('Newest First'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'oldest',
                    child: Row(
                      children: [
                        Icon(Icons.history,
                            size: 16.sp, color: Colors.grey[600]),
                        SizedBox(width: 8.w),
                        const Text('Oldest First'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'highest_fare',
                    child: Row(
                      children: [
                        Icon(Icons.trending_up,
                            size: 16.sp, color: Colors.green),
                        SizedBox(width: 8.w),
                        const Text('Highest Fare'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'lowest_fare',
                    child: Row(
                      children: [
                        Icon(Icons.trending_down,
                            size: 16.sp, color: Colors.orange),
                        SizedBox(width: 8.w),
                        const Text('Lowest Fare'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onSortChanged(value);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}