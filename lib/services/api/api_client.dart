import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

/// Global Dio client for the G-Ride app.
/// Handles Render backend requests, headers, timeouts, and error formatting.
class ApiClient {
  static const String baseUrl = 'https://g-ride-backend.onrender.com/api';

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        log('⚠️ Failed to attach token: $e');
      }
      return handler.next(options);
    },
    onResponse: (response, handler) {
      // Optional: log successful responses in debug mode
      log('✅ ${response.requestOptions.method} ${response.requestOptions.uri} → ${response.statusCode}');
      return handler.next(response);
    },
    onError: (error, handler) {
      // Optional: handle global 401
      if (error.response?.statusCode == 401) {
        log('🔒 Unauthorized request to ${error.requestOptions.path}');
      }
      return handler.next(error);
    },
  ));

  /// Centralized Dio error formatter for consistent API responses.
  static Map<String, dynamic> handleError(DioException e) {
    log('❌ API error: ${e.message}');

    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      return {
        'success': false,
        'message': data is Map && data['message'] != null
            ? data['message']
            : 'Server error occurred.',
      };
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return {'success': false, 'message': 'Connection timed out.'};
      case DioExceptionType.receiveTimeout:
        return {'success': false, 'message': 'Response timed out.'};
      case DioExceptionType.badResponse:
        return {
          'success': false,
          'message': 'Bad response: ${e.response?.statusCode}'
        };
      case DioExceptionType.connectionError:
        return {'success': false, 'message': 'No internet connection.'};
      default:
        return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }
}
