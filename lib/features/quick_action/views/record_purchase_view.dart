import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/theme/app_theme.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordPurchaseView extends StatefulWidget {
  final String initialCategory;

  const RecordPurchaseView({super.key, required this.initialCategory});

  @override
  State<RecordPurchaseView> createState() => _RecordPurchaseViewState();
}

class _RecordPurchaseViewState extends State<RecordPurchaseView> {
  String _selectedPaymentMethod = 'bank';
  late String _currentCategory;
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.initialCategory;
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

  int? _assetAccountForCategory(String category) {
    switch (category) {
      case 'Supplies':
        return QuickActionAccounts.supplies;
      case 'Equipment':
        return QuickActionAccounts.equipment;
      case 'Furniture':
        return QuickActionAccounts.furnitureAndFixtures;
      case 'Land':
        return QuickActionAccounts.land;
      case 'Building':
        return QuickActionAccounts.building;
      case 'Vehicle':
        return QuickActionAccounts.vehicle;
      default:
        return null;
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

    final assetCode = _assetAccountForCategory(_currentCategory);
    if (assetCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Quick Purchase currently supports Supplies, Equipment, and Furniture only.',
          ),
        ),
      );
      return;
    }

    int creditCode;
    switch (_selectedPaymentMethod) {
      case 'cash':
        creditCode = QuickActionAccounts.cashOnHand;
        break;
      case 'bank':
        creditCode = QuickActionAccounts.cashInBank;
        break;
      case 'credit':
        creditCode = QuickActionAccounts.accountsPayable;
        break;
      default:
        creditCode = QuickActionAccounts.cashOnHand;
    }

    final lines = <TemplateLine>[
      TemplateLine(accountCode: assetCode, isDebit: true, amount: amount),
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
          const SnackBar(content: Text('Failed to save purchase. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Stream<double>? get _balanceStream {
    if (_selectedPaymentMethod == 'cash') {
      return appDb.ledgerDao.watchBalanceForAccountCode(QuickActionAccounts.cashOnHand);
    }
    if (_selectedPaymentMethod == 'bank') {
      return appDb.ledgerDao.watchBalanceForAccountCode(QuickActionAccounts.cashInBank);
    }
    return null;
  }

  String? get _balanceLabel {
    if (_selectedPaymentMethod == 'cash') return 'Cash balance:';
    if (_selectedPaymentMethod == 'bank') return 'Bank balance:';
    return null;
  }

  bool get _isOutflow => _selectedPaymentMethod == 'cash' || _selectedPaymentMethod == 'bank';

  double get _currentAmount =>
      double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final isUnpaid = _selectedPaymentMethod == 'credit';
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: scheme.surfaceContainerHighest,
        elevation: 0,
        leading: BackButton(color: scheme.primary),
        title: Text(
          'Record Purchase',
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
          final balances = snap.data ?? {
            QuickActionAccounts.cashOnHand: 0.0,
            QuickActionAccounts.cashInBank: 0.0,
          };
          final cashBalance = balances[QuickActionAccounts.cashOnHand] ?? 0.0;
          final bankBalance = balances[QuickActionAccounts.cashInBank] ?? 0.0;
          final amount = _currentAmount;
          final isCash = _selectedPaymentMethod == 'cash';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_isOutflow) ...[
                BeforeAfterBalanceHeader(
                  label: isCash ? 'Cash balance' : 'Bank balance',
                  before: isCash ? cashBalance : bankBalance,
                  after: (isCash ? cashBalance : bankBalance) - amount,
                ),
                const SizedBox(height: 16),
              ],
              QuickActionAmountCard(
                amountController: _amountController,
                amountLabel: 'Amount',
                balanceStream: _balanceStream,
                balanceLabel: _balanceLabel,
                checkInsufficient: _isOutflow,
                onAmountChanged: () => setState(() {}),
              ),
              if (_isOutflow && _balanceStream != null)
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
              const QuickActionSectionLabel('Paid via'),
              PaymentMethodChips(
                value: _selectedPaymentMethod,
                onChanged: (v) => setState(() => _selectedPaymentMethod = v),
                creditLabel: 'Pay Later',
                cashBalance: balances[QuickActionAccounts.cashOnHand],
                bankBalance: balances[QuickActionAccounts.cashInBank],
              ),
          if (isUnpaid)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: context.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Will be recorded as Accounts Payable (Debt).',
                      style: TextStyle(color: context.warning, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: DropdownButtonFormField<String>(
              value: _currentCategory,
              items: ['Supplies', 'Equipment', 'Furniture', 'Land', 'Building', 'Vehicle']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _currentCategory = v);
              },
              decoration: const InputDecoration(
                labelText: 'Asset Category',
                prefixIcon: Icon(Icons.category_outlined),
                border: UnderlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          QuickActionDetailsCard(
            descriptionController: _descController,
            dateText: _dateController.text,
            onDateTap: _pickDate,
            descriptionHint: 'e.g. 2 Laptops for office',
          ),
            ],
          );
        },
      ),
      bottomNavigationBar: _isOutflow && _balanceStream != null
          ? StreamBuilder<double>(
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
            )
          : QuickActionSaveButton(
              onPressed: _save,
              isSaving: _isSaving,
              label: 'Save Entry',
            ),
    );
  }
}
