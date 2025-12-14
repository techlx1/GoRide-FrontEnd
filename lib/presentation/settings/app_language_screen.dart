import 'package:flutter/material.dart';
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

  void _updateLanguage(String lang) async {
    setState(() => _selected = lang);

    final res = await DriverApi.updateLanguage(languageCode: lang);

    if (res['success'] == true) {
      ToastHelper.showSuccess("Language updated");
    } else {
      ToastHelper.showError(res['message'] ?? "Failed to update language");
    }
  }

  Widget _langTile(String code, String label) {
    return ListTile(
      title: Text(
        label,
        style: GoogleFonts.inter(fontSize: 16),
      ),
      trailing: _selected == code
          ? const Icon(Icons.check_circle, color: Colors.blue)
          : null,
      onTap: () => _updateLanguage(code),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Language"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          _langTile("en", "English"),
          _langTile("es", "Spanish"),
          _langTile("pt", "Portuguese"),
        ],
      ),
    );
  }
}
