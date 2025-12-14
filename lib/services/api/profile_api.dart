import 'package:dio/dio.dart';
import 'api_client.dart';

class ProfileApi {
  static final Dio _dio = ApiClient.dio;

  static Future<Map<String, dynamic>> uploadProfilePhoto(FormData formData) async {
    try {
      final response = await _dio.post(
        '/profile/photo',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return ApiClient.handleError(e);
    }
  }
}
