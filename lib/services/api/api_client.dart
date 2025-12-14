import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

/// 🌐 Global Dio client for the G-Ride app.
/// Handles base URL, headers, token injection, timeouts, and unified error handling.
class ApiClient {
  /// ✅ Render backend base URL (no extra /api here)
  static const String baseUrl = 'https://g-ride-backend.onrender.com/api';

  /// 🧩 Dio instance with common configuration
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 25), // ⏱️ allow Render cold start
      receiveTimeout: const Duration(seconds: 25),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          // 🪪 Automatically attach saved JWT token
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          log('⚠️ Failed to attach token: $e');
        }

        // 🛰️ Log outgoing request
        log('➡️ ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // ✅ Log successful responses
        log('✅ ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (error, handler) {
        // 🔒 Handle global 401s
        if (error.response?.statusCode == 401) {
          log('🔒 Unauthorized: ${error.requestOptions.uri}');
        }
        return handler.next(error);
      },
    ),
  );

  /// 🧠 Centralized Dio error handler
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
        return {'success': false, 'message': 'Connection timed out. Please try again.'};
      case DioExceptionType.receiveTimeout:
        return {'success': false, 'message': 'Response timed out. Please retry.'};
      case DioExceptionType.badResponse:
        return {'success': false, 'message': 'Bad response: ${e.response?.statusCode}'};
      case DioExceptionType.connectionError:
        return {'success': false, 'message': 'No internet connection.'};
      default:
        return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }
}
