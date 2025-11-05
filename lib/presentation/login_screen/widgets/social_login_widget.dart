import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginWidget extends StatelessWidget {
  final bool isLoading;
  final Function(String provider) onSocialLogin;

  const SocialLoginWidget({
    Key? key,
    required this.isLoading,
    required this.onSocialLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Social Login Buttons
        Column(
          children: [
            // Google Login Button
            _buildSocialButton(
              context: context,
              provider: 'Google',
              iconName: 'g_translate',
              backgroundColor: Colors.white,
              textColor: AppTheme.lightTheme.colorScheme.onSurface,
              borderColor: AppTheme.lightTheme.colorScheme.outline,
            ),

            SizedBox(height: 1.5.h),

            // Apple Login Button (iOS style)
            _buildSocialButton(
              context: context,
              provider: 'Apple',
              iconName: 'apple',
              backgroundColor: Colors.black,
              textColor: Colors.white,
              borderColor: Colors.black,
            ),

            SizedBox(height: 1.5.h),

            // Facebook Login Button
            _buildSocialButton(
              context: context,
              provider: 'Facebook',
              iconName: 'facebook',
              backgroundColor: const Color(0xFF1877F2),
              textColor: Colors.white,
              borderColor: const Color(0xFF1877F2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String provider,
    required String iconName,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return SizedBox(
      height: 6.h,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : () => onSocialLogin(provider),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: textColor,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              'Continue with $provider',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
