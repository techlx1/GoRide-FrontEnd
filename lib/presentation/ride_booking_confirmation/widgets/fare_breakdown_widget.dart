import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FareBreakdownWidget extends StatefulWidget {
  final Map<String, dynamic> fareDetails;

  const FareBreakdownWidget({
    Key? key,
    required this.fareDetails,
  }) : super(key: key);

  @override
  State<FareBreakdownWidget> createState() => _FareBreakdownWidgetState();
}

class _FareBreakdownWidgetState extends State<FareBreakdownWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final baseFare = widget.fareDetails['baseFare'] as double? ?? 500.0;
    final distanceCharge =
        widget.fareDetails['distanceCharge'] as double? ?? 150.0;
    final timeCharge = widget.fareDetails['timeCharge'] as double? ?? 75.0;
    final surgeMultiplier =
        widget.fareDetails['surgeMultiplier'] as double? ?? 1.0;
    final discount = widget.fareDetails['discount'] as double? ?? 0.0;

    final subtotal = baseFare + distanceCharge + timeCharge;
    final surgeAmount = subtotal * (surgeMultiplier - 1);
    final totalFare = (subtotal + surgeAmount) - discount;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fare Breakdown',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Total: GY\$${totalFare.toStringAsFixed(2)}',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? _buildExpandedContent(
                    baseFare: baseFare,
                    distanceCharge: distanceCharge,
                    timeCharge: timeCharge,
                    surgeMultiplier: surgeMultiplier,
                    surgeAmount: surgeAmount,
                    discount: discount,
                    totalFare: totalFare,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent({
    required double baseFare,
    required double distanceCharge,
    required double timeCharge,
    required double surgeMultiplier,
    required double surgeAmount,
    required double discount,
    required double totalFare,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
      child: Column(
        children: [
          Divider(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            thickness: 1,
          ),
          SizedBox(height: 2.h),
          _buildFareItem('Base Fare', baseFare),
          SizedBox(height: 1.h),
          _buildFareItem('Distance Charge', distanceCharge),
          SizedBox(height: 1.h),
          _buildFareItem('Time Charge', timeCharge),
          if (surgeMultiplier > 1.0) ...[
            SizedBox(height: 1.h),
            _buildFareItem(
              'Surge Pricing (${surgeMultiplier.toStringAsFixed(1)}x)',
              surgeAmount,
              isHighlight: true,
            ),
          ],
          if (discount > 0) ...[
            SizedBox(height: 1.h),
            _buildFareItem('Discount', -discount, isDiscount: true),
          ],
          SizedBox(height: 2.h),
          Divider(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            thickness: 1,
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              Text(
                'GY\$${totalFare.toStringAsFixed(2)}',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFareItem(String label, double amount,
      {bool isHighlight = false, bool isDiscount = false}) {
    Color textColor = AppTheme.lightTheme.colorScheme.onSurface;
    if (isHighlight) textColor = AppTheme.lightTheme.colorScheme.error;
    if (isDiscount) textColor = AppTheme.lightTheme.colorScheme.tertiary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}GY\$${amount.abs().toStringAsFixed(2)}',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
