import 'package:bookkeeping/core/theme/app_theme.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BorrowMoneyView extends StatefulWidget {
  const BorrowMoneyView({super.key});

  static const String _title = 'Borrow Money';

  @override
  State<BorrowMoneyView> createState() => _BorrowMoneyViewState();
}

class _BorrowMoneyViewState extends State<BorrowMoneyView> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  String _debtType = 'ap';
  String _receivedTo = 'cash';
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

    final debitCode = _receivedTo == 'cash'
        ? QuickActionAccounts.cashOnHand
        : QuickActionAccounts.cashInBank;

    final creditCode = _debtType == 'ap'
        ? QuickActionAccounts.accountsPayable
        : QuickActionAccounts.longTermLoans;

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
          const SnackBar(content: Text('Failed to save entry. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
          BorrowMoneyView._title,
          style: textTheme.headlineLarge?.copyWith(fontSize: 20) ??
              TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          QuickActionAmountCard(
            amountController: _amountController,
            amountLabel: 'Amount',
            onAmountChanged: () => setState(() {}),
          ),
          const SizedBox(height: 24),
          const QuickActionSectionLabel('Debt Account'),
          Row(
            children: [
              Expanded(
                child: _DebtChip(
                  label: 'Payable (3 months or less)',
                  isSelected: _debtType == 'ap',
                  onTap: () => setState(() => _debtType = 'ap'),
                  accentColor: const Color(0xFF1976D2), // Blue
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DebtChip(
                  label: 'Loan (more than 3 months)',
                  isSelected: _debtType == 'loan',
                  onTap: () => setState(() => _debtType = 'loan'),
                  accentColor: const Color(0xFF7B1FA2), // Purple
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const QuickActionSectionLabel('Received to (Cash / Bank)'),
          CashBankChips(
            value: _receivedTo,
            onChanged: (v) => setState(() => _receivedTo = v),
          ),
          const SizedBox(height: 24),
          QuickActionDetailsCard(
            descriptionController: _descController,
            dateText: _dateController.text,
            onDateTap: _pickDate,
          ),
        ],
      ),
      bottomNavigationBar: QuickActionSaveButton(
        onPressed: _save,
        isSaving: _isSaving,
        label: 'Save Entry',
      ),
    );
  }
}

class _DebtChip extends StatelessWidget {
  const _DebtChip({
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
      color: isSelected ? accentColor.withValues(alpha: 0.15) : scheme.surface,
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
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
