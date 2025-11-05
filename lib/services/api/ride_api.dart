import 'package:dio/dio.dart';
import 'api_client.dart';
//Handles ride actions and status updates.

class RideApi {
  static final Dio _dio = ApiClient.dio;

  static Future<Map<String, dynamic>> acceptRide(int rideId, String driverId) async {
    try {
      final response = await _dio.post('/rides/accept', data: {
        'ride_id': rideId,
        'driver_id': driverId,
      });
      return response.data;
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  static Future<Map<String, dynamic>> updateRideStatus(
      int rideId, String newStatus) async {
    try {
      final response = await _dio.post('/rides/update-status', data: {
        'ride_id': rideId,
        'status': newStatus,
      });
      return response.data;
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }
}
