import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/widgets/app_toast.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LendMoneyView extends StatefulWidget {
  const LendMoneyView({super.key});

  static const String _title = 'Lend Money';

  @override
  State<LendMoneyView> createState() => _LendMoneyViewState();
}

class _LendMoneyViewState extends State<LendMoneyView> {
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
      AppToast.show(context, message: 'Description and amount are required.');
      return;
    }

    final creditCode = _paymentMethod == 'cash'
        ? QuickActionAccounts.cashOnHand
        : QuickActionAccounts.cashInBank;

    final lines = <TemplateLine>[
      TemplateLine(
        accountCode: QuickActionAccounts.accountsReceivable,
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
        AppToast.show(
          context,
          message: 'Failed to save lending entry. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Stream<double> get _balanceStream => _paymentMethod == 'cash'
      ? appDb.ledgerDao.watchBalanceForAccountCode(
          QuickActionAccounts.cashOnHand,
        )
      : appDb.ledgerDao.watchBalanceForAccountCode(
          QuickActionAccounts.cashInBank,
        );

  double get _currentAmount =>
      double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        // Blends smoothly into the pinned header
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: scheme.primary),
        title: Text(
          LendMoneyView._title,
          style:
              textTheme.headlineLarge?.copyWith(fontSize: 20) ??
              TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<Map<int, double>>(
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

            final before = _paymentMethod == 'cash' ? cash : bank;
            final amount = parseAmount(_amountController);
            final after = before - amount;

            final insufficient = amount > 0 && amount > before;

            return Column(
              children: [
                // =====================================
                // 1. PINNED HEADER
                // =====================================
                BeforeAfterBalanceHeader(
                  label: _paymentMethod == 'cash'
                      ? 'Cash balance'
                      : 'Bank balance',
                  before: before,
                  after: after,
                ),

                // =====================================
                // 2. SCROLLABLE CONTENT
                // =====================================
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      QuickActionAmountCard(
                        amountController: _amountController,
                        amountLabel: 'Amount',
                        onAmountChanged: () => setState(() {}),
                      ),
                      if (insufficient)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: InsufficientBalanceNotice(
                            amount: amount,
                            currentBalance: before,
                            isOutflow: true,
                          ),
                        ),
                      const SizedBox(height: 24),
                      const QuickActionSectionLabel('Lent from (Cash / Bank)'),
                      CashBankChips(
                        value: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v),
                        cashBalance: cash,
                        bankBalance: bank,
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
              ],
            );
          },
        ),
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
