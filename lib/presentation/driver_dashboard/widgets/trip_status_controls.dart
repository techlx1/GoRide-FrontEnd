import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TripStatusControls extends StatelessWidget {
  final String currentStatus;
  final Map<String, dynamic>? activeTrip;
  final Function(String) onStatusUpdate;
  final VoidCallback onEmergency;

  const TripStatusControls({
    Key? key,
    required this.currentStatus,
    this.activeTrip,
    required this.onStatusUpdate,
    required this.onEmergency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activeTrip == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
          // Trip info header
          Row(
            children: [
              CircleAvatar(
                radius: 5.w,
                backgroundImage: NetworkImage(
                  activeTrip!['passengerAvatar'] as String,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeTrip!['passengerName'] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Trip ID: ${activeTrip!['tripId']}",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(currentStatus).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(currentStatus),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(currentStatus),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Current destination
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: currentStatus == 'heading_to_pickup'
                      ? 'location_on'
                      : 'flag',
                  color: currentStatus == 'heading_to_pickup'
                      ? AppTheme.lightTheme.colorScheme.primary
                      : Colors.red,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentStatus == 'heading_to_pickup'
                            ? "Pickup Location"
                            : "Drop-off Location",
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        currentStatus == 'heading_to_pickup'
                            ? activeTrip!['pickupLocation'] as String
                            : activeTrip!['dropoffLocation'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Action buttons
          Row(
            children: [
              // Emergency button
              Expanded(
                child: OutlinedButton(
                  onPressed: onEmergency,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'emergency',
                        color: Colors.red,
                        size: 18,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        "Emergency",
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 3.w),

              // Primary action button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _handlePrimaryAction(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _getPrimaryActionText(currentStatus),
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Navigation button (when heading to pickup/dropoff)
          if (currentStatus == 'heading_to_pickup' ||
              currentStatus == 'in_trip') ...[
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _openNavigation(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                  side: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.primary),
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'navigation',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "Open Navigation",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handlePrimaryAction() {
    switch (currentStatus) {
      case 'heading_to_pickup':
        onStatusUpdate('arrived_at_pickup');
        break;
      case 'arrived_at_pickup':
        onStatusUpdate('in_trip');
        break;
      case 'in_trip':
        onStatusUpdate('completed');
        break;
    }
  }

  void _openNavigation() {
    // This would typically open the device's navigation app
    // For now, we'll just show a toast
  }

  String _getPrimaryActionText(String status) {
    switch (status) {
      case 'heading_to_pickup':
        return 'Arrived at Pickup';
      case 'arrived_at_pickup':
        return 'Start Trip';
      case 'in_trip':
        return 'Complete Trip';
      default:
        return 'Update Status';
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'heading_to_pickup':
        return 'Heading to Pickup';
      case 'arrived_at_pickup':
        return 'Arrived';
      case 'in_trip':
        return 'In Trip';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'heading_to_pickup':
        return Colors.orange;
      case 'arrived_at_pickup':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'in_trip':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }
}
