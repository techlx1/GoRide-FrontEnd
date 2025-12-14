import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/api/driver_api.dart';
import '../utils/toast_helper.dart';

class VersionChecker {
  static Future<void> checkAppVersion(BuildContext context) async {
    final package = await PackageInfo.fromPlatform();
    final currentVersion = package.version;

    final res = await DriverApi.getAppVersion();

    if (res['success'] != true) return;

    final latest = res['latest_version'];
    final minSupported = res['min_supported_version'];
    final updateUrl = res['update_url'];

    // Force update
    if (_isVersionLower(currentVersion, minSupported)) {
      _showUpdateDialog(context, updateUrl, mandatory: true);
      return;
    }

    // Optional update
    if (_isVersionLower(currentVersion, latest)) {
      _showUpdateDialog(context, updateUrl, mandatory: false);
    }
  }

  static bool _isVersionLower(String current, String target) {
    final c = current.split('.').map(int.parse).toList();
    final t = target.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (c[i] < t[i]) return true;
      if (c[i] > t[i]) return false;
    }
    return false;
  }

  static void _showUpdateDialog(BuildContext context, String url, {bool mandatory = false}) {
    showDialog(
      barrierDismissible: !mandatory,
      context: context,
      builder: (_) => AlertDialog(
        title: Text(mandatory ? "Update Required" : "Update Available"),
        content: Text(
          mandatory
              ? "You must update the app to continue using G-Ride."
              : "A new version of G-Ride is available.",
        ),
        actions: [
          if (!mandatory)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Later"),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              launchUrl(Uri.parse(url));
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
