import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
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
  String _method = 'cash';
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
      TemplateLine(
        accountCode: QuickActionAccounts.salesReturnsAndAllowances,
        isDebit: true,
        amount: amount,
      ),
      TemplateLine(accountCode: creditAccount, isDebit: false, amount: amount),
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
          const SnackBar(content: Text('Failed to save refund. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Stream<double>? get _balanceStream {
    if (_method == 'cash') {
      return appDb.ledgerDao.watchBalanceForAccountCode(QuickActionAccounts.cashOnHand);
    }
    if (_method == 'bank') {
      return appDb.ledgerDao.watchBalanceForAccountCode(QuickActionAccounts.cashInBank);
    }
    return null;
  }

  String? get _balanceLabel {
    if (_method == 'cash') return 'Cash balance:';
    if (_method == 'bank') return 'Bank balance:';
    return null;
  }

  bool get _isOutflow => _method == 'cash' || _method == 'bank';

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
          RefundToCustomersView._title,
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
            checkInsufficient: _isOutflow,
            onAmountChanged: () => setState(() {}),
          ),
          if (_isOutflow && _balanceStream != null)
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
          const QuickActionSectionLabel('Refunded via'),
          PaymentMethodChips(
            value: _method,
            onChanged: (v) => setState(() => _method = v),
            creditLabel: 'On Credit',
          ),
          const SizedBox(height: 24),
          QuickActionDetailsCard(
            descriptionController: _descController,
            dateText: _dateController.text,
            onDateTap: _pickDate,
          ),
        ],
      ),
      bottomNavigationBar: _isOutflow && _balanceStream != null
          ? StreamBuilder<double>(
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
            )
          : QuickActionSaveButton(
              onPressed: _save,
              isSaving: _isSaving,
              label: 'Save Entry',
            ),
    );
  }
}
