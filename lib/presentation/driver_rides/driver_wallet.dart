import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../theme/app_theme.dart';
import '../../utils/toast_helper.dart';

class DriverWallet extends StatefulWidget {
  const DriverWallet({Key? key}) : super(key: key);

  @override
  State<DriverWallet> createState() => _DriverWalletState();
}

class _DriverWalletState extends State<DriverWallet> {
  double balance = 8200.50;
  final List<Map<String, dynamic>> _transactions = [
    {'type': 'Credit', 'amount': 2500, 'date': '2025-10-25'},
    {'type': 'Credit', 'amount': 1800, 'date': '2025-10-24'},
    {'type': 'Debit', 'amount': 500, 'date': '2025-10-23'},
  ];

  void _withdrawFunds() {
    if (balance < 1000) {
      ToastHelper.showError('Minimum withdrawal is \$1000.');
      return;
    }
    setState(() => balance -= 1000);
    ToastHelper.showSuccess('You withdrew \$1000 successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Wallet'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Colors.green.shade50,
              child: Padding(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  children: [
                    Text(
                      "Wallet Balance",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "\$${balance.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      label: const Text("Withdraw \$1000"),
                      onPressed: _withdrawFunds,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppTheme.lightTheme.colorScheme.primary,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              "Transaction History",
              style: TextStyle(
                  fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final txn = _transactions[index];
                  final isCredit = txn['type'] == 'Credit';
                  return ListTile(
                    leading: Icon(
                      isCredit
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: isCredit ? Colors.green : Colors.red,
                    ),
                    title: Text("${txn['type']} \$${txn['amount']}"),
                    subtitle: Text(txn['date']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
