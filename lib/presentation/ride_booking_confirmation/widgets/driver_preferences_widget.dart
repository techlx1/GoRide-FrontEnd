import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DriverPreferencesWidget extends StatelessWidget {
  final bool femaleDriverPreference;
  final bool accessibilityRequired;
  final Function(bool) onFemaleDriverToggle;
  final Function(bool) onAccessibilityToggle;

  const DriverPreferencesWidget({
    Key? key,
    required this.femaleDriverPreference,
    required this.accessibilityRequired,
    required this.onFemaleDriverToggle,
    required this.onAccessibilityToggle,
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
          Text(
            'Driver Preferences',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildPreferenceItem(
            icon: 'person',
            title: 'Female Driver',
            subtitle: 'Request a female driver when available',
            value: femaleDriverPreference,
            onChanged: onFemaleDriverToggle,
            iconColor: AppTheme.lightTheme.colorScheme.secondary,
          ),
          SizedBox(height: 2.h),
          _buildPreferenceItem(
            icon: 'accessible',
            title: 'Accessibility Support',
            subtitle: 'Vehicle with wheelchair accessibility',
            value: accessibilityRequired,
            onChanged: onAccessibilityToggle,
            iconColor: AppTheme.lightTheme.colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: value ? iconColor.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? iconColor.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: iconColor,
                size: 5.w,
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
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: iconColor,
            activeTrackColor: iconColor.withValues(alpha: 0.3),
            inactiveThumbColor:
                AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            inactiveTrackColor:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
