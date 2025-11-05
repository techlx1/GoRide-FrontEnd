import 'package:dio/dio.dart';
import 'dart:developer';
//Handles Dio configuration + shared error handler.//


class ApiClient {
  static const String baseUrl = 'https://g-ride-backend.onrender.com/api';

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Map<String, dynamic> handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Server error occurred.',
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
      default:
        return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }
}
