import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VehicleStatusWidget extends StatelessWidget {
  final Map<String, dynamic> vehicleData;

  const VehicleStatusWidget({
    Key? key,
    required this.vehicleData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Vehicle Status",
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_hasAlerts())
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${_getAlertCount()} Alert${_getAlertCount() > 1 ? 's' : ''}",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 2.h),

          // Vehicle info
          Row(
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'directions_car',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 32,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${vehicleData['make']} ${vehicleData['model']}",
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "License: ${vehicleData['licensePlate']}",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      "Year: ${vehicleData['year']}",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Status indicators
          Row(
            children: [
              Expanded(
                child: _buildStatusIndicator(
                  "Fuel Level",
                  "${vehicleData['fuelLevel']}%",
                  'local_gas_station',
                  _getFuelColor(vehicleData['fuelLevel'] as int),
                ),
              ),
              Expanded(
                child: _buildStatusIndicator(
                  "Mileage",
                  "${vehicleData['mileage']} km",
                  'speed',
                  AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Document status
          if (vehicleData['documents'] != null) ...[
            Text(
              "Document Status",
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            ..._buildDocumentList(vehicleData['documents'] as List),
          ],

          // Maintenance reminders
          if (vehicleData['maintenanceReminders'] != null &&
              (vehicleData['maintenanceReminders'] as List).isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              "Maintenance Reminders",
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            ..._buildMaintenanceList(
                vehicleData['maintenanceReminders'] as List),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(
      String label, String value, String iconName, Color color) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: color,
          size: 24,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDocumentList(List documents) {
    return (documents as List<Map<String, dynamic>>).map((doc) {
      final isExpiringSoon = _isExpiringSoon(doc['expiryDate'] as String);
      final isExpired = _isExpired(doc['expiryDate'] as String);

      return Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isExpired
              ? Colors.red.withValues(alpha: 0.1)
              : isExpiringSoon
                  ? Colors.orange.withValues(alpha: 0.1)
                  : Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isExpired
                ? Colors.red.withValues(alpha: 0.3)
                : isExpiringSoon
                    ? Colors.orange.withValues(alpha: 0.3)
                    : Colors.green.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: _getDocumentIcon(doc['type'] as String),
              color: isExpired
                  ? Colors.red
                  : isExpiringSoon
                      ? Colors.orange
                      : Colors.green,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc['name'] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Expires: ${doc['expiryDate']}",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: isExpired
                          ? Colors.red
                          : isExpiringSoon
                              ? Colors.orange
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isExpired || isExpiringSoon)
              CustomIconWidget(
                iconName: 'warning',
                color: isExpired ? Colors.red : Colors.orange,
                size: 20,
              ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildMaintenanceList(List reminders) {
    return (reminders as List<Map<String, dynamic>>).map((reminder) {
      return Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.blue.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'build',
              color: Colors.blue,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder['type'] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Due: ${reminder['dueDate']}",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getFuelColor(int fuelLevel) {
    if (fuelLevel <= 20) return Colors.red;
    if (fuelLevel <= 40) return Colors.orange;
    return Colors.green;
  }

  String _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'license':
        return 'credit_card';
      case 'insurance':
        return 'security';
      case 'registration':
        return 'description';
      default:
        return 'article';
    }
  }

  bool _isExpiringSoon(String expiryDate) {
    try {
      final expiry = DateTime.parse(expiryDate);
      final now = DateTime.now();
      final difference = expiry.difference(now).inDays;
      return difference <= 30 && difference > 0;
    } catch (e) {
      return false;
    }
  }

  bool _isExpired(String expiryDate) {
    try {
      final expiry = DateTime.parse(expiryDate);
      final now = DateTime.now();
      return expiry.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  bool _hasAlerts() {
    int alertCount = 0;

    // Check fuel level
    if ((vehicleData['fuelLevel'] as int) <= 20) alertCount++;

    // Check documents
    if (vehicleData['documents'] != null) {
      for (var doc in vehicleData['documents'] as List) {
        final docMap = doc as Map<String, dynamic>;
        if (_isExpired(docMap['expiryDate'] as String) ||
            _isExpiringSoon(docMap['expiryDate'] as String)) {
          alertCount++;
        }
      }
    }

    return alertCount > 0;
  }

  int _getAlertCount() {
    int alertCount = 0;

    // Check fuel level
    if ((vehicleData['fuelLevel'] as int) <= 20) alertCount++;

    // Check documents
    if (vehicleData['documents'] != null) {
      for (var doc in vehicleData['documents'] as List) {
        final docMap = doc as Map<String, dynamic>;
        if (_isExpired(docMap['expiryDate'] as String) ||
            _isExpiringSoon(docMap['expiryDate'] as String)) {
          alertCount++;
        }
      }
    }

    return alertCount;
  }
}
