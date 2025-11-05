import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// A reusable toast helper that ensures
/// consistent styling for success, error, and info messages.
/// Works on both Android and iOS.
class ToastHelper {
  static void showSuccess(String message) {
    _show(message, Colors.green.shade600);
  }

  static void showError(String message) {
    _show(message, Colors.red.shade700);
  }

  static void showInfo(String message) {
    _show(message, Colors.blue.shade600);
  }

  static void _show(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
