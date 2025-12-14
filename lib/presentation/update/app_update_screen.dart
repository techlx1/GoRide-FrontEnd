import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api/driver_api.dart';
import '../../utils/toast_helper.dart';

class AppUpdateScreen extends StatefulWidget {
  const AppUpdateScreen({Key? key}) : super(key: key);

  @override
  State<AppUpdateScreen> createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen> {
  bool _loading = true;
  String? currentVersion = "1.0.0"; // Local app version
  String? latestVersion;
  bool forceUpdate = false;
  String? downloadUrl;

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    setState(() => _loading = true);

    final res = await DriverApi.getAppVersion();

    if (res['success'] == true) {
      setState(() {
        latestVersion = res['latest_version'] ?? "1.0.0";
        forceUpdate = res['force_update'] ?? false;
        downloadUrl = res['play_store_url'] ?? "";
        _loading = false;
      });
    } else {
      ToastHelper.showError(res['message'] ?? "Failed to check version");
      setState(() => _loading = false);
    }
  }

  Future<void> _openStore() async {
    if (downloadUrl == null || downloadUrl!.isEmpty) {
      ToastHelper.showError("No download link available.");
      return;
    }

    final uri = Uri.parse(downloadUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ToastHelper.showError("Unable to open link");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("App Update"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 4.h),

            Icon(
              Icons.system_update,
              size: 40.sp,
              color: Colors.blueAccent,
            ),

            SizedBox(height: 3.h),

            Text(
              "Current Version",
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: theme.onSurfaceVariant,
              ),
            ),
            Text(
              currentVersion ?? "---",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 3.h),

            Text(
              "Latest Version Available",
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: theme.onSurfaceVariant,
              ),
            ),
            Text(
              latestVersion ?? "---",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),

            SizedBox(height: 4.h),

            if (currentVersion == latestVersion)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  "Your app is up to date!",
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              )
            else
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      forceUpdate
                          ? "A critical update is required!"
                          : "A new update is available.",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _openStore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 1.8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Update Now",
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
          ],
        ),
      ),
    );
  }
}
