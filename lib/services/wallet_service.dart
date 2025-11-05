import 'package:dio/dio.dart';
import 'api_service.dart';
import 'package:flutter/foundation.dart';

class WalletService {
  // 🧾 Fetch driver wallet
  static Future<Map<String, dynamic>> getDriverWallet(int driverId) async {
    try {
      final response = await ApiService.dio.get('/driver/wallet/$driverId');
      return response.data;
    } catch (e) {
      debugPrint('Wallet fetch error: $e');
      return {'success': false, 'balance': 0, 'transactions': []};
    }
  }

  // 💸 Add earnings (after ride)
  static Future<void> addEarning(int driverId, double amount) async {
    try {
      await ApiService.dio.post('/driver/wallet/update', data: {
        'driver_id': driverId,
        'amount': amount,
        'type': 'Ride Completed'
      });
    } catch (e) {
      debugPrint('Add earning failed: $e');
    }
  }

  // 🏧 Withdraw request
  static Future<Map<String, dynamic>> withdraw(int driverId, double amount) async {
    try {
      final response = await ApiService.dio.post('/driver/wallet/withdraw', data: {
        'driver_id': driverId,
        'amount': amount,
      });
      return response.data;
    } catch (e) {
      debugPrint('Withdraw failed: $e');
      return {'success': false, 'message': 'Withdraw failed'};
    }
  }
}
