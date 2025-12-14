import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../services/api/driver_api.dart';
import '../../../utils/toast_helper.dart';

class VehicleEditScreen extends StatefulWidget {
  final Map<String, dynamic> vehicleData;

  const VehicleEditScreen({
    Key? key,
    required this.vehicleData,
  }) : super(key: key);

  @override
  State<VehicleEditScreen> createState() => _VehicleEditScreenState();
}

class _VehicleEditScreenState extends State<VehicleEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController model;
  late final TextEditingController plate;
  late final TextEditingController year;
  late final TextEditingController color;
  late final TextEditingController seats;

  File? _photo;
  bool submitting = false;

  @override
  void initState() {
    super.initState();

    // Load existing values OR empty
    model = TextEditingController(text: widget.vehicleData['vehicle_model'] ?? "");
    plate = TextEditingController(text: widget.vehicleData['license_plate'] ?? "");
    year = TextEditingController(text: widget.vehicleData['vehicle_year'] ?? "");
    color = TextEditingController(text: widget.vehicleData['vehicle_color'] ?? "");
    seats = TextEditingController(
      text: widget.vehicleData['vehicle_seats']?.toString() ?? "",
    );
  }

  // ------------------------------------------------------
  // PICK VEHICLE PHOTO
  // ------------------------------------------------------
  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() => _photo = File(img.path));
    }
  }

  // ------------------------------------------------------
  // SUBMIT VEHICLE INFO
  // ------------------------------------------------------
  Future<void> submitChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => submitting = true);

    // DEBUG PRINT — Shows EXACTLY what backend receives
    print("🚀 SENDING TO BACKEND:");
    print({
      "vehicle_model": model.text.trim(),
      "license_plate": plate.text.trim(),
      "vehicle_year": year.text.trim(),
      "vehicle_color": color.text.trim(),
      "vehicle_seats": seats.text.trim(),
      "vehicle_photo": _photo != null ? "FILE INCLUDED" : "NO FILE",
    });

    final response = await DriverApi.updateVehicleData(
      model: model.text.trim(),
      plate: plate.text.trim(),
      year: year.text.trim(),
      color: color.text.trim(),
      seats: seats.text.trim(),
      photo: _photo,
    );

    setState(() => submitting = false);

    if (response['success'] == true) {
      ToastHelper.showSuccess(response['message'] ?? "Vehicle saved");
      Navigator.pop(context, true);
    } else {
      ToastHelper.showError(response['message'] ?? "Failed to save");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehicle Details"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // PHOTO PICKER
              GestureDetector(
                onTap: pickPhoto,
                child: _photo == null
                    ? Container(
                  height: 22.h,
                  width: double.infinity,
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
                    height: 22.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              _field(model, "Vehicle Model"),
              _field(plate, "License Plate"),
              _field(year, "Vehicle Year", number: true),
              _field(color, "Vehicle Color"),
              _field(seats, "Vehicle Seats", number: true),

              SizedBox(height: 4.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitting ? null : submitChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  ),
                  child: submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "Save Vehicle Details",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
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

  // ------------------------------------------------------
  // REUSABLE FORM FIELD WIDGET
  // ------------------------------------------------------
  Widget _field(TextEditingController controller, String label,
      {bool number = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: TextFormField(
        controller: controller,
        validator: (v) => v!.isEmpty ? "Required" : null,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
