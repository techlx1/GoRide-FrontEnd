import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationFormWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFormChanged;
  final VoidCallback onSubmit;
  final bool isLoading;

  const RegistrationFormWidget({
    Key? key,
    required this.onFormChanged,
    required this.onSubmit,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<RegistrationFormWidget> createState() => _RegistrationFormWidgetState();
}

class _RegistrationFormWidgetState extends State<RegistrationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;
  String _selectedUserType = 'rider';
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    _checkPasswordStrength(_passwordController.text);
    final formData = {
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim().toLowerCase(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
      'userType': _selectedUserType,
      'termsAccepted': _termsAccepted,
      'privacyAccepted': _privacyAccepted,
      'isValid': _isFormValid(),
    };
    widget.onFormChanged(formData);
  }

  bool _isFormValid() {
    return _fullNameController.text.trim().isNotEmpty &&
        _emailController.text.trim().contains('@') &&
        _phoneController.text.trim().length >= 7 &&
        _passwordController.text.length >= 8 &&
        _termsAccepted &&
        _privacyAccepted;
  }

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    setState(() {
      switch (strength) {
        case 0:
        case 1:
          _passwordStrength = 'Weak';
          _passwordStrengthColor = AppTheme.lightTheme.colorScheme.error;
          break;
        case 2:
        case 3:
          _passwordStrength = 'Medium';
          _passwordStrengthColor = Colors.orange;
          break;
        case 4:
        case 5:
          _passwordStrength = 'Strong';
          _passwordStrengthColor = Colors.green;
          break;
      }
    });
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final email = value.trim().toLowerCase();
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phone = value.trim();
    if (phone.length < 7) {
      return 'Please enter a valid phone number';
    }
    // Validate it's only digits
    if (!RegExp(r'^\d{7}$').hasMatch(phone)) {
      return 'Phone number must be exactly 7 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name Field
          Text(
            'Full Name',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _fullNameController,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'person',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
            validator: _validateFullName,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: 3.h),

          // Email Field
          Text(
            'Email Address',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _emailController,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'email',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
            validator: _validateEmail,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
          ),
          SizedBox(height: 3.h),

          // Phone Number Field
          Text(
            'Phone Number',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _phoneController,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              hintText: 'Enter phone number',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+592',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      width: 1,
                      height: 4.h,
                      color: AppTheme.lightTheme.colorScheme.outline,
                    ),
                    SizedBox(width: 2.w),
                  ],
                ),
              ),
            ),
            validator: _validatePhone,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(7),
            ],
          ),
          SizedBox(height: 3.h),

          // Password Field
          Text(
            'Password',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _passwordController,
            enabled: !widget.isLoading,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Create a strong password',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: CustomIconWidget(
                  iconName:
                      _isPasswordVisible ? 'visibility_off' : 'visibility',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
            validator: _validatePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => widget.onSubmit(),
          ),

          // Password Strength Indicator
          _passwordStrength.isNotEmpty
              ? Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Row(
                  children: [
                    Text(
                      'Password strength: ',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                    Text(
                      _passwordStrength,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: _passwordStrengthColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
              : const SizedBox.shrink(),
          SizedBox(height: 4.h),

          // User Type Selection
          Text(
            'I want to',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap:
                        widget.isLoading
                            ? null
                            : () {
                              setState(() {
                                _selectedUserType = 'rider';
                              });
                              _onFormChanged();
                            },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      decoration: BoxDecoration(
                        color:
                            _selectedUserType == 'rider'
                                ? AppTheme.lightTheme.colorScheme.primary
                                : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'directions_car',
                            color:
                                _selectedUserType == 'rider'
                                    ? AppTheme.lightTheme.colorScheme.onPrimary
                                    : AppTheme
                                        .lightTheme
                                        .colorScheme
                                        .onSurfaceVariant,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Book Rides',
                            style: AppTheme.lightTheme.textTheme.labelLarge
                                ?.copyWith(
                                  color:
                                      _selectedUserType == 'rider'
                                          ? AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .onPrimary
                                          : AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap:
                        widget.isLoading
                            ? null
                            : () {
                              setState(() {
                                _selectedUserType = 'driver';
                              });
                              _onFormChanged();
                            },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      decoration: BoxDecoration(
                        color:
                            _selectedUserType == 'driver'
                                ? AppTheme.lightTheme.colorScheme.primary
                                : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'local_taxi',
                            color:
                                _selectedUserType == 'driver'
                                    ? AppTheme.lightTheme.colorScheme.onPrimary
                                    : AppTheme
                                        .lightTheme
                                        .colorScheme
                                        .onSurfaceVariant,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Drive & Earn',
                            style: AppTheme.lightTheme.textTheme.labelLarge
                                ?.copyWith(
                                  color:
                                      _selectedUserType == 'driver'
                                          ? AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .onPrimary
                                          : AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),

          // Terms and Privacy Checkboxes
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _termsAccepted,
                onChanged:
                    widget.isLoading
                        ? null
                        : (value) {
                          setState(() {
                            _termsAccepted = value ?? false;
                          });
                          _onFormChanged();
                        },
              ),
              Expanded(
                child: GestureDetector(
                  onTap:
                      widget.isLoading
                          ? null
                          : () {
                            setState(() {
                              _termsAccepted = !_termsAccepted;
                            });
                            _onFormChanged();
                          },
                  child: Padding(
                    padding: EdgeInsets.only(top: 2.w),
                    child: RichText(
                      text: TextSpan(
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _privacyAccepted,
                onChanged:
                    widget.isLoading
                        ? null
                        : (value) {
                          setState(() {
                            _privacyAccepted = value ?? false;
                          });
                          _onFormChanged();
                        },
              ),
              Expanded(
                child: GestureDetector(
                  onTap:
                      widget.isLoading
                          ? null
                          : () {
                            setState(() {
                              _privacyAccepted = !_privacyAccepted;
                            });
                            _onFormChanged();
                          },
                  child: Padding(
                    padding: EdgeInsets.only(top: 2.w),
                    child: RichText(
                      text: TextSpan(
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
