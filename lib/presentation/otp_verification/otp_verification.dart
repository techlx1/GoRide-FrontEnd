import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../services/otp_service.dart';
import './widgets/otp_header_widget.dart';
import './widgets/otp_timer_widget.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({Key? key}) : super(key: key);

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> with CodeAutoFill {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final OtpService _otpService = OtpService();

  String? _phoneNumber;
  String? _purpose;
  String? _returnRoute;
  bool _isLoading = false;
  bool _isResendLoading = false;
  String? _errorMessage;
  String? _demoOtp; // For demo purposes

  // Timer state
  bool _canResend = false;
  int _timerDuration = 60; // 60 seconds

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();

    // Auto-fill setup for SMS
    _initSmsListener();

    // Extract arguments after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        setState(() {
          _phoneNumber = arguments['phone_number'] as String?;
          _purpose = arguments['purpose'] as String? ?? 'registration';
          _returnRoute = arguments['return_route'] as String?;
          _demoOtp = arguments['demo_otp'] as String?; // For demo
        });
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  void _initSmsListener() {
    // Initialize SMS auto-fill
    SmsAutoFill().listenForCode();
  }

  @override
  void codeUpdated() {
    // Auto-fill callback from SMS
    if (code != null && code!.length == 6) {
      _pinController.text = code!;
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    if (_pinController.text.length != 6) {
      _showError('Please enter a 6-digit OTP code');
      return;
    }

    if (_phoneNumber == null) {
      _showError('Phone number not provided');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _otpService.verifyOtp(
        phoneNumber: _phoneNumber!,
        otpCode: _pinController.text,
        purpose: _purpose ?? 'registration',
      );

      // Verification successful
      _showSuccessAndNavigate();
    } catch (error) {
      _showError('Verification failed: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    if (_phoneNumber == null) return;

    setState(() {
      _isResendLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _otpService.resendOtp(
        phoneNumber: _phoneNumber!,
        purpose: _purpose ?? 'registration',
      );

      // Update demo OTP for testing
      if (response['demo_otp'] != null) {
        setState(() {
          _demoOtp = response['demo_otp'];
        });
      }

      _showSuccess('New OTP sent successfully!');

      // Reset timer
      setState(() {
        _canResend = false;
        _timerDuration = 60;
      });
    } catch (error) {
      _showError('Failed to resend OTP: $error');
    } finally {
      setState(() {
        _isResendLoading = false;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });

    // Clear the PIN on error
    _pinController.clear();

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessAndNavigate() {
    // Haptic feedback for success
    HapticFeedback.mediumImpact();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phone number verified successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Navigate based on purpose and return route
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_returnRoute != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          _returnRoute!,
          (route) => false,
        );
      } else {
        switch (_purpose) {
          case 'registration':
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/rider-home-screens',
              (route) => false,
            );
            break;
          case 'login':
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/rider-home-screens',
              (route) => false,
            );
            break;
          case 'password_reset':
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login-screens',
              (route) => false,
            );
            break;
          default:
            Navigator.pop(context);
        }
      }
    });
  }

  void _onTimerComplete() {
    setState(() {
      _canResend = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Custom theme for Pinput
    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 56.w,
      textStyle: TextStyle(
        fontSize: 20.sp,
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: Colors.grey[300]!),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Theme.of(context).primaryColor, width: 2),
      borderRadius: BorderRadius.circular(8.w),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Colors.white,
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.red, width: 2),
      borderRadius: BorderRadius.circular(8.w),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20.w,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // Header
              OtpHeaderWidget(
                phoneNumber: _phoneNumber ?? '',
                purpose: _purpose ?? 'registration',
              ),

              SizedBox(height: 40.h),

              // OTP Input
              Pinput(
                controller: _pinController,
                focusNode: _focusNode,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                errorPinTheme: _errorMessage != null ? errorPinTheme : null,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                cursor: Container(
                  width: 2.w,
                  height: 24.h,
                  color: Theme.of(context).primaryColor,
                ),
                onCompleted: (pin) {
                  if (pin.length == 6) {
                    _verifyOtp();
                  }
                },
                onChanged: (pin) {
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
              ),

              SizedBox(height: 16.h),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8.w),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 20.w,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 24.h),

              // Timer and Resend
              OtpTimerWidget(
                duration: _timerDuration,
                canResend: _canResend,
                isResendLoading: _isResendLoading,
                onResend: _resendOtp,
                onTimerComplete: _onTimerComplete,
              ),

              const Spacer(),

              // Demo OTP Display (for testing)
              if (_demoOtp != null)
                Container(
                  margin: EdgeInsets.only(bottom: 20.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8.w),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Demo OTP (for testing):',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SelectableText(
                        _demoOtp!,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || _pinController.text.length != 6
                      ? null
                      : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 16.h),

              // Help Text
              Text(
                'Didn\'t receive the code? Check your SMS or try resending.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
