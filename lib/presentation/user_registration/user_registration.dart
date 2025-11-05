import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../utils/toast_helper.dart';
import './widgets/progress_header_widget.dart';
import './widgets/registration_form_widget.dart';
import './widgets/social_registration_widget.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({Key? key}) : super(key: key);

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  bool _isLoading = false;
  Map<String, dynamic> _formData = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onFormChanged(Map<String, dynamic> formData) {
    setState(() {
      _formData = formData;
    });
  }

  /// ✅ Handles registration via backend
  Future<void> _handleRegistration() async {
    if (!_formData['isValid']) {
      ToastHelper.showError('Please fill in all required fields correctly');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final normalizedUserType =
      _formData['userType'].toString().toLowerCase();

      final response = await ApiService.registerUser(
        _formData['fullName'] ?? '',
        _formData['email'] ?? '',
        _formData['phone'] ?? '',
        _formData['password'] ?? '',
        normalizedUserType,
      );

      if (response['success'] == true) {
        ToastHelper.showSuccess(
          'Account created successfully! Please verify your email.',
        );

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/otp-verification',
            arguments: {
              'email': _formData['email'],
              'userType': normalizedUserType,
            },
          );
        }
      } else {
        ToastHelper.showError(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      ToastHelper.showError('Registration failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleBackPressed() {
    Navigator.pushReplacementNamed(context, '/login-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ProgressHeaderWidget(
              onBackPressed: _handleBackPressed,
              currentStep: 1,
              totalSteps: 2,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),
                    Text(
                      'Create Your Account',
                      style: AppTheme.lightTheme.textTheme.headlineSmall
                          ?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Join RideGuyana and start your journey with us.',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    RegistrationFormWidget(
                      onFormChanged: _onFormChanged,
                      onSubmit: _handleRegistration,
                      isLoading: _isLoading,
                    ),
                    SizedBox(height: 4.h),
                    SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: ElevatedButton(
                        onPressed: (_formData['isValid'] == true && !_isLoading)
                            ? _handleRegistration
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          (_formData['isValid'] == true && !_isLoading)
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                          foregroundColor:
                          (_formData['isValid'] == true && !_isLoading)
                              ? AppTheme.lightTheme.colorScheme.onPrimary
                              : AppTheme.lightTheme.colorScheme
                              .onSurfaceVariant,
                          elevation:
                          (_formData['isValid'] == true && !_isLoading)
                              ? 2
                              : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                            : Text(
                          'Create Account',
                          style: AppTheme.lightTheme.textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    SocialRegistrationWidget(
                      onGoogleSignUp: () {},
                      onAppleSignUp: () {},
                      isLoading: _isLoading,
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
