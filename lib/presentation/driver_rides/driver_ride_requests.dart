import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/toast_helper.dart';
import 'driver_ongoing_ride.dart';

class DriverRideRequests extends StatefulWidget {
  const DriverRideRequests({Key? key}) : super(key: key);

  @override
  State<DriverRideRequests> createState() => _DriverRideRequestsState();
}

class _DriverRideRequestsState extends State<DriverRideRequests> {
  List<Map<String, dynamic>> _requests = [
    {'id': 1, 'pickup': 'Market Square', 'dropoff': 'Mackenzie Hospital', 'fare': 1200},
    {'id': 2, 'pickup': 'Wismar', 'dropoff': 'Linden Bus Park', 'fare': 800},
  ];

  void _acceptRide(Map<String, dynamic> ride) {
    ToastHelper.showSuccess('Ride accepted!');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DriverOngoingRide(ride: ride)),
    );
  }

  void _rejectRide(Map<String, dynamic> ride) {
    ToastHelper.showInfo('Ride declined.');
    setState(() => _requests.remove(ride));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Requests'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
      body: _requests.isEmpty
          ? const Center(child: Text('No ride requests at the moment.'))
          : ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final ride = _requests[index];
          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text('${ride['pickup']} → ${ride['dropoff']}'),
              subtitle: Text('Fare: \$${ride['fare']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _rejectRide(ride),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _acceptRide(ride),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
