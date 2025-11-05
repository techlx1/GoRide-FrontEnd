import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController contactController = TextEditingController();
  bool isLoading = false;

  Future<void> sendResetRequest() async {
    setState(() => isLoading = true);

    final input = contactController.text.trim();
    final response = await ApiService.requestPasswordReset(
      email: input.contains('@') ? input : null,
      phone: !input.contains('@') ? input : null,
    );

    setState(() => isLoading = false);

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent! Check your email or SMS.')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOTPScreen(contact: input),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Failed to send OTP.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Enter your email or phone number to receive a reset code.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(
                labelText: 'Email or Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : sendResetRequest,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
