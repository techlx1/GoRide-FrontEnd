import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthApi {
  static final Dio _dio = ApiClient.dio;

  static Future<Map<String, dynamic>> login(
      String emailOrPhone, String password) async {
    try {
      final Map<String, dynamic> data = emailOrPhone.contains('@')
          ? {'email': emailOrPhone, 'password': password}
          : {'phone': emailOrPhone, 'password': password};

      // ✔ Correct URL now
      final response = await _dio.post('/auth/login', data: data);

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String userType,
  }) async {
    try {
      // ✔ Correct
      final response = await _dio.post(
        '/auth/register',
        data: {
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'user_type': userType,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      // ✔ Correct — matches backend /api/profile/me
      final response = await _dio.get(
        '/profile/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }
}
