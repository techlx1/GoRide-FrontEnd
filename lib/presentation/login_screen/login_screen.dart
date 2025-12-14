import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';
import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../services/api/auth_api.dart';
import '../../utils/toast_helper.dart';

// Widgets
import './widgets/app_logo_widget.dart';
import './widgets/biometric_login_widget.dart';
import './widgets/login_form_widget.dart';
import '../../providers/auth_providers.dart';   // ⭐ NEW: Riverpod driverId provider

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  bool _isBiometricAvailable = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isBiometricAvailable = true);
    }
  }

  /// 🔥 UPDATED LOGIN HANDLER (REMOVED FACEBOOK)
  Future<void> _handleLogin(String emailOrPhone, String password) async {
    setState(() => _isLoading = true);

    try {
      final response = await AuthApi.login(emailOrPhone, password);
      print("🟢 Login API Response: $response");

      if (response['success'] == true) {
        HapticFeedback.lightImpact();
        ToastHelper.showSuccess(response['message'] ?? "Login successful!");

        final prefs = await SharedPreferences.getInstance();

        /// 🔐 SAVE TOKEN
        final token = response['token'];
        if (token != null && token.toString().isNotEmpty) {
          await prefs.setString('auth_token', token.toString());
        } else {
          ToastHelper.showError("No token returned from server.");
          setState(() => _isLoading = false);
          return;
        }

        /// 👤 Save user_type
        final userType = (response['user']?['user_type'] ?? 'rider')
            .toString()
            .toLowerCase();
        await prefs.setString('user_type', userType);

        /// 🆔 Save user ID (driver or rider)
        if (response['user']?['id'] != null) {
          final userId = response['user']['id'].toString();
          await prefs.setString('user_id', userId);

          // ⭐ NEW: Update driverIdProvider if DRIVER
          if (userType == "driver") {
            ref.read(driverIdProvider.notifier).state = userId;
          }
        }

        /// 🚀 NAVIGATION
        if (userType == "driver") {
          Navigator.pushReplacementNamed(context, AppRoutes.driverDashboard);
        } else {
          Navigator.pushReplacementNamed(
              context, AppRoutes.rideBookingConfirmation);
        }
      } else {
        HapticFeedback.heavyImpact();
        ToastHelper.showError(response['message'] ?? "Invalid credentials.");
      }
    } catch (e) {
      ToastHelper.showError("Login failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 🔹 Biometric login placeholder
  Future<void> _handleBiometricLogin() async {
    ToastHelper.showInfo("Biometric login coming soon");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8.h),
                const AppLogoWidget(),
                SizedBox(height: 6.h),

                /// Welcome Text
                Text(
                  'Welcome!',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 20.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),

                Text(
                  'Sign in to continue your journey',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),

                /// Login Form
                LoginFormWidget(
                  onLogin: _handleLogin,
                  isLoading: _isLoading,
                ),

                /// Remember Me
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: _isLoading
                          ? null
                          : (value) => setState(() => _rememberMe = value ?? false),
                    ),
                    Expanded(
                      child: Text(
                        'Remember me on this device',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                /// 🔥 FACEBOOK REMOVED
                /// (Google & Apple login still available if needed later)

                /// Biometric Login
                BiometricLoginWidget(
                  onBiometricLogin: _handleBiometricLogin,
                  isAvailable: _isBiometricAvailable,
                ),

                SizedBox(height: 4.h),

                /// Register Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New user? ',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontSize: 14.sp,
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.userRegistration,
                      ),
                      child: Text(
                        'Sign Up',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
