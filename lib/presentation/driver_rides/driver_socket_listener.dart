import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/nav.dart';
import '../../state/ride_events_notifier.dart';
import '../../utils/toast_helper.dart';
import '../../services/api_service.dart';
import 'driver_ongoing_ride.dart';
import 'widgets/ride_request_dialog.dart';

class DriverSocketListener extends StatefulWidget {
  final Widget child;
  const DriverSocketListener({Key? key, required this.child}) : super(key: key);

  @override
  State<DriverSocketListener> createState() => _DriverSocketListenerState();
}

class _DriverSocketListenerState extends State<DriverSocketListener> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RideEventsNotifier>(
      builder: (context, events, child) {
        final ride = events.incomingRide;
        if (ride != null && !events.dialogShown) {
          events.markDialogShown();

          Future.microtask(() {
            final ctx = rootNavigatorKey.currentState!.overlay!.context;

            showDialog(
              context: ctx,
              barrierDismissible: false,
              builder: (dialogCtx) {
                return RideRequestDialog(
                  ride: ride,
                  onAccept: () async {
                    Navigator.of(dialogCtx).pop();
                    await _acceptRide(context, ride);
                  },
                  onReject: () async {
                    Navigator.of(dialogCtx).pop();
                    await _rejectRide(context, ride);
                  },
                );
              },
            );
          });
        }
        return widget.child;
      },
    );
  }

  Future<void> _acceptRide(BuildContext context, Map<String, dynamic> ride) async {
    final rideId = ride['ride_id'] ?? ride['id'];
    final driverId = ride['driver_id'];
    final res = await ApiService.acceptRide(driverId, rideId);
    if (res['success'] == true) {
      ToastHelper.showSuccess(res['message'] ?? 'Ride accepted');
      context.read<RideEventsNotifier>().clearIncomingRide();
      Navigator.of(rootNavigatorKey.currentContext!).push(
        MaterialPageRoute(builder: (_) => DriverOngoingRide(ride: ride)),
      );
    } else {
      ToastHelper.showError(res['message'] ?? 'Failed to accept');
    }
  }

  Future<void> _rejectRide(BuildContext context, Map<String, dynamic> ride) async {
    final rideId = ride['ride_id'] ?? ride['id'];
    final driverId = ride['driver_id'];
    final res = await ApiService.rejectRide(driverId, rideId);
    if (res['success'] == true) {
      ToastHelper.showInfo(res['message'] ?? 'Ride rejected');
    } else {
      ToastHelper.showError(res['message'] ?? 'Failed to reject');
    }
    context.read<RideEventsNotifier>().clearIncomingRide();
  }
}
