import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../services/user_profile_service.dart';
import './widgets/edit_profile_modal_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_menu_item_widget.dart';
import './widgets/profile_stats_widget.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final UserProfileService _profileService = UserProfileService();

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _userStats;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final profile = await _profileService.getCurrentUserProfile();
      final stats = await _profileService.getUserStatistics();

      setState(() {
        _userProfile = profile;
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshProfile() async => await _loadAllData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryLight,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppTheme.primaryLight),
            onPressed: _showEditProfileModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? _buildErrorState()
          : RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header
              Container(
                color: Colors.white,
                child: ProfileHeaderWidget(
                  profile: _userProfile,
                  onEditPhoto: _changeProfilePhoto,
                ),
              ),

              SizedBox(height: 8.h),

              // Stats
              if (_userStats != null)
                Container(
                  color: Colors.white,
                  child: ProfileStatsWidget(stats: _userStats!),
                ),

              SizedBox(height: 8.h),

              _buildPersonalInfoSection(),
              SizedBox(height: 8.h),
              _buildPreferencesSection(),
              SizedBox(height: 8.h),
              _buildSupportSection(),
              SizedBox(height: 8.h),
              _buildAccountSection(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI SECTION BUILDERS ----------

  Widget _buildErrorState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
        SizedBox(height: 2.h),
        Text('Failed to load profile',
            style: GoogleFonts.inter(fontSize: 16.sp)),
        SizedBox(height: 2.h),
        ElevatedButton(onPressed: _loadAllData, child: const Text('Retry')),
      ],
    ),
  );

  Widget _buildPersonalInfoSection() => _buildCardSection(
    'Personal Information',
    [
      ProfileMenuItemWidget(
        icon: Icons.person_outline,
        title: 'Full Name',
        subtitle: _userProfile?['full_name'] ?? 'Not set',
        onTap: _showEditProfileModal,
      ),
      ProfileMenuItemWidget(
        icon: Icons.email_outlined,
        title: 'Email',
        subtitle: _userProfile?['email'] ?? 'Not set',
        onTap: _changeEmail,
      ),
      ProfileMenuItemWidget(
        icon: Icons.phone_outlined,
        title: 'Phone Number',
        subtitle: _userProfile?['phone'] ?? 'Not set',
        onTap: _showEditProfileModal,
      ),
    ],
  );

  Widget _buildPreferencesSection() => _buildCardSection(
    'Preferences',
    [
      ProfileMenuItemWidget(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'Manage notifications',
        onTap: () => _showToast('Coming soon'),
      ),
      ProfileMenuItemWidget(
        icon: Icons.language_outlined,
        title: 'Language',
        subtitle: 'English',
        onTap: () => _showToast('Coming soon'),
      ),
    ],
  );

  Widget _buildSupportSection() => _buildCardSection(
    'Support & Legal',
    [
      ProfileMenuItemWidget(
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'Get help with your account',
        onTap: () => _showToast('Coming soon'),
      ),
      ProfileMenuItemWidget(
        icon: Icons.article_outlined,
        title: 'Terms of Service',
        subtitle: 'View terms and conditions',
        onTap: () => _showToast('Coming soon'),
      ),
    ],
  );

  Widget _buildAccountSection() => _buildCardSection(
    'Account Actions',
    [
      ProfileMenuItemWidget(
        icon: Icons.lock_outline,
        title: 'Change Password',
        subtitle: 'Update your password',
        onTap: _changePassword,
      ),
      ProfileMenuItemWidget(
        icon: Icons.logout,
        title: 'Sign Out',
        subtitle: 'Log out of your account',
        titleColor: Colors.red,
        onTap: _signOut,
      ),
      ProfileMenuItemWidget(
        icon: Icons.delete_outline,
        title: 'Delete Account',
        subtitle: 'Permanently delete your account',
        titleColor: Colors.red,
        onTap: _deleteAccount,
      ),
    ],
  );

  Widget _buildCardSection(String title, List<Widget> items) => Container(
    color: Colors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.sp),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...items,
      ],
    ),
  );

  // ---------- ACTION METHODS ----------

  void _showEditProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileModalWidget(
        profile: _userProfile,
        onSave: (updatedProfile) async {
          try {
            await _profileService.updateProfile(
              fullName: updatedProfile['full_name'] ?? '',
              phoneNumber: updatedProfile['phone'],
              dateOfBirth: updatedProfile['date_of_birth'] != null
                  ? DateTime.parse(updatedProfile['date_of_birth'])
                  : null,
            );
            await _loadAllData();
            _showToast('Profile updated successfully');
          } catch (e) {
            _showToast('Failed to update profile: $e', isError: true);
          }
        },
      ),
    );
  }

  Future<void> _changeProfilePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _showToast('Photo upload feature coming soon');
    }
  }

  void _changeEmail() {
    _showInputDialog(
      title: 'Change Email',
      hintText: 'Enter new email',
      onSubmit: (val) async {
        try {
          await _profileService.updateEmail(val);
          await _loadAllData();
          _showToast('Email updated successfully');
        } catch (e) {
          _showToast('Failed to update email: $e', isError: true);
        }
      },
    );
  }

  void _changePassword() {
    _showInputDialog(
      title: 'Change Password',
      hintText: 'Enter new password',
      obscureText: true,
      onSubmit: (val) async {
        try {
          await _profileService.updatePassword(val);
          _showToast('Password updated successfully');
        } catch (e) {
          _showToast('Failed to update password: $e', isError: true);
        }
      },
    );
  }

  void _signOut() async {
    try {
      await _profileService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/login-screen', (route) => false);
      }
    } catch (e) {
      _showToast('Failed to sign out: $e', isError: true);
    }
  }

  void _deleteAccount() async {
    try {
      await _profileService.deleteAccount();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/login-screen', (route) => false);
      }
    } catch (e) {
      _showToast('Failed to delete account: $e', isError: true);
    }
  }

  // ---------- HELPERS ----------

  void _showInputDialog({
    required String title,
    required String hintText,
    bool obscureText = false,
    required Function(String) onSubmit,
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hintText),
          obscureText: obscureText,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onSubmit(controller.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? Colors.red : AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
