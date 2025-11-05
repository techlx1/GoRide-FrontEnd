import 'package:dio/dio.dart';
import 'dart:developer';

class ApiService {
  // 🌍 Backend base URL
  static const String baseUrl = 'https://g-ride-backend.onrender.com/api';

  // 🔧 Dio instance
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  static Dio get dio => _dio;


  // 🔐 LOGIN (email or phone)
  static Future<Map<String, dynamic>> loginUser(
      String emailOrPhone, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': emailOrPhone.contains('@') ? emailOrPhone : null,
          'phone': !emailOrPhone.contains('@') ? emailOrPhone : null,
          'password': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  // 📝 REGISTER NEW USER
  static Future<Map<String, dynamic>> registerUser(
      String fullName,
      String email,
      String phone,
      String password,
      String userType) async {
    try {
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
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  // 👤 GET PROFILE (token-based)
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await _dio.get(
        '/profile/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  // 🚘 DRIVER OVERVIEW (using driverId)
  static Future<Map<String, dynamic>> getDriverOverview(int driverId) async {
    try {
      final response = await _dio.get('/driver/overview/$driverId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['overview'];
      } else {
        return {'success': false, 'message': 'Failed to load driver overview'};
      }
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  // 🚘 DRIVER STATUS (update online/offline)
  static Future<void> updateDriverStatus(int driverId, bool online) async {
    try {
      await _dio.post('/driver/status', data: {
        'driver_id': driverId,
        'online': online,
      });
      log('🚗 Driver $driverId status updated: $online');
    } on DioException catch (e) {
      _handleError(e);
    } catch (e) {
      log('❌ updateDriverStatus error: $e');
    }
  }

  // 🚘 DRIVER TRIPS HISTORY
  static Future<Map<String, dynamic>> getDriverTrips(int driverId) async {
    try {
      final response = await _dio.get('/driver/$driverId/trips');
      if (response.statusCode == 200) {
        final data = (response.data is List && response.data.isNotEmpty)
            ? {'success': true, 'trips': response.data}
            : response.data;
        return data;
      } else {
        return {'success': false, 'message': 'Failed to load trip history'};
      }
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  // 💰 DRIVER WALLET DATA
  static Future<Map<String, dynamic>> getDriverWallet(int driverId) async {
    try {
      final response = await _dio.get('/driver/$driverId/wallet');
      if (response.statusCode == 200) {
        final data = (response.data is List && response.data.isNotEmpty)
            ? response.data[0]
            : response.data;
        return data;
      } else {
        return {'success': false, 'message': 'Failed to load wallet'};
      }
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  // 🏦 WITHDRAW FUNDS
  static Future<Map<String, dynamic>> withdrawDriverFunds(
      int driverId, double amount) async {
    try {
      final response = await _dio.post(
        '/driver/$driverId/wallet/withdraw',
        data: {'amount': amount},
      );
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  // 💰 DRIVER EARNINGS
  static Future<Map<String, dynamic>> getDriverEarnings(String token) async {
    try {
      final response = await _dio.get(
        '/driver/earnings',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  // ⚙️ HANDLE ERRORS
  static Map<String, dynamic> _handleError(DioException e) {
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
