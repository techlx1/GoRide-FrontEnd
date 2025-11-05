import 'package:dio/dio.dart';
import 'api_client.dart';
//Handles login, registration, and profile.

class AuthApi {
  static final Dio _dio = ApiClient.dio;

  static Future<Map<String, dynamic>> login(String emailOrPhone, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': emailOrPhone.contains('@') ? emailOrPhone : null,
        'phone': !emailOrPhone.contains('@') ? emailOrPhone : null,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  static Future<Map<String, dynamic>> register(
      String fullName,
      String email,
      String phone,
      String password,
      String userType,
      ) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'user_type': userType,
      });
      return response.data;
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await _dio.get(
        '/profile/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }
}
