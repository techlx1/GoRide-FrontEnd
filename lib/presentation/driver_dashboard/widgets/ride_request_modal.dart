import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RideRequestModal extends StatefulWidget {
  final Map<String, dynamic> rideRequest;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const RideRequestModal({
    Key? key,
    required this.rideRequest,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  State<RideRequestModal> createState() => _RideRequestModalState();
}

class _RideRequestModalState extends State<RideRequestModal>
    with TickerProviderStateMixin {
  late AnimationController _countdownController;
  late Animation<double> _countdownAnimation;
  int _remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    _countdownController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _countdownAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_countdownController);

    _countdownController.addListener(() {
      setState(() {
        _remainingSeconds = (30 * (1 - _countdownController.value)).round();
      });
    });

    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDecline();
      }
    });

    _countdownController.forward();
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header with countdown
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "New Ride Request",
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'timer',
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "$_remainingSeconds seconds to respond",
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                AnimatedBuilder(
                  animation: _countdownAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _countdownAnimation.value,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    );
                  },
                ),
              ],
            ),
          ),

          // Ride details
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Passenger info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 6.w,
                        backgroundImage: NetworkImage(
                          widget.rideRequest['passengerAvatar'] as String,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.rideRequest['passengerName'] as String,
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'star',
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  "${widget.rideRequest['passengerRating']}",
                                  style:
                                      AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "GY\$${(widget.rideRequest['fareAmount'] as double).toStringAsFixed(2)}",
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Trip details
                  _buildLocationItem(
                    "Pickup Location",
                    widget.rideRequest['pickupLocation'] as String,
                    'location_on',
                    AppTheme.lightTheme.colorScheme.primary,
                  ),

                  SizedBox(height: 2.h),

                  _buildLocationItem(
                    "Drop-off Location",
                    widget.rideRequest['dropoffLocation'] as String,
                    'flag',
                    Colors.red,
                  ),

                  SizedBox(height: 3.h),

                  // Trip stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildTripStat(
                          "Distance",
                          "${widget.rideRequest['distance']} km",
                          'straighten',
                        ),
                      ),
                      Expanded(
                        child: _buildTripStat(
                          "Duration",
                          "${widget.rideRequest['estimatedTime']} min",
                          'schedule',
                        ),
                      ),
                      Expanded(
                        child: _buildTripStat(
                          "Pickup ETA",
                          "${widget.rideRequest['pickupETA']} min",
                          'directions_car',
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onDecline,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.lightTheme.colorScheme.outline,
                            foregroundColor:
                                AppTheme.lightTheme.colorScheme.onSurface,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Decline",
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: widget.onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.lightTheme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Accept Ride",
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(
      String label, String location, String iconName, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: iconColor,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                location,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripStat(String label, String value, String iconName) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
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
}
