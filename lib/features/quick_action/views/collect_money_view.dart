import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CollectMoneyView extends StatefulWidget {
  const CollectMoneyView({super.key});

  static const String _title = 'Collect Money';

  @override
  State<CollectMoneyView> createState() => _CollectMoneyViewState();
}

class _CollectMoneyViewState extends State<CollectMoneyView> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  String _cashLocation = 'cash';
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
            accountCode: QuickActionAccounts.accountsReceivable,
            isDebit: false,
            amount: amount,
          ),
        ],
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          CollectMoneyView._title,
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<Map<int, double>>(
        stream: appDb.ledgerDao.watchBalancesForAccountCodes({
          QuickActionAccounts.accountsReceivable,
          QuickActionAccounts.cashOnHand,
          QuickActionAccounts.cashInBank,
        }),
        builder: (context, snap) {
          final balances = snap.data ??
              {
                QuickActionAccounts.accountsReceivable: 0.0,
                QuickActionAccounts.cashOnHand: 0.0,
                QuickActionAccounts.cashInBank: 0.0,
              };

          final receivablesBefore =
              balances[QuickActionAccounts.accountsReceivable] ?? 0.0;
          final amount = parseAmount(_amountController);
          final receivablesAfter = (receivablesBefore - amount);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              BeforeAfterBalanceHeader(
                label: 'Total Receivables',
                before: receivablesBefore,
                after: receivablesAfter,
              ),
              const SizedBox(height: 16),
              QuickActionAmountCard(
                amountController: _amountController,
                amountLabel: 'Amount Collected',
                onAmountChanged: () => setState(() {}),
              ),
              const SizedBox(height: 24),
              const QuickActionSectionLabel('Received to (Cash / Bank)'),
              CashBankChips(
                value: _cashLocation,
                onChanged: (v) => setState(() => _cashLocation = v),
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
      bottomNavigationBar: QuickActionSaveButton(
        onPressed: _save,
        isSaving: _isSaving,
        label: 'Save Entry',
      ),
    );
  }
}
