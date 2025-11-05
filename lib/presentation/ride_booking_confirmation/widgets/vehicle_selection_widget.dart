import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VehicleSelectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> vehicleTypes;
  final String selectedVehicleId;
  final Function(String) onVehicleSelected;

  const VehicleSelectionWidget({
    Key? key,
    required this.vehicleTypes,
    required this.selectedVehicleId,
    required this.onVehicleSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              'Choose Vehicle Type',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 12.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              itemCount: vehicleTypes.length,
              itemBuilder: (context, index) {
                final vehicle = vehicleTypes[index];
                final isSelected = selectedVehicleId == vehicle['id'];

                return GestureDetector(
                  onTap: () => onVehicleSelected(vehicle['id']),
                  child: Container(
                    width: 20.w,
                    margin: EdgeInsets.only(right: 3.w),
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: AppTheme.lightTheme.colorScheme.shadow,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomImageWidget(
                          imageUrl: vehicle['icon'] as String,
                          width: 8.w,
                          height: 4.h,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          vehicle['name'] as String,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'GY\$${vehicle['price']}',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
