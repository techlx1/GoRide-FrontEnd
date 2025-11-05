import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class EditProfileModalWidget extends StatefulWidget {
  final Map<String, dynamic>? profile;
  final Function(Map<String, dynamic>) onSave;

  const EditProfileModalWidget({
    Key? key,
    required this.profile,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditProfileModalWidget> createState() => _EditProfileModalWidgetState();
}

class _EditProfileModalWidgetState extends State<EditProfileModalWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: widget.profile?['full_name'] ?? '');
    _phoneController =
        TextEditingController(text: widget.profile?['phone'] ?? '');
    if (widget.profile?['date_of_birth'] != null) {
      try {
        _selectedDate = DateTime.parse(widget.profile!['date_of_birth']);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.5.h),
            width: 40.w,
            height: 0.8.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Profile',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Full Name'),
                    _buildTextField(
                      controller: _fullNameController,
                      hint: 'Enter your full name',
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 2.5.h),

                    _buildLabel('Phone Number'),
                    _buildTextField(
                      controller: _phoneController,
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 2.5.h),

                    _buildLabel('Date of Birth'),
                    _buildDatePicker(),
                    SizedBox(height: 4.h),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          padding: EdgeInsets.symmetric(vertical: 1.8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: EdgeInsets.only(bottom: 0.8.h),
    child: Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: Colors.grey[700],
      ),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
          BorderSide(color: AppTheme.lightTheme.colorScheme.primary),
        ),
        contentPadding:
        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'Select date of birth',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: _selectedDate != null
                    ? Colors.black87
                    : Colors.grey[500],
              ),
            ),
            Icon(Icons.calendar_today, size: 18.sp, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
      _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = {
        'full_name': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'date_of_birth': _selectedDate?.toIso8601String(),
      };
      widget.onSave(updatedProfile);
      Navigator.pop(context);
    }
  }
}
