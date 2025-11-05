import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DriverInfoCard extends StatelessWidget {
  final Map<String, dynamic> driverData;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  const DriverInfoCard({
    Key? key,
    required this.driverData,
    required this.onCall,
    required this.onMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.lightTheme.primaryColor,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: driverData["photo"] as String,
                    width: 15.w,
                    height: 15.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverData["name"] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'star',
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          "${driverData["rating"]}",
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "• ${driverData["totalRides"]} rides",
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      "${driverData["vehicleModel"]} • ${driverData["licensePlate"]}",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: onCall,
                      icon: CustomIconWidget(
                        iconName: 'phone',
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: onMessage,
                      icon: CustomIconWidget(
                        iconName: 'message',
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
