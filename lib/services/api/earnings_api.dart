import 'package:dio/dio.dart';
import '../api/api_client.dart';

/// 💰 Driver Earnings & Wallet API
/// Communicates with Render backend (which fetches Supabase data)
class EarningsApi {
  static final Dio _dio = ApiClient.dio;

  /// 📊 Fetch driver earnings summary
  /// Backend: GET /driver/earnings
  /// Driver ID is extracted from JWT token on server
  static Future<Map<String, dynamic>> getEarnings({
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        '/driver/earnings',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  /// 💼 Retrieve driver wallet balance
  /// Backend: GET /driver/wallet
  static Future<Map<String, dynamic>> getWallet({
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        '/driver/wallet',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  /// 💸 Request payout
  /// Backend: POST /driver/wallet/payout
  static Future<Map<String, dynamic>> requestPayout({
    required double amount,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/driver/wallet/payout',
        data: {'amount': amount},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }
}
