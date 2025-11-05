import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentMethodWidget extends StatelessWidget {
  final Map<String, dynamic> selectedPaymentMethod;
  final VoidCallback onChangePaymentMethod;

  const PaymentMethodWidget({
    Key? key,
    required this.selectedPaymentMethod,
    required this.onChangePaymentMethod,
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
            'Payment Method',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          GestureDetector(
            onTap: onChangePaymentMethod,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: _getPaymentMethodColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: _getPaymentMethodIcon(),
                        color: _getPaymentMethodColor(),
                        size: 6.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedPaymentMethod['name'] as String? ??
                              'Cash Payment',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        if (selectedPaymentMethod['details'] != null) ...[
                          SizedBox(height: 0.5.h),
                          Text(
                            selectedPaymentMethod['details'] as String,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Change',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        CustomIconWidget(
                          iconName: 'keyboard_arrow_right',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 4.w,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodIcon() {
    final type = selectedPaymentMethod['type'] as String? ?? 'cash';
    switch (type) {
      case 'card':
        return 'credit_card';
      case 'mobile_money':
        return 'phone_android';
      case 'cash':
      default:
        return 'payments';
    }
  }

  Color _getPaymentMethodColor() {
    final type = selectedPaymentMethod['type'] as String? ?? 'cash';
    switch (type) {
      case 'card':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'mobile_money':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'cash':
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
