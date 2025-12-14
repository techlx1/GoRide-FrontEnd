import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  // 🔔 Callbacks
  Function(Map<String, dynamic>)? onNotificationReceived;
  Function(Map<String, dynamic>)? onRideRequest;

  // ============================================================
  //  CONNECT TO SERVER
  // ============================================================
  void connect(String driverId) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      'https://g-ride-backend.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Socket connected → ${_socket!.id}');

      // Register driver to personal notification room
      _socket!.emit("register_driver", {"driver_id": driverId});
      print("📡 Registered driver room: $driverId");
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
    });

    _socket!.onConnectError((err) {
      print('⚠️ Socket connect error: $err');
    });

    _socket!.onError((err) {
      print('🔥 Socket error: $err');
    });

    // ============================================================
    //  REAL-TIME NOTIFICATIONS
    // ============================================================
    _socket!.on("notification", (data) {
      print("🔔 Notification received: $data");
      if (onNotificationReceived != null) {
        onNotificationReceived!(Map<String, dynamic>.from(data));
      }
    });

    // ============================================================
    //  REAL-TIME RIDE REQUEST (FUTURE FEATURE)
    // ============================================================
    _socket!.on("ride_request", (data) {
      print("🚗 New Ride Request: $data");
      if (onRideRequest != null) {
        onRideRequest!(Map<String, dynamic>.from(data));
      }
    });

    _socket!.connect();
  }

  // ============================================================
  //  SEND DRIVER LOCATION TO BACKEND
  // ============================================================
  void emitDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
  }) {
    if (!isConnected) return;

    _socket!.emit("driver_location", {
      "driver_id": driverId,
      "latitude": latitude,
      "longitude": longitude,
      "timestamp": DateTime.now().toIso8601String(),
    });
  }

  // ============================================================
  //  DISCONNECT
  // ============================================================
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    _socket = null;
  }
}
