import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BiometricLoginWidget extends StatefulWidget {
  final Function() onBiometricLogin;
  final bool isAvailable;

  const BiometricLoginWidget({
    Key? key,
    required this.onBiometricLogin,
    required this.isAvailable,
  }) : super(key: key);

  @override
  State<BiometricLoginWidget> createState() => _BiometricLoginWidgetState();
}

class _BiometricLoginWidgetState extends State<BiometricLoginWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleBiometricAuth() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Add haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Simulate biometric authentication process
      await Future.delayed(const Duration(milliseconds: 1500));

      // Call the callback function
      widget.onBiometricLogin();

      // Success haptic feedback
      HapticFeedback.heavyImpact();
    } catch (e) {
      // Error haptic feedback
      HapticFeedback.heavyImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric authentication failed. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAvailable) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 2.h),

        // Biometric Authentication Button
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: _isAuthenticating ? null : _handleBiometricAuth,
                    child: Center(
                      child: _isAuthenticating
                          ? SizedBox(
                              width: 6.w,
                              height: 6.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            )
                          : CustomIconWidget(
                              iconName: 'fingerprint',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 8.w,
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: 1.h),

        // Biometric Login Text
        Text(
          _isAuthenticating ? 'Authenticating...' : 'Use Biometric Login',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}