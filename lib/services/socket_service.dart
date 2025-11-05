import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/toast_helper.dart';

class SocketService {
  static IO.Socket? socket;
  static bool isConnected = false;

  /// 🌍 Connect to backend Socket.IO server
  static Future<void> connect({required String baseUrl, String? token}) async {
    try {
      if (socket != null && socket!.connected) {
        log('🔁 Socket already connected.');
        return;
      }

      socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(3000)
            .setAuth({'token': token})
            .build(),
      );

      // 🔌 Connection events
      socket!.onConnect((_) {
        isConnected = true;
        log('✅ Socket connected: ${socket!.id}');
        ToastHelper.showSuccess('Socket connected');
      });

      socket!.onDisconnect((_) {
        isConnected = false;
        log('❌ Socket disconnected.');
        ToastHelper.showError('Connection lost. Reconnecting...');
      });

      socket!.onReconnect((_) => log('🔁 Reconnected to socket'));
      socket!.onError((data) => log('⚠️ Socket error: $data'));

      socket!.connect();
    } catch (e) {
      log('❌ Socket connection error: $e');
    }
  }

  /// 🚪 Join a ride room (driver & rider)
  static void joinRideRoom(dynamic rideId) {
    if (socket?.connected ?? false) {
      socket!.emit('join_ride_room', rideId);
      log('🚪 Joined ride room: ride_$rideId');
    } else {
      log('⚠️ Cannot join room, socket not connected');
    }
  }

  /// 👨‍✈️ Join room as driver
  static void joinDriverRoom(dynamic rideId) {
    if (socket?.connected ?? false) {
      socket!.emit('join_driver_room', rideId);
      log('👨‍✈️ Driver joined ride_$rideId');
    }
  }

  /// 📡 Emit live driver location
  static void emitDriverLocation({
    required int driverId,
    required int rideId,
    required double latitude,
    required double longitude,
  }) {
    if (!(socket?.connected ?? false)) return;

    socket!.emit('driver_location', {
      'driver_id': driverId,
      'ride_id': rideId,
      'latitude': latitude,
      'longitude': longitude,
    });

    log('📍 Emitted location → ride_$rideId | lat=$latitude, lng=$longitude');
  }

  /// 🧭 Listen for driver position updates
  static void onDriverPosition(void Function(Map<String, dynamic>) callback) {
    socket?.on('driver_position', (data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  /// ✅ Ride completed notification
  static void onRideCompleted(void Function(Map<String, dynamic>) callback) {
    socket?.on('ride_completed', (data) {
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  /// 💬 Emit a general event
  static void emit(String event, dynamic data) {
    if (socket?.connected ?? false) {
      socket!.emit(event, data);
      log('📤 Emit event: $event | data: $data');
    }
  }

  /// 👂 Listen to custom events
  static void on(String event, void Function(dynamic) callback) {
    socket?.on(event, callback);
  }

  /// ❌ Disconnect
  static void disconnect() {
    if (socket != null) {
      socket!.disconnect();
      isConnected = false;
      log('🛑 Socket disconnected manually');
    }
  }
}
