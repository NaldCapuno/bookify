import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/widgets/app_toast.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PayWorkersView extends StatefulWidget {
  const PayWorkersView({super.key});

  static const String _title = 'Pay Employees';

  @override
  State<PayWorkersView> createState() => _PayWorkersViewState();
}

class _PayWorkersViewState extends State<PayWorkersView> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  String _employeeType = 'workers'; // workers | office
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

    final debitCode = _employeeType == 'workers'
        ? QuickActionAccounts.directLabor
        : QuickActionAccounts.salariesAndWagesExpense;

    final lines = <TemplateLine>[
      TemplateLine(
        accountCode: debitCode,
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
        AppToast.show(context, message: 'Failed to save payment. Please try again.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
          PayWorkersView._title,
          style: textTheme.headlineLarge?.copyWith(fontSize: 20) ??
              TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<Map<int, double>>(
        stream: appDb.ledgerDao.watchBalancesForAccountCodes({
          QuickActionAccounts.cashOnHand,
          QuickActionAccounts.cashInBank,
          QuickActionAccounts.directLabor,
        }),
        builder: (context, snap) {
          final balances = snap.data ??
              {
                QuickActionAccounts.cashOnHand: 0.0,
                QuickActionAccounts.cashInBank: 0.0,
                QuickActionAccounts.directLabor: 0.0,
              };
          final amount = _currentAmount;
          final cash = balances[QuickActionAccounts.cashOnHand] ?? 0.0;
          final bank = balances[QuickActionAccounts.cashInBank] ?? 0.0;
          final directLabor = balances[QuickActionAccounts.directLabor] ?? 0.0;
          final isCash = _paymentMethod == 'cash';
          final before = isCash ? cash : bank;
          final after = before - amount;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              BeforeAfterBalanceHeader(
                label: isCash ? 'Cash balance' : 'Bank balance',
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
              const QuickActionSectionLabel('Employee Type'),
              Row(
                children: [
                  Expanded(
                    child: _TypeChip(
                      label: 'Workers',
                      isSelected: _employeeType == 'workers',
                      onTap: () => setState(() => _employeeType = 'workers'),
                      accentColor: const Color(0xFF00838F), // Teal
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TypeChip(
                      label: 'Office Staffs',
                      isSelected: _employeeType == 'office',
                      onTap: () => setState(() => _employeeType = 'office'),
                      accentColor: const Color(0xFF5C6BC0), // Indigo
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_employeeType == 'workers')
                _PostingHintCard(
                  directLaborBalance: directLabor.abs(),
                ),
              const SizedBox(height: 20),
              const QuickActionSectionLabel('Paid via'),
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
          final cash = balances[QuickActionAccounts.cashOnHand] ?? 0.0;
          final bank = balances[QuickActionAccounts.cashInBank] ?? 0.0;
          final isCash = _paymentMethod == 'cash';
          final before = isCash ? cash : bank;
          final amount = _currentAmount;
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

class _PostingHintCard extends StatelessWidget {
  const _PostingHintCard({
    required this.directLaborBalance,
  });

  final double directLaborBalance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = 'Direct labor balance: ${formatAmount(directLaborBalance)}';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: isSelected
          ? accentColor.withValues(alpha: 0.15)
          : scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accentColor : accentColor.withValues(alpha: 0.4),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? accentColor : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
