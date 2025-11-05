import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RideSearchWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const RideSearchWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Search by pickup or destination...',
          hintStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[500],
            size: 20.sp,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[500],
                    size: 20.sp,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }
}