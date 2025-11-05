import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PromoCodeWidget extends StatefulWidget {
  final Function(String) onPromoCodeApplied;
  final String? appliedPromoCode;

  const PromoCodeWidget({
    Key? key,
    required this.onPromoCodeApplied,
    this.appliedPromoCode,
  }) : super(key: key);

  @override
  State<PromoCodeWidget> createState() => _PromoCodeWidgetState();
}

class _PromoCodeWidgetState extends State<PromoCodeWidget> {
  final TextEditingController _promoController = TextEditingController();
  bool _isApplying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.appliedPromoCode != null) {
      _promoController.text = widget.appliedPromoCode!;
    }
  }

  Future<void> _applyPromoCode() async {
    if (_promoController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a promo code';
      });
      return;
    }

    setState(() {
      _isApplying = true;
      _errorMessage = null;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final promoCode = _promoController.text.trim().toUpperCase();
    final validPromoCodes = ['RIDE10', 'WELCOME20', 'GUYANA15', 'NEWUSER25'];

    if (validPromoCodes.contains(promoCode)) {
      widget.onPromoCodeApplied(promoCode);
      setState(() {
        _isApplying = false;
      });
    } else {
      setState(() {
        _isApplying = false;
        _errorMessage = 'Invalid promo code. Please try again.';
      });
    }
  }

  void _removePromoCode() {
    _promoController.clear();
    widget.onPromoCodeApplied('');
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasAppliedCode =
        widget.appliedPromoCode != null && widget.appliedPromoCode!.isNotEmpty;

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
            children: [
              CustomIconWidget(
                iconName: 'local_offer',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Promo Code',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (hasAppliedCode) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Promo Code Applied',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.appliedPromoCode!,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _removePromoCode,
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.error
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.error,
                        size: 4.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'confirmation_number',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 5.w,
                        ),
                      ),
                      errorText: _errorMessage,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) {
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 3.w),
                ElevatedButton(
                  onPressed: _isApplying ? null : _applyPromoCode,
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isApplying
                      ? SizedBox(
                          width: 4.w,
                          height: 4.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          'Apply',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ],
          if (!hasAppliedCode) ...[
            SizedBox(height: 2.h),
            Text(
              'Popular codes: RIDE10, WELCOME20, GUYANA15',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }
}
