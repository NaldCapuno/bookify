import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FundMarketingView extends StatefulWidget {
  const FundMarketingView({super.key});

  static const String _title = 'Fund Marketing';

  @override
  State<FundMarketingView> createState() => _FundMarketingViewState();
}

class _FundMarketingViewState extends State<FundMarketingView> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  String _paymentMethod = 'cash';
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

    final creditCode = _paymentMethod == 'cash'
        ? QuickActionAccounts.cashOnHand
        : QuickActionAccounts.cashInBank;

    final lines = <TemplateLine>[
      TemplateLine(
        accountCode: QuickActionAccounts.marketingExpense,
        isDebit: true,
        amount: amount,
      ),
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
          const SnackBar(content: Text('Failed to save marketing expense. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Stream<double> get _balanceStream =>
      _paymentMethod == 'cash'
          ? appDb.ledgerDao.watchBalanceForAccountCode(QuickActionAccounts.cashOnHand)
          : appDb.ledgerDao.watchBalanceForAccountCode(QuickActionAccounts.cashInBank);

  String get _balanceLabel =>
      _paymentMethod == 'cash' ? 'Cash balance:' : 'Bank balance:';

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
        title: const Text(
          FundMarketingView._title,
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          QuickActionAmountCard(
            amountController: _amountController,
            amountLabel: 'Amount',
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
          const QuickActionSectionLabel('Paid via'),
          CashBankChips(value: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v)),
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
