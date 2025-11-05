import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/toast_helper.dart';
import '../driver_wallet/driver_wallet_screen.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({Key? key}) : super(key: key);

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        ToastHelper.showError("Missing token. Please log in again.");
        Navigator.pop(context);
        return;
      }

      final response = await ApiService.getDriverEarnings(token);

      if (response['success'] == true) {
        setState(() {
          _stats = response['stats'];
          _isLoading = false;
        });
      } else {
        ToastHelper.showError(response['message'] ?? "Failed to load earnings");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ToastHelper.showError("Error loading earnings: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Earnings'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DriverWalletScreen()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadEarnings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              SizedBox(height: 2.h),
              _buildStatsRow(),
              SizedBox(height: 3.h),
              Text(
                "Performance Summary",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              _buildTripSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Earnings",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  "\$${_stats?['todayEarnings']?.toStringAsFixed(0) ?? '0'}",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text("Wallet"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DriverWalletScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem("Trips", _stats?['tripsCompleted'] ?? 0, Icons.local_taxi),
        _buildStatItem("Rating", _stats?['averageRating'] ?? 0.0, Icons.star),
        _buildStatItem("Hours", _stats?['hoursWorked'] ?? 0, Icons.timer),
      ],
    );
  }

  Widget _buildStatItem(String title, dynamic value, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        child: Padding(
          padding: EdgeInsets.all(2.w),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.lightTheme.colorScheme.primary),
              SizedBox(height: 1.h),
              Text(
                "$value",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: Colors.black,
                ),
              ),
              Text(title,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripSummary() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today, color: Colors.blue),
          title: const Text("Weekly Trips"),
          trailing: Text(
            "${_stats?['weeklyTrips'] ?? 0}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.attach_money, color: Colors.green),
          title: const Text("Weekly Earnings"),
          trailing: Text(
            "\$${_stats?['weeklyEarnings']?.toStringAsFixed(0) ?? '0'}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
