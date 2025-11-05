import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../services/wallet_service.dart';
import '../../utils/toast_helper.dart';

class DriverWalletScreen extends StatefulWidget {
  const DriverWalletScreen({Key? key}) : super(key: key);

  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen> {
  double _balance = 0.0;
  List<dynamic> _transactions = [];
  bool _loading = true;
  int _driverId = 0;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final prefs = await SharedPreferences.getInstance();
    _driverId = prefs.getInt('driver_id') ?? 0;
    if (_driverId == 0) return;

    final data = await WalletService.getDriverWallet(_driverId);
    if (data['success'] == true) {
      setState(() {
        _balance = (data['balance'] ?? 0).toDouble();
        _transactions = data['transactions'] ?? [];
      });
    } else {
      ToastHelper.showError('Failed to load wallet');
    }

    setState(() => _loading = false);
  }

  Future<void> _handleWithdraw() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Funds'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter amount',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount <= 0 || amount > _balance) {
                ToastHelper.showError('Invalid amount');
                return;
              }
              final res = await WalletService.withdraw(_driverId, amount);
              if (res['success'] == true) {
                ToastHelper.showSuccess('Withdrawal submitted');
                Navigator.pop(context);
                _loadWallet();
              } else {
                ToastHelper.showError(res['message']);
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Wallet'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadWallet),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadWallet,
        child: ListView(
          padding: EdgeInsets.all(4.w),
          children: [
            // 💰 Balance Card
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Balance',
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 1.h),
                  Text(
                    'GYD ${_balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _handleWithdraw,
                      icon: const Icon(Icons.account_balance_wallet),
                      label: const Text('Withdraw'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            // 📜 Transaction History
            Text('Recent Transactions',
                style: TextStyle(
                    fontSize: 15.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 1.h),
            ..._transactions.map((tx) {
              final date = DateFormat('dd MMM, hh:mm a')
                  .format(DateTime.parse(tx['date']));
              final isCredit = (tx['amount'] ?? 0) > 0;
              return ListTile(
                leading: Icon(
                  isCredit ? Icons.add_circle : Icons.remove_circle,
                  color: isCredit ? Colors.green : Colors.red,
                ),
                title: Text(tx['type'] ?? 'Transaction'),
                subtitle: Text(date),
                trailing: Text(
                  '${isCredit ? '+' : ''}GYD ${tx['amount']}',
                  style: TextStyle(
                    color: isCredit ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
