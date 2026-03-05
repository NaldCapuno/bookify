import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BankingView extends StatefulWidget {
  final String type;
  const BankingView({super.key, required this.type});

  @override
  State<BankingView> createState() => _BankingViewState();
}

class _BankingViewState extends State<BankingView> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
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

    final isDeposit = widget.type == 'Deposit';
    final debitCode =
        isDeposit ? QuickActionAccounts.cashInBank : QuickActionAccounts.cashOnHand;
    final creditCode =
        isDeposit ? QuickActionAccounts.cashOnHand : QuickActionAccounts.cashInBank;

    final lines = <TemplateLine>[
      TemplateLine(accountCode: debitCode, isDebit: true, amount: amount),
      TemplateLine(accountCode: creditCode, isDebit: false, amount: amount),
    ];

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
          const SnackBar(content: Text('Failed to record transfer. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Stream<double> get _balanceStream {
    if (widget.type == 'Deposit') {
      return appDb.ledgerDao.watchBalanceForAccountCode(QuickActionAccounts.cashOnHand);
    }
    return appDb.ledgerDao.watchBalanceForAccountCode(QuickActionAccounts.cashInBank);
  }

  String get _balanceLabel =>
      widget.type == 'Deposit' ? 'Cash balance:' : 'Bank balance:';

  String get _amountLabel =>
      widget.type == 'Deposit' ? 'Amount to Bank' : 'Amount from Bank';

  double get _currentAmount =>
      double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          '${widget.type} Funds',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          QuickActionAmountCard(
            amountController: _amountController,
            amountLabel: _amountLabel,
            balanceStream: _balanceStream,
            balanceLabel: _balanceLabel,
            checkInsufficient: true,
            onAmountChanged: () => setState(() {}),
          ),
          StreamBuilder<double>(
            stream: _balanceStream,
            builder: (context, snap) {
              final balance = snap.data ?? 0.0;
              return InsufficientBalanceNotice(
                amount: _currentAmount,
                currentBalance: balance,
                isOutflow: true,
              );
            },
          ),
          const SizedBox(height: 24),
          QuickActionDetailsCard(
            descriptionController: _descController,
            dateText: _dateController.text,
            onDateTap: _pickDate,
          ),
        ],
      ),
      bottomNavigationBar: StreamBuilder<double>(
        stream: _balanceStream,
        builder: (context, snap) {
          final balance = snap.data ?? 0.0;
          final insufficient = _currentAmount > balance && _currentAmount > 0;
          return QuickActionSaveButton(
            onPressed: insufficient ? null : _save,
            isSaving: _isSaving,
            label: 'Save Entry',
          );
        },
      ),
    );
  }
}
