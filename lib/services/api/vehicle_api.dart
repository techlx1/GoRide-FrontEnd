import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

class VehicleApi {
  static final Dio _dio = ApiClient.dio;

  static Future<String?> uploadVehiclePhoto(File file) async {
    try {
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        "vehicle_photo": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        "/vehicle/upload-photo",
        data: formData,
      );

      if (response.data["success"] == true) {
        return response.data["url"];
      }
      return null;

    } on DioException catch (e) {
      return ApiClient.handleError(e)["message"];
    }
  }

  static Future<Map<String, dynamic>> upsertVehicle(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post("/vehicle/upsert", data: body);
      return response.data;
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }
}
