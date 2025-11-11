import 'package:dio/dio.dart';
import '../api/api_client.dart';

/// 💰 Driver Earnings & Wallet API
/// Communicates with Render backend (which fetches Supabase data)
class EarningsApi {
  static final Dio _dio = ApiClient.dio;

  /// 📊 Fetch driver earnings summary
  /// Endpoint: GET /api/driver/earnings/:driverId
  static Future<Map<String, dynamic>> getEarnings({
    required String driverId,
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        '/driver/earnings/$driverId',
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
  /// (Future endpoint: /api/driver/wallet/:driverId)
  static Future<Map<String, dynamic>> getWallet({
    required String driverId,
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        '/driver/wallet/$driverId',
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

  /// 💸 Request withdrawal from driver wallet
  /// (Future endpoint: POST /api/driver/wallet/withdraw)
  static Future<Map<String, dynamic>> withdraw({
    required String driverId,
    required double amount,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/driver/wallet/withdraw',
        data: {'driverId': driverId, 'amount': amount},
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
