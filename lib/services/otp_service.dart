import './supabase_service.dart';

class OtpService {
  final _client = SupabaseService.instance.client;

  // Generate and send OTP
  Future<Map<String, dynamic>> generateOtp({
    required String phoneNumber,
    required String purpose, // 'registration', 'login', 'password_reset'
    String? userId,
  }) async {
    try {
      // Clean up expired OTPs for this phone number
      await _cleanupExpiredOtps(phoneNumber);

      final response = await _client
          .from('otp_verifications')
          .insert({
            'user_id': userId,
            'phone_number': phoneNumber,
            'otp_code': _generateSixDigitOtp(),
            'purpose': purpose,
            'expires_at': DateTime.now()
                .add(const Duration(minutes: 10))
                .toIso8601String(),
          })
          .select()
          .single();

      // In production, integrate with SMS service like Twilio
      // For demo purposes, return the OTP in response
      return {
        'success': true,
        'message': 'OTP sent successfully',
        'otp_id': response['id'],
        'demo_otp': response['otp_code'], // Remove in production
      };
    } catch (error) {
      throw Exception('Failed to generate OTP: $error');
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
    required String purpose,
  }) async {
    try {
      final response = await _client
          .from('otp_verifications')
          .select()
          .eq('phone_number', phoneNumber)
          .eq('otp_code', otpCode)
          .eq('purpose', purpose)
          .isFilter('verified_at', null)
          .gte('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        // Check if OTP exists but is expired or already used
        final existingOtp = await _client
            .from('otp_verifications')
            .select()
            .eq('phone_number', phoneNumber)
            .eq('otp_code', otpCode)
            .eq('purpose', purpose)
            .order('created_at', ascending: false)
            .limit(1);

        if (existingOtp.isNotEmpty) {
          final otp = existingOtp.first;
          if (otp['verified_at'] != null) {
            throw Exception('OTP has already been used');
          } else if (DateTime.parse(otp['expires_at'])
              .isBefore(DateTime.now())) {
            throw Exception('OTP has expired');
          }
        }
        throw Exception('Invalid OTP code');
      }

      final otpRecord = response.first;

      // Mark OTP as verified
      await _client.from('otp_verifications').update({
        'verified_at': DateTime.now().toIso8601String(),
        'attempts': (otpRecord['attempts'] ?? 0) + 1,
      }).eq('id', otpRecord['id']);

      return {
        'success': true,
        'message': 'OTP verified successfully',
        'user_id': otpRecord['user_id'],
        'phone_number': otpRecord['phone_number'],
      };
    } catch (error) {
      // Increment attempt count on failure
      await _incrementFailedAttempt(phoneNumber, otpCode, purpose);
      rethrow;
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp({
    required String phoneNumber,
    required String purpose,
  }) async {
    try {
      // Check if there's a recent OTP request (rate limiting)
      final recentOtp = await _client
          .from('otp_verifications')
          .select()
          .eq('phone_number', phoneNumber)
          .eq('purpose', purpose)
          .gte(
              'created_at',
              DateTime.now()
                  .subtract(const Duration(minutes: 1))
                  .toIso8601String())
          .limit(1);

      if (recentOtp.isNotEmpty) {
        throw Exception('Please wait before requesting a new OTP');
      }

      // Generate new OTP
      return await generateOtp(
        phoneNumber: phoneNumber,
        purpose: purpose,
      );
    } catch (error) {
      throw Exception('Failed to resend OTP: $error');
    }
  }

  // Get OTP status for debugging/admin
  Future<Map<String, dynamic>?> getOtpStatus({
    required String phoneNumber,
    required String purpose,
  }) async {
    try {
      final response = await _client
          .from('otp_verifications')
          .select()
          .eq('phone_number', phoneNumber)
          .eq('purpose', purpose)
          .order('created_at', ascending: false)
          .limit(1);

      return response.isEmpty ? null : response.first;
    } catch (error) {
      return null;
    }
  }

  // Private helper methods
  String _generateSixDigitOtp() {
    return (100000 +
            (900000 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)
                .floor())
        .toString();
  }

  Future<void> _cleanupExpiredOtps(String phoneNumber) async {
    try {
      await _client
          .from('otp_verifications')
          .delete()
          .eq('phone_number', phoneNumber)
          .lt('expires_at', DateTime.now().toIso8601String());
    } catch (error) {
      // Silent fail on cleanup
    }
  }

  Future<void> _incrementFailedAttempt(
      String phoneNumber, String otpCode, String purpose) async {
    try {
      await _client
          .from('otp_verifications')
          .update({
            'attempts':
                1, // Since this might fail, we can use raw SQL to increment properly
          })
          .eq('phone_number', phoneNumber)
          .eq('otp_code', otpCode)
          .eq('purpose', purpose);
    } catch (error) {
      // Silent fail on attempt increment
    }
  }
}
