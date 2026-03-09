import 'package:bookkeeping/core/widgets/app_toast.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvestToBusinessView extends StatefulWidget {
  const InvestToBusinessView({super.key});

  static const String _title = 'Invest to Business';

  @override
  State<InvestToBusinessView> createState() => _InvestToBusinessViewState();
}

class _InvestToBusinessViewState extends State<InvestToBusinessView> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  String _cashLocation = 'cash';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _attemptedSubmit = false;

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
      setState(() => _attemptedSubmit = true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final toCashOnHand = _cashLocation == 'cash';
      await QuickActionJournalService.instance.postTemplateEntry(
        date: _selectedDate,
        description: desc,
        referenceNo: null,
        lines: [
          TemplateLine(
            accountCode: toCashOnHand
                ? QuickActionAccounts.cashOnHand
                : QuickActionAccounts.cashInBank,
            isDebit: true,
            amount: amount,
          ),
          TemplateLine(
            accountCode: QuickActionAccounts.ownersCapital,
            isDebit: false,
            amount: amount,
          ),
        ],
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        AppToast.show(context, message: 'Failed to save entry. Please try again.', isError: true);
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
          InvestToBusinessView._title,
          style: textTheme.headlineLarge?.copyWith(fontSize: 20) ??
              TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          QuickActionAmountCard(
            amountController: _amountController,
            amountLabel: 'Amount Invested',
            onAmountChanged: () => setState(() {}),
            errorText: _attemptedSubmit && parseAmount(_amountController) <= 0
                ? 'Amount is required.'
                : null,
          ),
          const SizedBox(height: 24),
          const QuickActionSectionLabel('Invested as (Cash / Bank)'),
          CashBankChips(
            value: _cashLocation,
            onChanged: (v) => setState(() => _cashLocation = v),
          ),
          const SizedBox(height: 24),
          QuickActionDetailsCard(
            descriptionController: _descController,
            dateText: _dateController.text,
            onDateTap: _pickDate,
            descriptionErrorText:
                _attemptedSubmit && _descController.text.trim().isEmpty
                    ? 'Description is required.'
                    : null,
            onDescriptionChanged: () => setState(() {}),
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
