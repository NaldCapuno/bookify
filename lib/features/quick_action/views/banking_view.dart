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
    final debitCode = isDeposit
        ? QuickActionAccounts.cashInBank
        : QuickActionAccounts.cashOnHand;
    final creditCode = isDeposit
        ? QuickActionAccounts.cashOnHand
        : QuickActionAccounts.cashInBank;

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
          const SnackBar(
            content: Text('Failed to record transfer. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String get _amountLabel =>
      widget.type == 'Deposit' ? 'Deposit amount' : 'Withdraw amount';

  double get _currentAmount =>
      double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final isDeposit = widget.type == 'Deposit';
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: scheme.surfaceContainerHighest,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: scheme.primary),
        title: Text(
          widget.type == 'Deposit' ? 'Deposit to Bank' : 'Withdraw from Bank',
          style:
              textTheme.headlineLarge?.copyWith(fontSize: 20) ??
              TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<Map<int, double>>(
        stream: appDb.ledgerDao.watchBalancesForAccountCodes({
          QuickActionAccounts.cashOnHand,
          QuickActionAccounts.cashInBank,
        }),
        builder: (context, snap) {
          final balances =
              snap.data ??
              {
                QuickActionAccounts.cashOnHand: 0.0,
                QuickActionAccounts.cashInBank: 0.0,
              };
          final cash = balances[QuickActionAccounts.cashOnHand] ?? 0.0;
          final bank = balances[QuickActionAccounts.cashInBank] ?? 0.0;
          final amount = _currentAmount;

          // Deposit: show cash balance (source). Withdraw: show bank balance (source).
          final balanceBefore = isDeposit ? cash : bank;
          final balanceAfter = isDeposit ? cash - amount : bank - amount;
          final sourceBalance = isDeposit ? cash : bank;
          final insufficient = amount > 0 && amount > sourceBalance;

          return SafeArea(
            child: Column(
              children: [
                BeforeAfterBalanceHeader(
                  label: isDeposit ? 'Cash balance' : 'Bank balance',
                  before: balanceBefore,
                  after: balanceAfter,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        QuickActionAmountCard(
                          amountController: _amountController,
                          amountLabel: _amountLabel,
                          onAmountChanged: () => setState(() {}),
                        ),
                        if (insufficient)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: InsufficientBalanceNotice(
                              amount: amount,
                              currentBalance: sourceBalance,
                              isOutflow: true,
                            ),
                          ),
                        const SizedBox(height: 24),
                        QuickActionDetailsCard(
                          descriptionController: _descController,
                          dateText: _dateController.text,
                          onDateTap: _pickDate,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<Map<int, double>>(
        stream: appDb.ledgerDao.watchBalancesForAccountCodes({
          QuickActionAccounts.cashOnHand,
          QuickActionAccounts.cashInBank,
        }),
        builder: (context, snap) {
          final balances =
              snap.data ??
              {
                QuickActionAccounts.cashOnHand: 0.0,
                QuickActionAccounts.cashInBank: 0.0,
              };
          final sourceBalance = isDeposit
              ? (balances[QuickActionAccounts.cashOnHand] ?? 0.0)
              : (balances[QuickActionAccounts.cashInBank] ?? 0.0);
          final insufficient =
              _currentAmount > sourceBalance && _currentAmount > 0;
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
