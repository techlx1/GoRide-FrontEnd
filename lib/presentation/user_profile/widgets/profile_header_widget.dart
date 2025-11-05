import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic>? profile;
  final VoidCallback? onEditPhoto;

  const ProfileHeaderWidget({
    Key? key,
    required this.profile,
    this.onEditPhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppTheme.lightTheme.colorScheme;
    final avatarUrl = profile?['avatar_url']; // Updated field name

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(5.w),
      child: Column(
        children: [
          // Profile photo
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 3),
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.person,
                          size: 40.sp, color: Colors.grey[400]),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.person,
                          size: 40.sp, color: Colors.grey[400]),
                    ),
                  )
                      : Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.person,
                        size: 40.sp, color: Colors.grey[400]),
                  ),
                ),
              ),
              if (onEditPhoto != null)
                Positioned(
                  bottom: 2.w,
                  right: 2.w,
                  child: GestureDetector(
                    onTap: onEditPhoto,
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.camera_alt,
                          size: 14.sp, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 2.h),

          // Full name
          Text(
            profile?['full_name'] ?? 'User Name',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          // Email
          Text(
            profile?['email'] ?? 'user@email.com',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          // Member since
          if (profile?['created_at'] != null)
            Text(
              'Member since ${_formatMemberSince(profile!['created_at'])}',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: Colors.grey[500],
              ),
            ),

          SizedBox(height: 2.h),

          // Role badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: _getRoleColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getRoleColor().withOpacity(0.3)),
            ),
            child: Text(
              _getRoleText(),
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: _getRoleColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Role badge colors and text
  Color _getRoleColor() {
    switch (profile?['role']) {
      case 'driver':
        return Colors.blue;
      case 'admin':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  String _getRoleText() {
    switch (profile?['role']) {
      case 'driver':
        return 'Driver';
      case 'admin':
        return 'Admin';
      default:
        return 'Rider';
    }
  }

  String _formatMemberSince(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
