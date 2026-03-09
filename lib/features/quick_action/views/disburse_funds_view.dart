import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/widgets/app_toast.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DisburseFundsView extends StatefulWidget {
  const DisburseFundsView({super.key});

  static const String _title = 'Disburse Funds';

  @override
  State<DisburseFundsView> createState() => _DisburseFundsViewState();
}

class _DisburseFundsViewState extends State<DisburseFundsView> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  String _paymentMethod = 'bank';
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
      AppToast.show(context, message: 'Description and amount are required.');
      return;
    }

    final creditCode = _paymentMethod == 'cash'
        ? QuickActionAccounts.cashOnHand
        : QuickActionAccounts.cashInBank;

    final lines = <TemplateLine>[
      TemplateLine(
        accountCode: QuickActionAccounts.ownersDrawings,
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
        AppToast.show(context, message: 'Failed to save disbursement. Please try again.', isError: true);
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: scheme.surfaceContainerHighest,
        elevation: 0,
        leading: BackButton(color: scheme.primary),
        title: Text(
          DisburseFundsView._title,
          style: textTheme.headlineLarge?.copyWith(fontSize: 20) ??
              TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<Map<int, double>>(
        stream: appDb.ledgerDao.watchBalancesForAccountCodes({
          QuickActionAccounts.cashOnHand,
          QuickActionAccounts.cashInBank,
        }),
        builder: (context, snap) {
          final balances = snap.data ??
              {
                QuickActionAccounts.cashOnHand: 0.0,
                QuickActionAccounts.cashInBank: 0.0,
              };

          final before = _paymentMethod == 'cash'
              ? (balances[QuickActionAccounts.cashOnHand] ?? 0.0)
              : (balances[QuickActionAccounts.cashInBank] ?? 0.0);
          final amount = parseAmount(_amountController);
          final after = before - amount;
          final insufficient = amount > 0 && amount > before;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              BeforeAfterBalanceHeader(
                label: _paymentMethod == 'cash' ? 'Cash balance' : 'Bank balance',
                before: before,
                after: after,
              ),
              const SizedBox(height: 16),
              QuickActionAmountCard(
                amountController: _amountController,
                amountLabel: 'Amount',
                onAmountChanged: () => setState(() {}),
              ),
              InsufficientBalanceNotice(
                amount: amount,
                currentBalance: before,
                isOutflow: true,
              ),
              const SizedBox(height: 24),
              const QuickActionSectionLabel('Taken from'),
              CashBankChips(
                value: _paymentMethod,
                onChanged: (v) => setState(() => _paymentMethod = v),
                cashBalance: balances[QuickActionAccounts.cashOnHand],
                bankBalance: balances[QuickActionAccounts.cashInBank],
              ),
              const SizedBox(height: 24),
              QuickActionDetailsCard(
                descriptionController: _descController,
                dateText: _dateController.text,
                onDateTap: _pickDate,
              ),
              const SizedBox(height: 90),
            ],
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<Map<int, double>>(
        stream: appDb.ledgerDao.watchBalancesForAccountCodes({
          QuickActionAccounts.cashOnHand,
          QuickActionAccounts.cashInBank,
        }),
        builder: (context, snap) {
          final balances = snap.data ??
              {
                QuickActionAccounts.cashOnHand: 0.0,
                QuickActionAccounts.cashInBank: 0.0,
              };
          final before = _paymentMethod == 'cash'
              ? (balances[QuickActionAccounts.cashOnHand] ?? 0.0)
              : (balances[QuickActionAccounts.cashInBank] ?? 0.0);
          final amount = parseAmount(_amountController);
          final insufficient = amount > 0 && amount > before;
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
