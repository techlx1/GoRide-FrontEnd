import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class LoginFormWidget extends StatefulWidget {
  final Function(String emailOrPhone, String password) onLogin;
  final bool isLoading;

  const LoginFormWidget({
    Key? key,
    required this.onLogin,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isPhone(String input) {
    // Recognize +592 and standard formats
    final phoneRegex = RegExp(r'^\+?\d{7,15}$');
    return phoneRegex.hasMatch(input);
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onLogin(
        _emailOrPhoneController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email / Phone
          TextFormField(
            controller: _emailOrPhoneController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email or Phone Number',
              hintText: 'Enter your email or +592...',
              labelStyle: GoogleFonts.inter(
                fontSize: 13.sp,
                color: Colors.grey[700],
              ),
              prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.grey[50],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryLight),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your email or phone number';
              }
              final val = value.trim();
              if (!_isPhone(val) && !val.contains('@')) {
                return 'Enter a valid email or phone number';
              }
              return null;
            },
          ),
          SizedBox(height: 2.h),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              labelStyle: GoogleFonts.inter(
                fontSize: 13.sp,
                color: Colors.grey[700],
              ),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey[600],
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryLight),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password cannot be empty';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.isLoading
                  ? null
                  : () => Navigator.pushNamed(context, '/forgot-password'),
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.inter(
                  color: AppTheme.primaryLight,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 7.h,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isLoading
                    ? Colors.grey[400]
                    : AppTheme.primaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: widget.isLoading ? 0 : 3,
              ),
              child: widget.isLoading
                  ? const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              )
                  : Text(
                'Sign In',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
