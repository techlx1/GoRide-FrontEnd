import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../services/supabase_service.dart';

class AppDrawerWidget extends StatelessWidget {
  const AppDrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'User';
    final userEmail = user?.email ?? 'user@example.com';

    return Drawer(
      child: Column(
        children: [
          // Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 32.w,
                  backgroundColor: Colors.white,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.history,
                  title: 'Ride History',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to ride history
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.payment,
                  title: 'Payment Methods',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to payment methods
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.local_offer,
                  title: 'Promotions',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to promotions
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.support_agent,
                  title: 'Support & Help',
                  onTap: () {
                    Navigator.pop(context);
                    _showSupportOptions(context);
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.info,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to privacy policy
                  },
                ),
              ],
            ),
          ),

          // Emergency Button
          Container(
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showEmergencyDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                ),
                icon: const Icon(Icons.emergency),
                label: Text(
                  'Emergency',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Sign Out
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextButton(
              onPressed: () => _signOut(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8.w),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.w,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _showSupportOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Support & Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Call Support'),
              subtitle: const Text('+592-123-RIDE'),
              onTap: () {
                Navigator.pop(context);
                // Make call to support
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Email Support'),
              subtitle: const Text('help@rideguyana.com'),
              onTap: () {
                Navigator.pop(context);
                // Open email client
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.orange),
              title: const Text('Live Chat'),
              subtitle: const Text('Chat with our team'),
              onTap: () {
                Navigator.pop(context);
                // Open chat
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About RideGuyana'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RideGuyana - Your trusted ride partner',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            const Text(
              'Safe, reliable, and affordable rides across Georgetown and beyond. '
              'We connect you with professional drivers for all your transportation needs.',
            ),
            SizedBox(height: 16.h),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Emergency',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'In case of emergency, contact local authorities or use the emergency numbers below.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In production, integrate with emergency services
              // For now, show emergency numbers
              _showEmergencyNumbers(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Emergency Numbers',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyNumbers(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Numbers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.local_police, color: Colors.blue),
              title: const Text('Police'),
              subtitle: const Text('911'),
              trailing: IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {
                  // Make call to 911
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.local_hospital, color: Colors.red),
              title: const Text('Medical Emergency'),
              subtitle: const Text('913'),
              trailing: IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {
                  // Make call to 913
                },
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.local_fire_department, color: Colors.orange),
              title: const Text('Fire Department'),
              subtitle: const Text('912'),
              trailing: IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {
                  // Make call to 912
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await SupabaseService.instance.client.auth.signOut();
                Navigator.pop(context); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login-screen',
                  (route) => false,
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $error')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
