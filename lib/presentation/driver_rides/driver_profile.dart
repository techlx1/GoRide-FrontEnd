import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../theme/app_theme.dart';
import '../../utils/toast_helper.dart';

class DriverProfile extends StatefulWidget {
  const DriverProfile({Key? key}) : super(key: key);

  @override
  State<DriverProfile> createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  Map<String, dynamic> driver = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '+592 611-2345',
    'vehicle': 'Toyota Axio',
    'plate': 'PWW 2345',
    'rating': 4.8,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.person, size: 60),
              ),
            ),
            SizedBox(height: 2.h),
            Center(
              child: Text(
                driver['name'],
                style:
                TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 3.h),
            _buildInfoTile('Email', driver['email']),
            _buildInfoTile('Phone', driver['phone']),
            _buildInfoTile('Vehicle', driver['vehicle']),
            _buildInfoTile('License Plate', driver['plate']),
            _buildInfoTile('Rating', '${driver['rating']} ⭐'),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                ToastHelper.showInfo('Profile update coming soon.');
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(color: Colors.grey, fontSize: 14)),
      subtitle: Text(value,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 16)),
    );
  }
}
