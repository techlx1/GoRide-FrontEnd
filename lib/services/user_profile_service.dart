import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProfileService {
  static const String baseUrl = 'https://g-ride-backend.onrender.com/api';

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final url = Uri.parse('$baseUrl/profile');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile: ${response.body}');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? phoneNumber,
    String? profilePictureUrl,
    DateTime? dateOfBirth,
  }) async {
    final url = Uri.parse('$baseUrl/profile/update');
    final body = {
      'full_name': fullName,
      'phone': phoneNumber,
      'avatar_url': profilePictureUrl,
      'date_of_birth': dateOfBirth?.toIso8601String(),
    };

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    final url = Uri.parse('$baseUrl/profile/stats');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user statistics: ${response.body}');
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    final url = Uri.parse('$baseUrl/profile/email');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': newEmail}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update email: ${response.body}');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    final url = Uri.parse('$baseUrl/profile/password');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'password': newPassword}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update password: ${response.body}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    final url = Uri.parse('$baseUrl/auth/logout');
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to sign out: ${response.body}');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    final url = Uri.parse('$baseUrl/profile/delete');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete account: ${response.body}');
    }
  }
}
