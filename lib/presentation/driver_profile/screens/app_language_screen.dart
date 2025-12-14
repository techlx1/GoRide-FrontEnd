import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api/driver_api.dart';
import '../../utils/toast_helper.dart';

class AppLanguageScreen extends StatefulWidget {
  const AppLanguageScreen({Key? key}) : super(key: key);

  @override
  State<AppLanguageScreen> createState() => _AppLanguageScreenState();
}

class _AppLanguageScreenState extends State<AppLanguageScreen> {
  String _selected = "en";

  final Map<String, String> languageMap = {
    "en": "English",
    "es": "Spanish",
    "pt": "Portuguese",
  };

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selected = prefs.getString("app_language") ?? "en";
    });
  }

  Future<void> _changeLanguage(String code) async {
    setState(() => _selected = code);

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("app_language", code);

    // Update on backend
    final res = await DriverApi.updateLanguage(languageCode: code);

    if (res['success'] == true) {
      ToastHelper.showSuccess("Language updated to ${languageMap[code]}");
    } else {
      ToastHelper.showError(res['message'] ?? "Language update failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("App Language"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),

      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose your preferred language",
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: theme.onSurface,
              ),
            ),

            SizedBox(height: 3.h),

            ...languageMap.entries.map((entry) {
              return Container(
                margin: EdgeInsets.only(bottom: 2.h),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.h,
                  ),
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _selected == entry.key
                          ? Colors.blueAccent
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  title: Text(
                    entry.value,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: _selected == entry.key
                      ? Icon(Icons.check_circle, color: Colors.blueAccent, size: 20.sp)
                      : Icon(Icons.circle_outlined, color: theme.outline, size: 20.sp),
                  onTap: () => _changeLanguage(entry.key),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
