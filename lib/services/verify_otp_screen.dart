import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class VerifyOTPScreen extends StatefulWidget {
  final String contact;
  const VerifyOTPScreen({Key? key, required this.contact}) : super(key: key);

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyReset() async {
    setState(() => isLoading = true);

    final input = widget.contact;
    final response = await ApiService.verifyPasswordReset(
      email: input.contains('@') ? input : null,
      phone: !input.contains('@') ? input : null,
      otp: otpController.text.trim(),
      newPassword: passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'] ?? 'Unknown response')),
    );

    if (response['success']) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('A code was sent to ${widget.contact}.'),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: 'OTP Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : verifyReset,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
