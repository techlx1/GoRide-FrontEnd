import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/api/driver_api.dart';
import '../../utils/toast_helper.dart';

class InviteFriendScreen extends StatefulWidget {
  const InviteFriendScreen({Key? key}) : super(key: key);

  @override
  State<InviteFriendScreen> createState() => _InviteFriendScreenState();
}

class _InviteFriendScreenState extends State<InviteFriendScreen> {
  String? referralCode;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReferral();
  }

  Future<void> _loadReferral() async {
    setState(() => _loading = true);

    final res = await DriverApi.createReferral();

    if (res['success'] == true) {
      setState(() {
        referralCode = res['referral_code'];
        _loading = false;
      });
    } else {
      ToastHelper.showError(res['message'] ?? "Failed to load referral code");
      setState(() => _loading = false);
    }
  }

  void _shareReferral() {
    if (referralCode == null) {
      ToastHelper.showError("Referral code not loaded");
      return;
    }

    final text =
        "Join G Ride and get rewards!\nUse my referral code: $referralCode\nDownload the app now.";

    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Invite a Friend"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 2.h),

            // Title
            Text(
              "Earn rewards for each friend you invite!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: theme.onSurface,
              ),
            ),

            SizedBox(height: 4.h),

            // Referral Code Display Box
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blueAccent, width: 1.5),
              ),
              child: Column(
                children: [
                  Text(
                    "Your Referral Code",
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: theme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    referralCode ?? "---",
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 5.h),

            // Share Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _shareReferral,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.share, color: Colors.white),
                label: Text(
                  "Share Invite Link",
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
