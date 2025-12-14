import 'package:dio/dio.dart';
import 'api_client.dart';
import 'dart:io';

class DriverApi {
  static final Dio _dio = ApiClient.dio;

  /* ============================================================
     📸 UPLOAD PROFILE PHOTO
  ============================================================ */
  static Future<Map<String, dynamic>> uploadProfilePhoto(File file) async {
    try {
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        "/driver/profile/photo",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     👤 DRIVER PROFILE
  ============================================================ */
  static Future<Map<String, dynamic>> getDriverProfile() async {
    try {
      final response = await _dio.get('/driver/profile');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     📄 DOCUMENTS
  ============================================================ */
  static Future<Map<String, dynamic>> getDriverDocuments() async {
    try {
      final response = await _dio.get('/driver/documents');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     🚗 VEHICLE (GET)
  ============================================================ */
  static Future<Map<String, dynamic>> getDriverVehicle() async {
    try {
      final response = await _dio.get('/driver/vehicle');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     🚗 VEHICLE (UPDATE)
  ============================================================ */
  static Future<Map<String, dynamic>> updateVehicleData({
    required String model,
    required String plate,
    required String year,
    required String color,
    required String seats,
    File? photo,
  }) async {
    try {
      final Map<String, dynamic> data = {
        "vehicle_model": model,
        "license_plate": plate,
        "vehicle_year": year,
        "vehicle_color": color,
        "vehicle_seats": seats,
      };

      if (photo != null) {
        data["vehicle_photo"] = await MultipartFile.fromFile(
          photo.path,
          filename: "vehicle.jpg",
        );
      }

      final formData = FormData.fromMap(data);

      final response = await _dio.post(
        "/driver/vehicle/update",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     📊 DRIVER OVERVIEW
  ============================================================ */
  static Future<Map<String, dynamic>> getDriverOverview() async {
    try {
      final response = await _dio.get('/driver/overview');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     📦 RECENT ORDERS
  ============================================================ */
  static Future<Map<String, dynamic>> getRecentOrders() async {
    try {
      final response = await _dio.get('/driver/rides/recent');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     💰 WALLET – OVERVIEW
  ============================================================ */
  static Future<Map<String, dynamic>> getWalletOverview() async {
    try {
      final response = await _dio.get('/driver/wallet');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     💳 WALLET – TRANSACTIONS
  ============================================================ */
  static Future<Map<String, dynamic>> getWalletTransactions({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/driver/wallet/transactions',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     💸 REQUEST PAYOUT
  ============================================================ */
  static Future<Map<String, dynamic>> requestPayout({
    required String amount,
    String? method,
    String? note,
  }) async {
    try {
      final response = await _dio.post(
        '/driver/wallet/payout',
        data: {
          'amount': amount,
          'method': method ?? 'wallet',
          'note': note,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     🔄 SEND MONEY
  ============================================================ */
  static Future<Map<String, dynamic>> sendMoney({
    required String receiverWalletId,
    required String amount,
    String? note,
  }) async {
    try {
      final response = await _dio.post(
        '/driver/wallet/send',
        data: {
          'receiver_wallet_id': receiverWalletId,
          'amount': amount,
          'note': note,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     📥 RECEIVE INFO
  ============================================================ */
  static Future<Map<String, dynamic>> getReceiveInfo() async {
    try {
      final response = await _dio.get('/driver/wallet/receive');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     💬 SEND SUGGESTION
  ============================================================ */
  static Future<Map<String, dynamic>> sendSuggestion({
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        '/app/suggestions',
        data: {"message": message},
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     🌍 UPDATE LANGUAGE
  ============================================================ */
  static Future<Map<String, dynamic>> updateLanguage({
    required String languageCode,
  }) async {
    try {
      final response = await _dio.post(
        '/app/language',
        data: {"language": languageCode},
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     🤝 REFERRAL
  ============================================================ */
  static Future<Map<String, dynamic>> createReferral() async {
    try {
      final response = await _dio.post('/referral/create');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     ❌ DELETE ACCOUNT
  ============================================================ */
  static Future<Map<String, dynamic>> deleteAccount({String? reason}) async {
    try {
      final response = await _dio.post(
        '/driver/account/delete',
        data: {'reason': reason},
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     🔔 APP VERSION
  ============================================================ */
  static Future<Map<String, dynamic>> getAppVersion() async {
    try {
      final response = await _dio.get(
        '/app/version',
        queryParameters: {"platform": "android"},
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     🔔 NOTIFICATIONS (UNREAD COUNT)
  ============================================================ */
  static Future<Map<String, dynamic>> getUnreadNotifications() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     🔔 NOTIFICATIONS – FULL LIST
  ============================================================ */
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }

  /* ============================================================
     🔔 MARK AS READ
  ============================================================ */
  static Future<Map<String, dynamic>> markNotificationRead(String id) async {
    try {
      final response = await _dio.put('/notifications/mark-read/$id');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }
}
