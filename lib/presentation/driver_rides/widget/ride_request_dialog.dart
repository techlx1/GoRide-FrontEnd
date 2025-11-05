import 'package:flutter/material.dart';

class RideRequestDialog extends StatelessWidget {
  final Map<String, dynamic> ride;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const RideRequestDialog({
    Key? key,
    required this.ride,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pickup = ride['pickup'] ?? 'Pickup';
    final dropoff = ride['dropoff'] ?? 'Dropoff';
    final fare = ride['fare'] ?? 0;
    final riderName = ride['rider_name'] ?? 'Rider';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('New Ride Request'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$riderName is requesting a ride'),
          const SizedBox(height: 8),
          Text('Pickup: $pickup'),
          Text('Dropoff: $dropoff'),
          const SizedBox(height: 8),
          Text('Fare: \$${fare.toString()}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        TextButton(onPressed: onReject, child: const Text('Reject')),
        ElevatedButton(onPressed: onAccept, child: const Text('Accept')),
      ],
    );
  }
}
