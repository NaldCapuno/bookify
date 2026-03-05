import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RefundToCustomersView extends StatefulWidget {
  const RefundToCustomersView({super.key});

  static const String _title = 'Refund to Customers';

  @override
  State<RefundToCustomersView> createState() => _RefundToCustomersViewState();
}

class _RefundToCustomersViewState extends State<RefundToCustomersView> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  String _method = 'cash'; // cash, bank, credit
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
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

    int creditAccount;
    switch (_method) {
      case 'cash':
        creditAccount = QuickActionAccounts.cashOnHand;
        break;
      case 'bank':
        creditAccount = QuickActionAccounts.cashInBank;
        break;
      case 'credit':
        creditAccount = QuickActionAccounts.accountsPayable;
        break;
      default:
        creditAccount = QuickActionAccounts.cashOnHand;
    }

    final lines = <TemplateLine>[
      // Refund reduces revenue
      TemplateLine(
        accountCode: QuickActionAccounts.salesReturnsAndAllowances,
        isDebit: true,
        amount: amount,
      ),
      TemplateLine(
        accountCode: creditAccount,
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
            content: Text('Failed to save entry. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          RefundToCustomersView._title,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _method,
            items: const [
              DropdownMenuItem(value: 'cash', child: Text('Cash on Hand')),
              DropdownMenuItem(value: 'bank', child: Text('Cash in Bank')),
              DropdownMenuItem(value: 'credit', child: Text('On Credit')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _method = val);
            },
            decoration: InputDecoration(
              labelText: 'Refunded via',
              prefixIcon: const Icon(Icons.payment_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: 'Description',
              prefixIcon: const Icon(Icons.description_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
