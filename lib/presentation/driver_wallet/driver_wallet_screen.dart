import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../services/api/driver_api.dart';
import '../../../utils/toast_helper.dart';

// NEW SCREENS
import 'widgets/send_money_screen.dart';
import 'widgets/receive_money_screen.dart';

class DriverWalletScreen extends StatefulWidget {
  const DriverWalletScreen({Key? key}) : super(key: key);

  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen> {
  bool _loading = true;
  Map<String, dynamic> _wallet = {};
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() => _loading = true);

    final res = await DriverApi.getWalletOverview();

    if (res['success'] == true) {
      setState(() {
        _wallet = res['wallet'] ?? {};
        _transactions = res['transactions'] ?? [];
        _loading = false;
      });
    } else {
      ToastHelper.showError(res['message'] ?? "Failed to load wallet");
      setState(() => _loading = false);
    }
  }

  // OPEN SEND SCREEN
  void _showSendMoney() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
    );
  }

  // OPEN RECEIVE SCREEN
  void _showReceiveMoney() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReceiveMoneyScreen()),
    );
  }

  // PAYOUT POPUP
  void _showPayoutDialog() {
    final amountController = TextEditingController();
    final methodController = TextEditingController(text: "Bank Transfer");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Request Payout"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount (GYD)"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: methodController,
              decoration: const InputDecoration(
                labelText: "Payout Method",
                hintText: "e.g. Bank, MMG, Cash",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final amount = amountController.text.trim();
              if (amount.isEmpty) {
                ToastHelper.showError("Please enter an amount.");
                return;
              }

              Navigator.pop(context);

              final res = await DriverApi.requestPayout(
                amount: amount,
                method: methodController.text.trim(),
              );

              if (res['success'] == true) {
                ToastHelper.showSuccess(res['message'] ?? "Payout requested");
                _loadWallet();
              } else {
                ToastHelper.showError(res['message'] ?? "Failed to request payout");
              }
            },
            child: const Text("Request"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadWallet,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // WALLET BALANCE CARD
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Available Balance",
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    SizedBox(height: 0.8.h),

                    Text(
                      "GYD ${(_wallet['available_balance'] ?? 0)}",
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 1.5.h),

                    Text(
                      "Pending: GYD ${_wallet['pending_balance'] ?? 0}",
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // SEND / RECEIVE ROW
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showSendMoney,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blueAccent,
                            ),
                            child: const Text("Send"),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showReceiveMoney,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blueAccent,
                            ),
                            child: const Text("Receive"),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 1.5.h),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showPayoutDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueAccent,
                        ),
                        child: const Text("Request Payout"),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              Text(
                "Recent Transactions",
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),

              if (_transactions.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    "No transactions yet.",
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: theme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _transactions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final tx = _transactions[index];
                    final isCredit = tx['type'] == 'credit';
                    final amount = tx['amount'] ?? 0;
                    final desc = tx['description'] ?? tx['source'] ?? "";
                    final createdAt = tx['created_at'].toString();

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCredit
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        child: Icon(
                          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isCredit ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        "${isCredit ? '+' : '-'} GYD $amount",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                      subtitle: Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: theme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Text(
                        createdAt.replaceAll("T", " ").split(".").first,
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          color: theme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
