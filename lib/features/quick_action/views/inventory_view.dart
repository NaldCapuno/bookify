import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryView extends StatefulWidget {
  final String actionType; // 'Acquire' or 'Produce'
  const InventoryView({super.key, required this.actionType});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final _amountController = TextEditingController(); // for Acquire
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  final _rawUsedController = TextEditingController(); // for Produce
  final _laborController = TextEditingController(); // for Produce
  String _paymentMethod = 'cash'; // for Acquire: cash/bank/credit
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
    _rawUsedController.dispose();
    _laborController.dispose();
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
    final isAcquire = widget.actionType == 'Acquire';
    final desc = _descController.text.trim();

    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description is required.')),
      );
      return;
    }

    if (isAcquire) {
      final rawAmount = _amountController.text.replaceAll(',', '').trim();
      final amount = double.tryParse(rawAmount) ?? 0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amount is required.')),
        );
        return;
      }

      int creditCode;
      switch (_paymentMethod) {
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
          accountCode: QuickActionAccounts.inventoryRawMaterials,
          isDebit: true,
          amount: amount,
        ),
        TemplateLine(
          accountCode: creditCode,
          isDebit: false,
          amount: amount,
        ),
      ];

      await _postLines(desc, lines);
    } else {
      final rawRaw = _rawUsedController.text.replaceAll(',', '').trim();
      final laborRaw = _laborController.text.replaceAll(',', '').trim();
      final rawUsed = double.tryParse(rawRaw) ?? 0;
      final labor = double.tryParse(laborRaw) ?? 0;

      if (rawUsed <= 0 && labor <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter at least one amount for Raw Materials or Direct Labor.'),
          ),
        );
        return;
      }

      final total = rawUsed + labor;
      final lines = <TemplateLine>[
        TemplateLine(
          accountCode: QuickActionAccounts.inventoryFinishedGoods,
          isDebit: true,
          amount: total,
        ),
        if (rawUsed > 0)
          TemplateLine(
            accountCode: QuickActionAccounts.inventoryRawMaterials,
            isDebit: false,
            amount: rawUsed,
          ),
        if (labor > 0)
          TemplateLine(
            accountCode: QuickActionAccounts.directLabor,
            isDebit: false,
            amount: labor,
          ),
      ];

      await _postLines(desc, lines);
    }
  }

  Future<void> _postLines(String desc, List<TemplateLine> lines) async {
    setState(() => _isSaving = true);
    try {
      await QuickActionJournalService.instance.postTemplateEntry(
        date: _selectedDate,
        description: desc,
        referenceNo: null,
        lines: lines,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save inventory entry. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
  static final _inputBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(12));

  @override
  Widget build(BuildContext context) {
    final bool isAcquire = widget.actionType == 'Acquire';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          "${widget.actionType} Inventory",
          style: const TextStyle(
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
          if (isAcquire) ..._acquireFields() else ..._produceFields(),
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

  List<Widget> _acquireFields() {
    return [
      TextField(
        controller: _dateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date',
          prefixIcon: const Icon(Icons.calendar_today),
          border: _inputBorder,
        ),
        onTap: _pickDate,
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _descController,
        decoration: InputDecoration(
          labelText: 'Description',
          prefixIcon: const Icon(Icons.description_outlined),
          border: _inputBorder,
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Amount',
          prefixIcon: const Icon(Icons.attach_money),
          border: _inputBorder,
        ),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _paymentMethod,
        items: const [
          DropdownMenuItem(value: 'cash', child: Text('Cash on Hand')),
          DropdownMenuItem(value: 'bank', child: Text('Cash in Bank')),
          DropdownMenuItem(value: 'credit', child: Text('Pay Later')),
        ],
        onChanged: (val) {
          if (val != null) setState(() => _paymentMethod = val);
        },
        decoration: InputDecoration(
          labelText: 'Paid via',
          prefixIcon: const Icon(Icons.payments_outlined),
          border: _inputBorder,
        ),
      ),
    ];
  }

  List<Widget> _produceFields() {
    return [
      TextField(
        controller: _dateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date',
          prefixIcon: const Icon(Icons.calendar_today),
          border: _inputBorder,
        ),
        onTap: _pickDate,
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _descController,
        decoration: InputDecoration(
          labelText: 'Description',
          prefixIcon: const Icon(Icons.description_outlined),
          border: _inputBorder,
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _rawUsedController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Amount for Raw Materials used',
          prefixIcon: const Icon(Icons.widgets_outlined),
          border: _inputBorder,
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _laborController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Amount for Direct Labor',
          prefixIcon: const Icon(Icons.people_alt_outlined),
          border: _inputBorder,
        ),
      ),
    ];
  }
}
