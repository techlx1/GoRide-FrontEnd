import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialRegistrationWidget extends StatelessWidget {
  final VoidCallback onGoogleSignUp;
  final VoidCallback onAppleSignUp;
  final bool isLoading;

  const SocialRegistrationWidget({
    Key? key,
    required this.onGoogleSignUp,
    required this.onAppleSignUp,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),

        // Social registration buttons
        Text(
          'Continue with',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),

        // Google Sign Up Button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: OutlinedButton(
            onPressed: isLoading ? null : onGoogleSignUp,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.5),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomImageWidget(
                  imageUrl:
                      'https://developers.google.com/identity/images/g-logo.png',
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Continue with Google',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 2.h),

        // Apple Sign Up Button (iOS style)
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: OutlinedButton(
            onPressed: isLoading ? null : onAppleSignUp,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.black,
              side: const BorderSide(
                color: Colors.black,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'apple',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Continue with Apple',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
