import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../services/api/driver_api.dart';
import '../../utils/toast_helper.dart';

class AppSuggestionsScreen extends StatefulWidget {
  const AppSuggestionsScreen({Key? key}) : super(key: key);

  @override
  State<AppSuggestionsScreen> createState() => _AppSuggestionsScreenState();
}

class _AppSuggestionsScreenState extends State<AppSuggestionsScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ToastHelper.showError("Please enter your suggestion.");
      return;
    }

    setState(() => _sending = true);

    final res = await DriverApi.sendSuggestion(message: text);

    setState(() => _sending = false);

    if (res['success'] == true) {
      ToastHelper.showSuccess(res['message'] ?? "Suggestion sent. Thank you!");
      _controller.clear();
    } else {
      ToastHelper.showError(res['message'] ?? "Failed to send suggestion");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("App Suggestions"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Help us improve G-Ride!",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: theme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "Share your ideas, bug reports, or feature requests.",
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: theme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Type your suggestion here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 1.7.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _sending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Send Suggestion",
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
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
