import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RideSummaryCardWidget extends StatelessWidget {
  final Map<String, dynamic> rideDetails;
  final VoidCallback onEditPickup;
  final VoidCallback onEditDestination;

  const RideSummaryCardWidget({
    Key? key,
    required this.rideDetails,
    required this.onEditPickup,
    required this.onEditDestination,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ride Summary',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildLocationRow(
            icon: 'radio_button_checked',
            iconColor: AppTheme.lightTheme.colorScheme.tertiary,
            title: 'Pickup',
            address:
                rideDetails['pickupAddress'] as String? ?? 'Georgetown, Guyana',
            onEdit: onEditPickup,
          ),
          SizedBox(height: 1.5.h),
          _buildLocationRow(
            icon: 'location_on',
            iconColor: AppTheme.lightTheme.colorScheme.error,
            title: 'Destination',
            address: rideDetails['dropoffAddress'] as String? ??
                'Stabroek Market, Georgetown',
            onEdit: onEditDestination,
          ),
          SizedBox(height: 2.h),
          Divider(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            thickness: 1,
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: 'schedule',
                  label: 'Duration',
                  value: '${rideDetails['estimatedDuration'] ?? 15} min',
                ),
              ),
              Container(
                width: 1,
                height: 4.h,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: 'straighten',
                  label: 'Distance',
                  value: '${rideDetails['estimatedDistance'] ?? 8.5} km',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required String icon,
    required Color iconColor,
    required String title,
    required String address,
    required VoidCallback onEdit,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: iconColor,
              size: 4.w,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.5.h),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Text(
                    address,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 2.w),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: CustomIconWidget(
              iconName: 'edit',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 5.w,
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
