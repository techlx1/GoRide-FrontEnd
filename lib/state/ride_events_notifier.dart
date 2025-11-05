import 'package:flutter/foundation.dart';

class RideEventsNotifier extends ChangeNotifier {
  Map<String, dynamic>? _incomingRide; // latest ride
  bool _dialogShown = false; // guard to avoid duplicate dialogs

  Map<String, dynamic>? get incomingRide => _incomingRide;
  bool get dialogShown => _dialogShown;

  void setIncomingRide(Map<String, dynamic> ride) {
    _incomingRide = ride;
    _dialogShown = false;
    notifyListeners();
  }

  void markDialogShown() {
    _dialogShown = true;
  }

  void clearIncomingRide() {
    _incomingRide = null;
    _dialogShown = false;
    notifyListeners();
  }
}
