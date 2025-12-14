import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../services/api/earnings_api.dart';
import '../../../utils/toast_helper.dart';
import '../widgets/earnings_summary_card.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> earningsData = {};
  String? token;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("auth_token");

    if (token == null) {
      ToastHelper.showError("Authentication error. Please log in again.");
      Navigator.pop(context);
      return;
    }

    _fetchEarnings();
  }

  Future<void> _fetchEarnings() async {
    setState(() => _isLoading = true);

    // Corrected – ONLY send token
    final res = await EarningsApi.getEarnings(
      token: token!,
    );

    if (res["success"] == true) {
      setState(() {
        earningsData = res["data"] ?? {};
        _isLoading = false;
      });
    } else {
      ToastHelper.showError(res["message"] ?? "Failed to load earnings");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          "Earnings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchEarnings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Earnings Summary Header
              EarningsSummaryCard(earnings: {
                "today": earningsData["todayEarnings"] ?? 0,
                "week": earningsData["weekEarnings"] ?? 0,
                "month": earningsData["monthEarnings"] ?? 0,
                "total": earningsData["totalEarnings"] ?? 0,
              }),

              SizedBox(height: 2.h),

              /// Quick Stats (Completed Rides + Pending Payments)
              _buildQuickStats(),

              SizedBox(height: 3.h),

              /// Recent Earnings List
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // QUICK STATS ROW
  // ----------------------------------------------------------
  Widget _buildQuickStats() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            "Completed\nTrips",
            (earningsData["completedRides"] ?? 0).toString(),
            Icons.check_circle,
            Colors.green,
          ),
          _statItem(
            "Pending\nPayments",
            (earningsData["pendingPayments"] ?? 0).toString(),
            Icons.pending_actions,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26.sp),
        SizedBox(height: 0.8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 0.4.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // RECENT TRANSACTIONS LIST
  // ----------------------------------------------------------
  Widget _buildRecentTransactions() {
    final history = earningsData["history"] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Earnings",
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 1.h),

        if (history.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "No recent earnings available",
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (_, i) {
              final item = history[i];

              return Container(
                margin: EdgeInsets.only(bottom: 1.5.h),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item["date"] ?? "",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 10.sp,
                      ),
                    ),
                    Text(
                      "G\$${item["amount"]}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
