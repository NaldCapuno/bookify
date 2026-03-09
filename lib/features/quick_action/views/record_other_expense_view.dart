import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/widgets/app_toast.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordOtherExpenseView extends StatefulWidget {
  const RecordOtherExpenseView({super.key});

  static const String _title = 'Record Other Expense';

  @override
  State<RecordOtherExpenseView> createState() => _RecordOtherExpenseViewState();
}

class _RecordOtherExpenseViewState extends State<RecordOtherExpenseView> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  String _expenseType = 'bankFees';
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

  static const Map<String, String> _expenseTypeLabels = {
    'bankFees': 'Bank Fees',
    'tax': 'Tax',
    'interest': 'Interest',
    'misc': 'Miscellaneous',
  };

  int _expenseAccountForType(String type) {
    switch (type) {
      case 'tax':
        return QuickActionAccounts.taxExpense;
      case 'interest':
        return QuickActionAccounts.interestExpense;
      case 'misc':
        return QuickActionAccounts.miscellaneousExpense;
      case 'bankFees':
      default:
        return QuickActionAccounts.bankFees;
    }
  }

  Future<void> _showExpenseTypePicker() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        final scheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  'Select Expense Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ..._expenseTypeLabels.entries.map((e) {
                  final isSelected = _expenseType == e.key;
                  return ListTile(
                    title: Text(
                      e.value,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: scheme.primary)
                        : null,
                    onTap: () => Navigator.pop(context, e.key),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _expenseType = picked);
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

    final expenseCode = _expenseAccountForType(_expenseType);
    final creditCode = _paymentMethod == 'cash'
        ? QuickActionAccounts.cashOnHand
        : QuickActionAccounts.cashInBank;

    final lines = <TemplateLine>[
      TemplateLine(accountCode: expenseCode, isDebit: true, amount: amount),
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
        AppToast.show(context, message: 'Failed to save expense. Please try again.', isError: true);
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
          RecordOtherExpenseView._title,
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
          final before = _paymentMethod == 'cash'
              ? (balances[QuickActionAccounts.cashOnHand] ?? 0.0)
              : (balances[QuickActionAccounts.cashInBank] ?? 0.0);
          final amount = parseAmount(_amountController);
          final after = before - amount;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              BeforeAfterBalanceHeader(
                label: _paymentMethod == 'cash'
                    ? 'Cash balance'
                    : 'Bank balance',
                before: before,
                after: after,
              ),
              const SizedBox(height: 16),
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
              const QuickActionSectionLabel('Expense Type'),
              InkWell(
                onTap: _showExpenseTypePicker,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long_outlined, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _expenseTypeLabels[_expenseType] ?? _expenseType,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const QuickActionSectionLabel('Paid via'),
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
            ],
          );
        },
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
