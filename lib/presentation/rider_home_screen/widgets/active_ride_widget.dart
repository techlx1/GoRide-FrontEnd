import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class ActiveRideWidget extends StatelessWidget {
  final Map<String, dynamic> rideData;
  final VoidCallback onCancelRide;

  const ActiveRideWidget({
    Key? key,
    required this.rideData,
    required this.onCancelRide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = rideData['status'] ?? 'requested';
    final pickupAddress = rideData['pickup_address'] ?? 'Unknown pickup';
    final destinationAddress =
        rideData['destination_address'] ?? 'Unknown destination';
    final fareAmount = rideData['fare_amount'];
    final driverData = rideData['driver_profiles'];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.w,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Header
          Row(
            children: [
              _buildStatusIcon(status),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(status),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                    Text(
                      _getStatusMessage(status),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (status == 'requested')
                TextButton(
                  onPressed: () {
                    _showCancelConfirmation(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 16.h),

          // Driver Information (if assigned)
          if (driverData != null && status != 'requested') ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Row(
                children: [
                  // Driver Avatar
                  CircleAvatar(
                    radius: 24.w,
                    backgroundColor: Theme.of(context).primaryColor,
                    backgroundImage: driverData['user_profiles']
                                ?['profile_picture_url'] !=
                            null
                        ? NetworkImage(
                            driverData['user_profiles']['profile_picture_url'])
                        : null,
                    child: driverData['user_profiles']
                                ?['profile_picture_url'] ==
                            null
                        ? Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24.w,
                          )
                        : null,
                  ),
                  SizedBox(width: 12.w),

                  // Driver Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverData['user_profiles']?['full_name'] ?? 'Driver',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${driverData['vehicle_model'] ?? 'Vehicle'} • ${driverData['vehicle_color'] ?? 'Color'}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16.w,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${driverData['rating'] ?? 0.0}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Call Button
                  IconButton(
                    onPressed: () {
                      // Make call to driver
                      _makeCallToDriver(
                          driverData['user_profiles']?['phone_number']);
                    },
                    icon: Icon(
                      Icons.phone,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Route Information
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2.w,
                    height: 24.h,
                    color: Colors.grey[300],
                  ),
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      pickupAddress,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'To',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      destinationAddress,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (fareAmount != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Fare',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      'GY\$${fareAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;

    switch (status) {
      case 'requested':
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case 'accepted':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'in_progress':
        icon = Icons.directions_car;
        color = Colors.blue;
        break;
      case 'completed':
        icon = Icons.done_all;
        color = Colors.green;
        break;
      case 'cancelled':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20.w,
      ),
    );
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'requested':
        return 'Finding a driver...';
      case 'accepted':
        return 'Driver assigned';
      case 'in_progress':
        return 'On the way';
      case 'completed':
        return 'Ride completed';
      case 'cancelled':
        return 'Ride cancelled';
      default:
        return 'Unknown status';
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'requested':
        return 'We\'re looking for the nearest driver';
      case 'accepted':
        return 'Your driver is on the way to pickup';
      case 'in_progress':
        return 'Enjoy your ride';
      case 'completed':
        return 'Thank you for choosing RideGuyana';
      case 'cancelled':
        return 'Your ride has been cancelled';
      default:
        return '';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.orange;
      case 'accepted':
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Ride'),
          content: const Text('Are you sure you want to cancel this ride?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Ride'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onCancelRide();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ride cancelled'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cancel Ride'),
            ),
          ],
        );
      },
    );
  }

  void _makeCallToDriver(String? phoneNumber) {
    if (phoneNumber != null) {
      // In production, integrate with phone dialer
      // For now, just show a message
      debugPrint('Calling driver: $phoneNumber');
    }
  }
}
