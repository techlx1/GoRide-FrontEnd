import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class ProfileMenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showArrow;
  final Color? titleColor;
  final Color? iconColor;

  const ProfileMenuItemWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showArrow = false,
    this.titleColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme.colorScheme;

    return InkWell(
      onTap: onTap,
      splashColor: theme.primary.withOpacity(0.1),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: (iconColor ?? theme.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18.sp,
                color: iconColor ?? theme.primary,
              ),
            ),
            SizedBox(width: 4.w),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? theme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: theme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Optional arrow
            if (showArrow)
              Icon(Icons.arrow_forward_ios, size: 14.sp, color: theme.outline),
          ],
        ),
      ),
    );
  }
}
