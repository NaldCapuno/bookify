import 'package:flutter/material.dart';

class BankingView extends StatelessWidget {
  final String type; // 'Deposit' or 'Withdraw'
  const BankingView({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          "$type Funds",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAmountDisplay(
              type == 'Deposit' ? "Amount to Bank" : "Amount from Bank",
            ),
            const SizedBox(height: 24),
            _buildBankSelector(),
          ],
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(context),
    );
  }

  Widget _buildAmountDisplay(String label) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.lightGreen.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const TextField(
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "\$ 0.00",
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankSelector() {
    return ListTile(
      tileColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.account_balance),
      title: const Text("Select Bank Account"),
      trailing: const Icon(Icons.keyboard_arrow_down),
      onTap: () {},
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            "Record Transfer",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
