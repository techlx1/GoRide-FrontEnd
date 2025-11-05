import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BookingStatusWidget extends StatefulWidget {
  final String status;
  final int nearbyDrivers;
  final int estimatedWaitTime;

  const BookingStatusWidget({
    Key? key,
    required this.status,
    required this.nearbyDrivers,
    required this.estimatedWaitTime,
  }) : super(key: key);

  @override
  State<BookingStatusWidget> createState() => _BookingStatusWidgetState();
}

class _BookingStatusWidgetState extends State<BookingStatusWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.status == 'searching') {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BookingStatusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == 'searching' && oldWidget.status != 'searching') {
      _pulseController.repeat(reverse: true);
    } else if (widget.status != 'searching') {
      _pulseController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.status == 'searching'
                        ? _pulseAnimation.value
                        : 1.0,
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: widget.status == 'searching'
                            ? SizedBox(
                                width: 6.w,
                                height: 6.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      _getStatusColor()),
                                ),
                              )
                            : CustomIconWidget(
                                iconName: _getStatusIcon(),
                                color: _getStatusColor(),
                                size: 6.w,
                              ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(),
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _getStatusSubtitle(),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.status == 'ready') ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.nearbyDrivers} drivers nearby',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Estimated wait: ${widget.estimatedWaitTime} minutes',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusTitle() {
    switch (widget.status) {
      case 'searching':
        return 'Finding Driver...';
      case 'ready':
        return 'Ready to Book';
      case 'confirmed':
        return 'Booking Confirmed';
      default:
        return 'Ready to Book';
    }
  }

  String _getStatusSubtitle() {
    switch (widget.status) {
      case 'searching':
        return 'We\'re matching you with the best driver';
      case 'ready':
        return 'Tap confirm to request your ride';
      case 'confirmed':
        return 'Your driver will arrive shortly';
      default:
        return 'Tap confirm to request your ride';
    }
  }

  String _getStatusIcon() {
    switch (widget.status) {
      case 'confirmed':
        return 'check_circle';
      case 'ready':
      default:
        return 'directions_car';
    }
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case 'searching':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'confirmed':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'ready':
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
