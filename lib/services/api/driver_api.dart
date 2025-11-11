import 'package:dio/dio.dart';
import 'api_client.dart';
import 'dart:developer';

/// ✅ Handles all driver-related endpoints
class DriverApi {
  static final Dio _dio = ApiClient.dio;

  /// Fetch dashboard overview
  static Future<Map<String, dynamic>> getOverview(int driverId) async {
    try {
      final response = await _dio.get('/driver/overview/$driverId');
      return response.data;
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /// Update online/offline status
  static Future<void> updateStatus(int driverId, bool online) async {
    try {
      await _dio.post('/driver/status', data: {
        'driver_id': driverId,
        'online': online,
      });
      log('✅ Driver $driverId status updated: $online');
    } on DioException catch (e) {
      ApiClient.handleError(e);
    }
  }

  /// Fetch driver trips
  static Future<Map<String, dynamic>> getTrips(int driverId) async {
    try {
      final response = await _dio.get('/driver/$driverId/trips');
      return response.data;
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /// Update driver location
  static Future<void> updateLocation(
      String driverId, double lat, double lng) async {
    try {
      await _dio.post('/driver/location', data: {
        'driver_id': driverId,
        'latitude': lat,
        'longitude': lng,
      });
    } on DioException catch (e) {
      ApiClient.handleError(e);
    }
  }

  /// Fetch driver profile
  static Future<Map<String, dynamic>> getDriverProfile(String token) async {
    try {
      final response = await _dio.get(
        '/driver/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /// Fetch driver documents
  static Future<Map<String, dynamic>> getDriverDocuments(String token) async {
    try {
      final response = await _dio.get(
        '/driver/documents',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }
}
