import 'package:dio/dio.dart';
import 'api_client.dart';

/// Handles authentication, registration, and user profile routes.
/// Communicates with your Render backend, which handles Supabase Auth.
class AuthApi {
  static final Dio _dio = ApiClient.dio;

  /// 🔐 Login via Render → Supabase
  static Future<Map<String, dynamic>> login(String emailOrPhone, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'email': emailOrPhone.contains('@') ? emailOrPhone : null,
          'phone': !emailOrPhone.contains('@') ? emailOrPhone : null,
          'password': password,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  /// 🧾 Register new account (Render → Supabase)
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String userType,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
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
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  /// 👤 Fetch profile using Supabase token via Render API
  static Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await _dio.get(
        '/api/profile/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }
}
