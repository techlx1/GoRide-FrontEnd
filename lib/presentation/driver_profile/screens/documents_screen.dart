import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/driver_documents_widget.dart';
import '../../../utils/toast_helper.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;
  bool isUploading = false;
  double uploadProgress = 0.0;

  List<dynamic> documents = [];

  // Backend Base URL
  final String baseUrl = "https://g-ride-backend.onrender.com/api/driver";

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  // ==========================================================
  // LOAD DOCUMENTS FROM BACKEND
  // ==========================================================
  Future<void> _loadDocuments() async {
    try {
      setState(() => isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {"Authorization": "Bearer $token"},
      ));

      final res = await dio.get("/documents");

      if (res.data["success"] == true) {
        setState(() => documents = res.data["documents"] ?? []);
      } else {
        ToastHelper.showError("Failed to load documents");
      }
    } catch (e) {
      print("Error loading documents: $e");
      ToastHelper.showError("Unable to load documents.");
    }

    setState(() => isLoading = false);
  }

  // ==========================================================
  // ACTION SHEET: TAKE PHOTO OR GALLERY
  // ==========================================================
  Future<void> _pickAndUpload(String docType) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Upload Document",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),

                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take Photo"),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? img =
                    await _picker.pickImage(source: ImageSource.camera);

                    if (img != null) {
                      await _uploadDocument(File(img.path), docType);
                    }
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Choose from Gallery"),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? img =
                    await _picker.pickImage(source: ImageSource.gallery);

                    if (img != null) {
                      await _uploadDocument(File(img.path), docType);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // UPLOAD DOCUMENT → BACKEND
  // ==========================================================
  Future<void> _uploadDocument(File file, String docType) async {
    try {
      setState(() {
        isUploading = true;
        uploadProgress = 0.0;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {"Authorization": "Bearer $token"},
      ));

      FormData formData = FormData.fromMap({
        "docType": docType,
        "file": await MultipartFile.fromFile(file.path),
      });

      final res = await dio.post(
        "/documents/upload",
        data: formData,
        onSendProgress: (sent, total) {
          setState(() => uploadProgress = sent / total);
        },
      );

      if (res.data["success"] == true) {
        ToastHelper.showSuccess("Uploaded successfully!");
        await _loadDocuments();
      } else {
        ToastHelper.showError(res.data["message"] ?? "Upload failed");
      }
    } catch (e) {
      print("UPLOAD ERROR: $e");
      ToastHelper.showError("Upload error");
    }

    setState(() => isUploading = false);
  }

  // ==========================================================
  // UPLOAD BUTTON
  // ==========================================================
  Widget _uploadButton(String label, String docType) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.8.h),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isUploading ? null : () => _pickAndUpload(docType),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 1.7.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.sp),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.white),
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Driver Documents"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 📄 SHOW DOCUMENT LIST
            DriverDocumentsWidget(documents: documents),

            SizedBox(height: 3.h),

            /// 📤 UPLOAD PROGRESS
            if (isUploading) ...[
              LinearProgressIndicator(
                minHeight: 8,
                value: uploadProgress,
                color: Colors.green,
                backgroundColor: Colors.green.withOpacity(0.2),
              ),
              SizedBox(height: 2.h),
            ],

            /// 📤 UPLOAD BUTTONS
            _uploadButton("Upload License - Front", "license_front"),
            _uploadButton("Upload License - Back", "license_back"),
            _uploadButton(
                "Upload Vehicle Registration", "vehicle_registration"),

            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }
}
