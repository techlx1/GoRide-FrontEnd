import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class OtpHeaderWidget extends StatelessWidget {
  final String phoneNumber;
  final String purpose;

  const OtpHeaderWidget({
    Key? key,
    required this.phoneNumber,
    required this.purpose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maskedPhoneNumber = _maskPhoneNumber(phoneNumber);

    return Column(
      children: [
        // Icon
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(26),
            borderRadius: BorderRadius.circular(40.w),
          ),
          child: Icon(
            Icons.sms_outlined,
            size: 40.w,
            color: Theme.of(context).primaryColor,
          ),
        ),

        SizedBox(height: 24.h),

        // Title
        Text(
          _getTitle(),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 16.h),

        // Subtitle with phone number
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
            children: [
              TextSpan(text: _getSubtitle()),
              TextSpan(
                text: maskedPhoneNumber,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),

        SizedBox(height: 8.h),

        // Additional context based on purpose
        Text(
          _getContextMessage(),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';

    if (phoneNumber.length >= 8) {
      // Show first 3 and last 2 digits, mask the middle
      final start = phoneNumber.substring(0, 3);
      final end = phoneNumber.substring(phoneNumber.length - 2);
      final middle = '*' * (phoneNumber.length - 5);
      return '$start$middle$end';
    }

    return phoneNumber; // Return as-is if too short to mask
  }

  String _getTitle() {
    switch (purpose) {
      case 'registration':
        return 'Verify Your Number';
      case 'login':
        return 'Enter Verification Code';
      case 'password_reset':
        return 'Reset Password';
      default:
        return 'Verify Phone Number';
    }
  }

  String _getSubtitle() {
    switch (purpose) {
      case 'registration':
        return 'We\'ve sent a 6-digit verification code to ';
      case 'login':
        return 'Enter the 6-digit code sent to ';
      case 'password_reset':
        return 'Enter the verification code sent to ';
      default:
        return 'Please enter the code sent to ';
    }
  }

  String _getContextMessage() {
    switch (purpose) {
      case 'registration':
        return 'This helps us keep your account secure';
      case 'login':
        return 'Code expires in 10 minutes';
      case 'password_reset':
        return 'Use this code to reset your password';
      default:
        return 'Code expires in 10 minutes';
    }
  }
}
