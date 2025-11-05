import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/toast_helper.dart';

class DriverOngoingRide extends StatefulWidget {
  final Map<String, dynamic> ride;
  const DriverOngoingRide({Key? key, required this.ride}) : super(key: key);

  @override
  State<DriverOngoingRide> createState() => _DriverOngoingRideState();
}

class _DriverOngoingRideState extends State<DriverOngoingRide> {
  bool _rideCompleted = false;

  void _completeRide() {
    setState(() => _rideCompleted = true);
    ToastHelper.showSuccess('Ride completed!');
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Ride'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _rideCompleted
            ? const Center(
          child: Text(
            'Ride Completed ✅',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pickup: ${ride['pickup']}'),
            Text('Dropoff: ${ride['dropoff']}'),
            Text('Fare: \$${ride['fare']}'),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor:
                AppTheme.lightTheme.colorScheme.primary,
              ),
              onPressed: _completeRide,
              child: const Text('Mark as Completed'),
            ),
          ],
        ),
      ),
    );
  }
}
