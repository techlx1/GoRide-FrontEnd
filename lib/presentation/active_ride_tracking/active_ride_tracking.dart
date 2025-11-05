import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/driver_info_card.dart';
import './widgets/map_widget.dart';
import './widgets/ride_action_buttons.dart';
import './widgets/ride_status_banner.dart';

class ActiveRideTracking extends StatefulWidget {
  const ActiveRideTracking({Key? key}) : super(key: key);

  @override
  State<ActiveRideTracking> createState() => _ActiveRideTrackingState();
}

class _ActiveRideTrackingState extends State<ActiveRideTracking>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Mock ride data
  final Map<String, dynamic> rideData = {
    "id": "RIDE_2025_001",
    "status": "Driver En Route",
    "estimatedTime": "8 mins",
    "distance": "2.3 km",
    "progress": 0.4,
    "fare": "GY\$850.00",
    "pickupAddress": "Main Street, Georgetown",
    "dropoffAddress": "Brickdam, Georgetown",
  };

  final Map<String, dynamic> driverData = {
    "id": "DRV_001",
    "name": "Marcus Thompson",
    "photo":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
    "rating": 4.8,
    "totalRides": 1247,
    "vehicleModel": "Toyota Corolla",
    "licensePlate": "GY 1234 AB",
    "phone": "+592-123-4567",
    "vehicleColor": "White",
  };

  // Location data
  final LatLng userLocation = LatLng(6.8013, -58.1551); // Georgetown, Guyana
  LatLng driverLocation = LatLng(6.8100, -58.1600); // Driver's current location

  final List<LatLng> routePoints = [
    LatLng(6.8100, -58.1600), // Driver location
    LatLng(6.8080, -58.1580),
    LatLng(6.8050, -58.1565),
    LatLng(6.8013, -58.1551), // User location
  ];

  bool _canCancelRide = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _simulateDriverMovement();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  void _simulateDriverMovement() {
    // Simulate driver moving towards user
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          driverLocation = LatLng(6.8080, -58.1580);
        });
      }
    });

    Future.delayed(Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          driverLocation = LatLng(6.8050, -58.1565);
          rideData["status"] = "Driver Arrived";
          rideData["estimatedTime"] = "2 mins";
          rideData["distance"] = "0.8 km";
          rideData["progress"] = 0.7;
          _canCancelRide = false;
        });
      }
    });

    Future.delayed(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          rideData["status"] = "Trip Started";
          rideData["estimatedTime"] = "12 mins";
          rideData["distance"] = "4.2 km";
          rideData["progress"] = 0.1;
        });
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _handleCall() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Call Driver',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Text(
          'Calling ${driverData["name"]} at ${driverData["phone"]}',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In real app, would initiate actual call
            },
            child: Text('Call'),
          ),
        ],
      ),
    );
  }

  void _handleMessage() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Message ${driverData["name"]}',
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'Chat functionality would be implemented here',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 2.h,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: CustomIconWidget(
                              iconName: 'send',
                              color: Colors.white,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
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
      ),
    );
  }

  void _handleEmergency() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: Colors.red,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Emergency',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you in an emergency situation?',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              'This will immediately contact emergency services and share your location.',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In real app, would contact emergency services
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Emergency services contacted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Call Emergency'),
          ),
        ],
      ),
    );
  }

  void _handleShareRide() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Ride',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              'Share your live location with friends and family',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption('SMS', 'sms', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ride shared via SMS')),
                  );
                }),
                _buildShareOption('WhatsApp', 'chat', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ride shared via WhatsApp')),
                  );
                }),
                _buildShareOption('Email', 'email', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ride shared via Email')),
                  );
                }),
              ],
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(String title, String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _handleCancelRide() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Ride',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to cancel this ride?',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Cancellation fee: GY\$150.00',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep Ride'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                  context, '/ride-booking-confirmation');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Cancel Ride'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          MapWidget(
            userLocation: userLocation,
            driverLocation: driverLocation,
            routePoints: routePoints,
            onMapCreated: _onMapCreated,
          ),

          // Status Banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: RideStatusBanner(
              status: rideData["status"] as String,
              estimatedTime: rideData["estimatedTime"] as String,
              distance: rideData["distance"] as String,
              progress: rideData["progress"] as double,
            ),
          ),

          // Action Buttons
          RideActionButtons(
            onEmergency: _handleEmergency,
            onShareRide: _handleShareRide,
            onCancelRide: _canCancelRide ? _handleCancelRide : null,
            canCancel: _canCancelRide,
          ),

          // Driver Info Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DriverInfoCard(
              driverData: driverData,
              onCall: _handleCall,
              onMessage: _handleMessage,
            ),
          ),
        ],
      ),
    );
  }
}
