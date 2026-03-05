import 'package:flutter/material.dart';

class RecordPurchaseView extends StatefulWidget {
  final String initialCategory;

  const RecordPurchaseView({super.key, required this.initialCategory});

  @override
  State<RecordPurchaseView> createState() => _RecordPurchaseViewState();
}

class _RecordPurchaseViewState extends State<RecordPurchaseView> {
  String _selectedPaymentMethod = 'bank';
  late String _currentCategory;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnpaid = _selectedPaymentMethod == 'credit';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          "Record Purchase",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AMOUNT PAID",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                    decoration: const InputDecoration(
                      prefixText: "\$ ",
                      border: InputBorder.none,
                      hintText: "0.00",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _currentCategory,
                    decoration: const InputDecoration(
                      labelText: "Asset Category",
                      prefixIcon: Icon(Icons.category_outlined),
                      border: InputBorder.none,
                    ),
                    items:
                        [
                              'Supplies',
                              'Equipment',
                              'Furniture',
                              'Land',
                              'Building',
                              'Vehicle',
                            ]
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _currentCategory = val);
                    },
                  ),
                  const Divider(),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: isUnpaid
                          ? "Vendor / Supplier (Required)*"
                          : "Vendor / Supplier (Optional)",
                      prefixIcon: const Icon(Icons.storefront),
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Description (e.g. 2 Laptops for office)",
                      prefixIcon: Icon(Icons.description_outlined),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "PAID VIA",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentOption('cash', 'Cash', Icons.money),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPaymentOption(
                    'bank',
                    'Bank',
                    Icons.account_balance,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPaymentOption(
                    'credit',
                    'Pay Later',
                    Icons.schedule,
                  ),
                ),
              ],
            ),
            if (isUnpaid)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Will be recorded as Accounts Payable (Debt).",
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: () {
              // Save Logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Save Purchase",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    final bool isSelected = _selectedPaymentMethod == value;
    final color = isSelected ? Colors.black87 : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
