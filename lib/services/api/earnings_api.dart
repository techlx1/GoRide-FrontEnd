import 'package:dio/dio.dart';
import 'api_client.dart';

class EarningsApi {
  static final Dio _dio = ApiClient.dio;

  static Future<Map<String, dynamic>> getEarnings(String token) async {
    try {
      final response = await _dio.get(
        '/driver/earnings',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getWallet(int driverId) async {
    try {
      final response = await _dio.get('/driver/$driverId/wallet');
      return response.data;
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  static Future<Map<String, dynamic>> withdraw(int driverId, double amount) async {
    try {
      final response = await _dio.post(
        '/driver/$driverId/wallet/withdraw',
        data: {'amount': amount},
      );
      return response.data;
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }
}
