import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvestToBusinessView extends StatefulWidget {
  const InvestToBusinessView({super.key});

  static const String _title = 'Invest to Business';

  @override
  State<InvestToBusinessView> createState() => _InvestToBusinessViewState();
}

class _InvestToBusinessViewState extends State<InvestToBusinessView> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  String _cashLocation = 'cash'; // 'cash' or 'bank'
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

    setState(() => _isSaving = true);
    try {
      final toCashOnHand = _cashLocation == 'cash';
      await QuickActionJournalService.instance.postTemplateEntry(
        date: _selectedDate,
        description: desc,
        referenceNo: null,
        lines: [
          TemplateLine(
            accountCode: toCashOnHand
                ? QuickActionAccounts.cashOnHand
                : QuickActionAccounts.cashInBank,
            isDebit: true,
            amount: amount,
          ),
          TemplateLine(
            accountCode: QuickActionAccounts.ownersCapital,
            isDebit: false,
            amount: amount,
          ),
        ],
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
          InvestToBusinessView._title,
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
            value: _cashLocation,
            items: const [
              DropdownMenuItem(value: 'cash', child: Text('Cash on Hand')),
              DropdownMenuItem(value: 'bank', child: Text('Cash in Bank')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _cashLocation = val);
              }
            },
            decoration: InputDecoration(
              labelText: 'Invested as (Cash / Bank)',
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
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
