import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RideActionButtons extends StatelessWidget {
  final VoidCallback onEmergency;
  final VoidCallback onShareRide;
  final VoidCallback? onCancelRide;
  final bool canCancel;

  const RideActionButtons({
    Key? key,
    required this.onEmergency,
    required this.onShareRide,
    this.onCancelRide,
    this.canCancel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12.h,
      right: 4.w,
      child: Column(
        children: [
          // Emergency Button
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onEmergency,
              icon: CustomIconWidget(
                iconName: 'warning',
                color: Colors.white,
                size: 24,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(height: 2.h),
          // Share Ride Button
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onShareRide,
              icon: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          if (canCancel && onCancelRide != null) ...[
            SizedBox(height: 2.h),
            // Cancel Ride Button
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onCancelRide,
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: Colors.red,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
