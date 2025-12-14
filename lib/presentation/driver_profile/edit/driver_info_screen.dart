import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import '../../../services/api/driver_api.dart';

class DriverInfoScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const DriverInfoScreen({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<DriverInfoScreen> createState() => _DriverInfoScreenState();
}

class _DriverInfoScreenState extends State<DriverInfoScreen> {
  bool isEditing = false;

  final nameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  String gender = "Male";

  File? profileImage;      // <<< NEW
  String? remotePhotoUrl;  // <<< NEW

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  void _loadDriverData() {
    final fullName = widget.data["full_name"] ?? "";
    final parts = fullName.split(" ");

    nameCtrl.text = parts.isNotEmpty ? parts[0] : "";
    lastNameCtrl.text = parts.length > 1 ? parts[1] : "";

    phoneCtrl.text = widget.data["phone"] ?? "";
    emailCtrl.text = widget.data["email"] ?? "";
    dobCtrl.text = widget.data["date_of_birth"] ?? "Not set";
    gender = widget.data["gender"] ?? "Male";

    remotePhotoUrl = widget.data["profile_photo_url"];
  }

  // ==========================
  // PICK IMAGE
  // ==========================
  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        profileImage = File(img.path);
      });
    }
  }

  // ==========================
  // UPLOAD IMAGE
  // ==========================
  Future<void> saveChanges() async {
    if (profileImage != null) {
      final result = await DriverApi.uploadProfilePhoto(profileImage!);

      if (result["success"] == true) {
        setState(() {
          remotePhotoUrl = result["photo_url"];
        });
      }
    }

    setState(() => isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7EDE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7DA48E),
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEditing ? "Editing" : "Profile",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: () => setState(() => isEditing = false),
              child:
              const Text("Cancel", style: TextStyle(color: Colors.white)),
            )
        ],
      ),

      body: Column(
        children: [
          // TOP CARD
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 3.h, left: 5.w, right: 5.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: isEditing ? pickProfileImage : null,
                  child: CircleAvatar(
                    radius: 40.sp,
                    backgroundColor: Colors.grey.shade300,

                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : (remotePhotoUrl != null
                        ? NetworkImage(remotePhotoUrl!)
                        : null),
                    child:
                    (profileImage == null && remotePhotoUrl == null)
                        ? const Icon(Icons.person,
                        size: 60, color: Colors.grey)
                        : null,
                  ),
                ),

                if (isEditing)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Text(
                      "Tap to upload photo",
                      style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                    ),
                  ),

                SizedBox(height: 2.h),

                if (!isEditing)
                  Text(
                    "${nameCtrl.text} ${lastNameCtrl.text}",
                    style: TextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),

                SizedBox(height: 2.h),
              ],
            ),
          ),

          // FORM FIELDS
          Expanded(
            child: SingleChildScrollView(
              padding:
              EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEditing) _buildField("First Name", nameCtrl),
                  if (isEditing) _buildField("Last Name", lastNameCtrl),

                  if (isEditing) _genderSelector(),
                  if (!isEditing) _displayInfo("Gender", gender),

                  _displayInfo("Phone Number", phoneCtrl.text),
                  _displayInfo("Date of Birth", dobCtrl.text),
                  _displayInfo("E-Mail", emailCtrl.text),

                  SizedBox(height: 3.h),

                  if (isEditing)
                    Center(
                      child: ElevatedButton(
                        onPressed: saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7DA48E),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 2.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Save"),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: !isEditing
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF7DA48E),
        child: const Icon(Icons.edit, color: Colors.white),
        onPressed: () => setState(() => isEditing = true),
      )
          : null,
    );
  }

  // ===================== COMPONENTS ========================

  Widget _genderSelector() {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          _genderButton("Male"),
          SizedBox(width: 3.w),
          _genderButton("Female"),
        ],
      ),
    );
  }

  Widget _genderButton(String text) {
    final active = gender == text;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = text),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF7DA48E) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.8.h),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _displayInfo(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 12.sp, color: Colors.grey, height: 1.3)),
          SizedBox(height: 0.5.h),
          Text(value,
              style: TextStyle(
                  fontSize: 13.sp, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
