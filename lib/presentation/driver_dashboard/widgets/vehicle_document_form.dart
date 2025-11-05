import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/toast_helper.dart';
import '../../theme/app_theme.dart';

class VehicleDocumentForm extends StatefulWidget {
  const VehicleDocumentForm({Key? key}) : super(key: key);

  @override
  State<VehicleDocumentForm> createState() => _VehicleDocumentFormState();
}

class _VehicleDocumentFormState extends State<VehicleDocumentForm> {
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  bool _isUploading = false;

  final Map<String, XFile?> _selectedFiles = {};
  final Map<String, DateTime?> _expiryDates = {};
  final Map<String, String?> _uploadedUrls = {};

  final List<Map<String, String>> _docTypes = [
    {"key": "cert_of_fitness", "label": "Fitness Certificate"},
    {"key": "vehicle_insurance", "label": "Insurance"},
    {"key": "driver_licence", "label": "Driver Licence"},
    {"key": "revenue_licence", "label": "Revenue Licence"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchExistingDocs();
  }

  Future<void> _fetchExistingDocs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) return;

      final res = await supabase
          .from('vehicles')
          .select()
          .eq('driver_id', userId)
          .maybeSingle();

      if (res != null) {
        for (var doc in _docTypes) {
          final key = doc['key']!;
          _uploadedUrls[key] = res[key];
          final expiryStr = res['${key}_expiry'];
          if (expiryStr != null) {
            _expiryDates[key] = DateTime.tryParse(expiryStr.toString());
          }
        }
      }
    } catch (e) {
      ToastHelper.showError("Error fetching documents: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFile(String key) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedFiles[key] = picked);
    }
  }

  Future<void> _deleteFile(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null || _uploadedUrls[key] == null) return;

    final fileUrl = _uploadedUrls[key]!;
    final path = Uri.parse(fileUrl).pathSegments.skip(3).join('/');
    try {
      await supabase.storage.from('vehicle_documents').remove([path]);
      await supabase
          .from('vehicles')
          .update({key: null, '${key}_expiry': null})
          .eq('driver_id', userId);
      setState(() {
        _uploadedUrls[key] = null;
        _expiryDates[key] = null;
      });
      ToastHelper.showSuccess("Deleted $key successfully!");
    } catch (e) {
      ToastHelper.showError("Delete failed: $e");
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isUploading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null) {
      ToastHelper.showError('Missing driver session.');
      setState(() => _isUploading = false);
      return;
    }

    try {
      for (var entry in _selectedFiles.entries) {
        final file = File(entry.value!.path);
        final ext = file.path.split('.').last;
        final filePath =
            '$userId/${entry.key}_${DateTime.now().millisecondsSinceEpoch}.$ext';

        await supabase.storage.from('vehicle_documents').upload(filePath, file);
        final publicUrl = supabase.storage
            .from('vehicle_documents')
            .getPublicUrl(filePath);

        await supabase.from('vehicles').update({
          entry.key: publicUrl,
          '${entry.key}_expiry': _expiryDates[entry.key]?.toIso8601String(),
        }).eq('driver_id', userId);

        _uploadedUrls[entry.key] = publicUrl;
      }

      ToastHelper.showSuccess('Documents updated successfully!');
      setState(() => _selectedFiles.clear());
    } catch (e) {
      ToastHelper.showError("Upload failed: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildUploader(String key, String label) {
    final file = _selectedFiles[key];
    final expiry = _expiryDates[key];
    final uploadedUrl = _uploadedUrls[key];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),

            // --- Preview + Buttons ---
            if (uploadedUrl != null)
              Column(
                children: [
                  Image.network(uploadedUrl,
                      height: 150, width: double.infinity, fit: BoxFit.cover),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickFile(key),
                        icon: const Icon(Icons.refresh),
                        label: const Text("Replace"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _deleteFile(key),
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  file != null
                      ? Text("📄 ${file.name}",
                      style: const TextStyle(color: Colors.green))
                      : const Text("No file selected"),
                  ElevatedButton.icon(
                    onPressed: () => _pickFile(key),
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload"),
                  ),
                ],
              ),

            SizedBox(height: 1.h),

            // --- Expiry Date Picker ---
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18),
                SizedBox(width: 2.w),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: expiry ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate:
                      DateTime.now().add(const Duration(days: 365 * 3)),
                    );
                    if (picked != null) {
                      setState(() => _expiryDates[key] = picked);
                    }
                  },
                  child: Text(
                    expiry != null
                        ? DateFormat('yyyy-MM-dd').format(expiry)
                        : 'Select expiry date',
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Vehicle Documents"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          for (var doc in _docTypes)
            _buildUploader(doc['key']!, doc['label']!),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _submitForm,
            icon: const Icon(Icons.cloud_upload),
            label: _isUploading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Save Changes"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              minimumSize: Size(double.infinity, 6.h),
            ),
          ),
        ],
      ),
    );
  }
}
