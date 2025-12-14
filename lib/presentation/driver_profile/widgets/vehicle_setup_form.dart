import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../services/api/driver_api.dart';
import '../../../utils/toast_helper.dart';

class VehicleSetupForm extends StatefulWidget {
  const VehicleSetupForm({Key? key}) : super(key: key);

  @override
  State<VehicleSetupForm> createState() => _VehicleSetupFormState();
}

class _VehicleSetupFormState extends State<VehicleSetupForm> {
  final _formKey = GlobalKey<FormState>();

  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _seatsController = TextEditingController();

  File? _photo;
  bool _submitting = false;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _photo = File(image.path));
    }
  }

  Future<void> _submitVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    if (_photo == null) {
      ToastHelper.showError("Please upload a vehicle photo");
      return;
    }

    setState(() => _submitting = true);

    try {
      final formData = FormData.fromMap({
        "vehicle_model": _modelController.text.trim(),
        "license_plate": _plateController.text.trim(),
        "vehicle_year": _yearController.text.trim(),
        "vehicle_color": _colorController.text.trim(),
        "vehicle_seats": _seatsController.text.trim(),
        "vehicle_photo": await MultipartFile.fromFile(
          _photo!.path,
          filename: "vehicle.jpg",
        ),
      });

      final res = await DriverApi.updateVehicle(formData);

      if (res['success'] == true) {
        ToastHelper.showSuccess(res['message'] ?? "Vehicle saved!");
        // return true so dashboard knows it should refresh
        Navigator.pop(context, true);
      } else {
        ToastHelper.showError(res['message'] ?? "Failed to save vehicle");
      }
    } catch (e) {
      ToastHelper.showError("Error: $e");
    }

    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehicle Setup"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 2.h),

              // PHOTO
              GestureDetector(
                onTap: _pickPhoto,
                child: _photo == null
                    ? Container(
                  width: double.infinity,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, size: 40),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _photo!,
                    width: double.infinity,
                    height: 22.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              TextFormField(
                controller: _modelController,
                validator: (v) =>
                v!.isEmpty ? "Enter vehicle model" : null,
                decoration: const InputDecoration(
                  labelText: "Vehicle Model",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),

              TextFormField(
                controller: _plateController,
                validator: (v) =>
                v!.isEmpty ? "Enter license plate" : null,
                decoration: const InputDecoration(
                  labelText: "License Plate",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),

              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return "Enter year";
                  if (v.length != 4) return "Invalid year";
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Year",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),

              TextFormField(
                controller: _colorController,
                validator: (v) =>
                v!.isEmpty ? "Enter vehicle color" : null,
                decoration: const InputDecoration(
                  labelText: "Vehicle Color",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),

              TextFormField(
                controller: _seatsController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return "Enter number of seats";
                  if (int.tryParse(v) == null) return "Must be a number";
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Number of Seats",
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 4.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitVehicle,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "Save Vehicle Details",
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
      ),
    );
  }
}
