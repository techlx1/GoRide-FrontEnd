import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './api/api_client.dart';

/// 💳 Handles driver wallet operations
/// such as fetching balance, adding earnings, and withdrawals.
class WalletService {
  static final Dio _dio = ApiClient.dio;

  /// 🧾 Fetch driver wallet (requires token)
  static Future<Map<String, dynamic>> getDriverWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _dio.get(
        '/driver/wallet',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Wallet fetch error: ${e.message}');
      return ApiClient.handleError(e);
    } catch (e) {
      debugPrint('Wallet fetch error: $e');
      return {'success': false, 'balance': 0, 'transactions': []};
    }
  }

  /// 💸 Add earnings (after a completed ride)
  static Future<void> addEarning(double amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      await _dio.post(
        '/driver/wallet/update',
        data: {'amount': amount, 'type': 'Ride Completed'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      debugPrint('✅ Added earning: $amount');
    } on DioException catch (e) {
      debugPrint('❌ Add earning failed: ${e.message}');
      ApiClient.handleError(e);
    } catch (e) {
      debugPrint('Add earning failed: $e');
    }
  }

  /// 🏧 Withdraw funds
  static Future<Map<String, dynamic>> withdraw(double amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _dio.post(
        '/driver/wallet/withdraw',
        data: {'amount': amount},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('✅ Withdrawal response: ${response.data}');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Withdraw failed: ${e.message}');
      return ApiClient.handleError(e);
    } catch (e) {
      debugPrint('Withdraw failed: $e');
      return {'success': false, 'message': 'Withdraw failed'};
    }
  }
}
