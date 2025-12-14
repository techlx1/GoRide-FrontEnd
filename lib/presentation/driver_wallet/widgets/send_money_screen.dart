import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../../services/api/driver_api.dart';
import '../../../../utils/toast_helper.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({Key? key}) : super(key: key);

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController walletIdController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool _sending = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sending = true);

    final res = await DriverApi.sendMoney(
      receiverWalletId: walletIdController.text.trim(),
      amount: amountController.text.trim(),
      note: noteController.text.trim(),
    );

    setState(() => _sending = false);

    if (res['success'] == true) {
      ToastHelper.showSuccess(res['message'] ?? "Money sent!");
      Navigator.pop(context, true);
    } else {
      ToastHelper.showError(res['message'] ?? "Failed to send money");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Money"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 2.h),

              TextFormField(
                controller: walletIdController,
                decoration: const InputDecoration(
                  labelText: "Receiver Wallet ID",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v!.isEmpty ? "Enter the wallet ID" : null,
              ),
              SizedBox(height: 2.h),

              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount (GYD)",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v!.isEmpty ? "Enter amount" : null,
              ),
              SizedBox(height: 2.h),

              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: "Message / Note (optional)",
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 4.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: _sending
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "Send Money",
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
