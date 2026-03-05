import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordPurchaseView extends StatefulWidget {
  final String initialCategory;

  const RecordPurchaseView({super.key, required this.initialCategory});

  @override
  State<RecordPurchaseView> createState() => _RecordPurchaseViewState();
}

class _RecordPurchaseViewState extends State<RecordPurchaseView> {
  String _selectedPaymentMethod = 'bank';
  late String _currentCategory;
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.initialCategory;
    _dateController.text = DateFormat('MM/dd/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  int? _assetAccountForCategory(String category) {
    switch (category) {
      case 'Supplies':
        return QuickActionAccounts.supplies;
      case 'Equipment':
        return QuickActionAccounts.equipment;
      case 'Furniture':
        return QuickActionAccounts.furnitureAndFixtures;
      default:
        return null;
    }
  }

  Future<void> _save() async {
    final desc = _descController.text.trim();
    final rawAmount = _amountController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(rawAmount) ?? 0;

    if (desc.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description and amount are required.')),
      );
      return;
    }

    final assetCode = _assetAccountForCategory(_currentCategory);
    if (assetCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Quick Purchase currently supports Supplies, Equipment, and Furniture only.',
          ),
        ),
      );
      return;
    }

    int creditCode;
    switch (_selectedPaymentMethod) {
      case 'cash':
        creditCode = QuickActionAccounts.cashOnHand;
        break;
      case 'bank':
        creditCode = QuickActionAccounts.cashInBank;
        break;
      case 'credit':
        creditCode = QuickActionAccounts.accountsPayable;
        break;
      default:
        creditCode = QuickActionAccounts.cashOnHand;
    }

    final lines = <TemplateLine>[
      TemplateLine(
        accountCode: assetCode,
        isDebit: true,
        amount: amount,
      ),
      TemplateLine(
        accountCode: creditCode,
        isDebit: false,
        amount: amount,
      ),
    ];

    setState(() => _isSaving = true);
    try {
      await QuickActionJournalService.instance.postTemplateEntry(
        date: _selectedDate,
        description: desc,
        referenceNo: null,
        lines: lines,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save purchase. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnpaid = _selectedPaymentMethod == 'credit';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          "Record Purchase",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Transaction Details",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Date',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _currentCategory,
            items: ['Supplies', 'Equipment', 'Furniture', 'Land', 'Building', 'Vehicle']
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _currentCategory = val);
            },
            decoration: InputDecoration(
              labelText: 'Asset Category',
              prefixIcon: const Icon(Icons.category_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedPaymentMethod,
            items: const [
              DropdownMenuItem(value: 'cash', child: Text('Cash on Hand')),
              DropdownMenuItem(value: 'bank', child: Text('Cash in Bank')),
              DropdownMenuItem(value: 'credit', child: Text('Pay Later')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedPaymentMethod = val);
            },
            decoration: InputDecoration(
              labelText: 'Paid via',
              prefixIcon: const Icon(Icons.payments_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (isUnpaid)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Will be recorded as Accounts Payable (Debt).",
                      style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'e.g. 2 Laptops for office',
              prefixIcon: const Icon(Icons.description_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: Text(
            _isSaving ? "Saving..." : "Save Entry",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
