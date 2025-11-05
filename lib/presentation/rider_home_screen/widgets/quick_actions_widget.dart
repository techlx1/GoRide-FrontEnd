import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';


class QuickActionsWidget extends StatelessWidget {
  final Position? currentLocation;
  final Function(String address, LatLng location) onLocationSelected;

  const QuickActionsWidget({
    Key? key,
    required this.currentLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context: context,
                icon: Icons.home,
                title: 'Home',
                subtitle: 'Set home address',
                onTap: () => _selectHomeLocation(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildQuickActionCard(
                context: context,
                icon: Icons.work,
                title: 'Work',
                subtitle: 'Set work address',
                onTap: () => _selectWorkLocation(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildQuickActionCard(
                context: context,
                icon: Icons.history,
                title: 'Recent',
                subtitle: 'View recent trips',
                onTap: () => _showRecentLocations(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Promotional Banner
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withAlpha(204),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Row(
            children: [
              Icon(
                Icons.local_offer,
                color: Colors.white,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get 20% off your next ride',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Use code: RIDE20',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Apply promo code
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Promo code applied!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
                child: Text(
                  'Apply',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24.w,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _selectHomeLocation() {
    // Pre-defined home location (can be customized)
    const homeLocation = LatLng(6.8103, -58.1598); // Georgetown area
    onLocationSelected('Home - Main Street, Georgetown', homeLocation);
  }

  void _selectWorkLocation() {
    // Pre-defined work location (can be customized)
    const workLocation = LatLng(6.8264, -58.1441); // Thomas Lands area
    onLocationSelected('Work - Thomas Lands, Georgetown', workLocation);
  }

  void _showRecentLocations(BuildContext context) {
    // Mock recent locations
    final recentLocations = [
      {
        'name': 'Stabroek Market',
        'address': 'Water Street, Georgetown',
        'time': '2 hours ago',
        'location': const LatLng(6.8206, -58.1624),
      },
      {
        'name': 'Georgetown Hospital',
        'address': 'New Market Street',
        'time': 'Yesterday',
        'location': const LatLng(6.8083, -58.1598),
      },
      {
        'name': 'City Mall',
        'address': 'Regent Street',
        'time': '3 days ago',
        'location': const LatLng(6.8047, -58.1598),
      },
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Locations',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentLocations.length,
              separatorBuilder: (context, index) => Divider(height: 24.h),
              itemBuilder: (context, index) {
                final location = recentLocations[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withAlpha(26),
                    child: Icon(
                      Icons.history,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Text(
                    location['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(location['address'] as String),
                      Text(
                        location['time'] as String,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16.w,
                    color: Colors.grey[400],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onLocationSelected(
                      location['address'] as String,
                      location['location'] as LatLng,
                    );
                  },
                );
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
