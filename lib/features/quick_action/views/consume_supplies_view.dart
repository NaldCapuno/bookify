import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/widgets/app_toast.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConsumeSuppliesView extends StatefulWidget {
  const ConsumeSuppliesView({super.key});

  static const String _title = 'Consume Supplies';

  @override
  State<ConsumeSuppliesView> createState() => _ConsumeSuppliesViewState();
}

class _ConsumeSuppliesViewState extends State<ConsumeSuppliesView> {
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
      AppToast.show(context, message: 'Description and amount are required.');
      return;
    }

    final lines = <TemplateLine>[
      TemplateLine(
        accountCode: QuickActionAccounts.suppliesExpense,
        isDebit: true,
        amount: amount,
      ),
      TemplateLine(
        accountCode: QuickActionAccounts.supplies,
        isDebit: false,
        amount: amount,
      ),
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
          ConsumeSuppliesView._title,
          style: textTheme.headlineLarge?.copyWith(fontSize: 20) ??
              TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          QuickActionAmountCard(
            amountController: _amountController,
            amountLabel: 'Amount (value of supplies used)',
            onAmountChanged: () => setState(() {}),
          ),
          StreamBuilder<double>(
            stream: appDb.ledgerDao
                .watchBalanceForAccountCode(QuickActionAccounts.supplies),
            builder: (context, snap) {
              final scheme = Theme.of(context).colorScheme;
              final balance = snap.data ?? 0.0;
              final used = parseAmount(_amountController);
              final remaining = balance - used;
              final displayRemaining = remaining.clamp(0.0, double.infinity);
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Supplies Remaining: ${formatAmount(displayRemaining)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: remaining < 0
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
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
