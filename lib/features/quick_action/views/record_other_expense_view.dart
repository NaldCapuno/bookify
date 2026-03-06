import 'package:bookkeeping/core/database/app_database.dart';
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

  int _expenseAccountForType(String type) {
    switch (type) {
      case 'interest':
        return QuickActionAccounts.interestExpense;
      case 'misc':
        return QuickActionAccounts.miscellaneousExpense;
      case 'bankFees':
      default:
        return QuickActionAccounts.bankFees;
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save expense. Please try again.')),
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
          RecordOtherExpenseView._title,
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<Map<int, double>>(
        stream: appDb.ledgerDao.watchBalancesForAccountCodes({
          QuickActionAccounts.cashOnHand,
          QuickActionAccounts.cashInBank,
        }),
        builder: (context, snap) {
          final balances = snap.data ?? {
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
                label: _paymentMethod == 'cash' ? 'Cash balance' : 'Bank balance',
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
              Row(
                children: [
                  Expanded(
                    child: _ExpenseChip(
                      'Bank Fees',
                      'bankFees',
                      _expenseType,
                      () => setState(() => _expenseType = 'bankFees'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ExpenseChip(
                      'Interest',
                      'interest',
                      _expenseType,
                      () => setState(() => _expenseType = 'interest'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ExpenseChip(
                      'Misc',
                      'misc',
                      _expenseType,
                      () => setState(() => _expenseType = 'misc'),
                    ),
                  ),
                ],
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

class _ExpenseChip extends StatelessWidget {
  const _ExpenseChip(this.label, this.value, this.selected, this.onTap);

  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Material(
      color: isSelected ? const Color(0xFF2E7D32).withValues(alpha: 0.12) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
