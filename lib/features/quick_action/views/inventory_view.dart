import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/widgets/app_toast.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryView extends StatefulWidget {
  final String actionType;
  const InventoryView({super.key, required this.actionType});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  final _rawUsedController = TextEditingController();
  final _laborController = TextEditingController();
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
    _rawUsedController.dispose();
    _laborController.dispose();
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
    final isAcquire = widget.actionType == 'Acquire';
    final desc = _descController.text.trim();

    if (desc.isEmpty) {
      AppToast.show(context, message: 'Description is required.');
      return;
    }

    if (isAcquire) {
      final rawAmount = _amountController.text.replaceAll(',', '').trim();
      final amount = double.tryParse(rawAmount) ?? 0;
      if (amount <= 0) {
        AppToast.show(context, message: 'Amount is required.');
        return;
      }

      int creditCode;
      switch (_paymentMethod) {
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
        TemplateLine(
          accountCode: QuickActionAccounts.inventoryRawMaterials,
          isDebit: true,
          amount: amount,
        ),
        TemplateLine(accountCode: creditCode, isDebit: false, amount: amount),
      ];

      await _postLines(desc, lines);
    } else {
      final rawRaw = _rawUsedController.text.replaceAll(',', '').trim();
      final rawUsed = double.tryParse(rawRaw) ?? 0;
      final rawLabor = _laborController.text.replaceAll(',', '').trim();
      final labor = double.tryParse(rawLabor) ?? 0;

      if (rawUsed <= 0) {
        AppToast.show(
          context,
          message: 'Enter the amount of Raw Materials used.',
        );
        return;
      }

      if (labor < 0) {
        AppToast.show(context, message: 'Direct Labor cannot be negative.');
        return;
      }

      final finishedGoodsProduced = rawUsed + labor;

      final lines = <TemplateLine>[
        TemplateLine(
          accountCode: QuickActionAccounts.inventoryFinishedGoods,
          isDebit: true,
          amount: finishedGoodsProduced,
        ),
        TemplateLine(
          accountCode: QuickActionAccounts.inventoryRawMaterials,
          isDebit: false,
          amount: rawUsed,
        ),
        if (labor > 0)
          TemplateLine(
            accountCode: QuickActionAccounts.directLabor,
            isDebit: false,
            amount: labor,
          ),
      ];

      await _postLines(desc, lines);
    }
  }

  Future<void> _postLines(String desc, List<TemplateLine> lines) async {
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
          message: 'Failed to save inventory entry. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Stream<double>? get _balanceStream {
    if (widget.actionType != 'Acquire') return null;
    if (_paymentMethod == 'cash') {
      return appDb.ledgerDao.watchBalanceForAccountCode(
        QuickActionAccounts.cashOnHand,
      );
    }
    if (_paymentMethod == 'bank') {
      return appDb.ledgerDao.watchBalanceForAccountCode(
        QuickActionAccounts.cashInBank,
      );
    }
    return null;
  }

  double get _currentAmount =>
      double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final isAcquire = widget.actionType == 'Acquire';
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        // Blend AppBar color into the pinned header
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: scheme.primary),
        title: Text(
          isAcquire ? 'Acquire Raw Materials' : 'Produce Finished Goods',
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
            QuickActionAccounts
                .inventoryRawMaterials, // Added to watch raw materials globally
          }),
          builder: (context, snap) {
            final balances =
                snap.data ??
                {
                  QuickActionAccounts.cashOnHand: 0.0,
                  QuickActionAccounts.cashInBank: 0.0,
                  QuickActionAccounts.inventoryRawMaterials: 0.0,
                };

            // Extract Balances
            final cash = balances[QuickActionAccounts.cashOnHand] ?? 0.0;
            final bank = balances[QuickActionAccounts.cashInBank] ?? 0.0;
            final rawMaterials =
                balances[QuickActionAccounts.inventoryRawMaterials] ?? 0.0;

            // Form inputs
            final rawUsed =
                double.tryParse(
                  _rawUsedController.text.replaceAll(',', '').trim(),
                ) ??
                0.0;
            final labor =
                double.tryParse(
                  _laborController.text.replaceAll(',', '').trim(),
                ) ??
                0.0;
            final totalFinishedGoods = rawUsed + labor;

            return Column(
              children: [
                // =====================================
                // 1. PINNED HEADER (Dynamic)
                // =====================================
                if (isAcquire && _paymentMethod != 'credit')
                  BeforeAfterBalanceHeader(
                    label: _paymentMethod == 'cash'
                        ? 'Cash balance'
                        : 'Bank balance',
                    before: _paymentMethod == 'cash' ? cash : bank,
                    after:
                        (_paymentMethod == 'cash' ? cash : bank) -
                        _currentAmount,
                  )
                else if (!isAcquire)
                  BeforeAfterBalanceHeader(
                    label: 'Raw Materials',
                    before: rawMaterials,
                    after: rawMaterials - rawUsed,
                  ),

                // =====================================
                // 2. SCROLLABLE CONTENT
                // =====================================
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (isAcquire) ...[
                        QuickActionAmountCard(
                          amountController: _amountController,
                          amountLabel: 'Amount',
                          onAmountChanged: () => setState(() {}),
                        ),
                        if (_paymentMethod != 'credit' &&
                            _currentAmount >
                                (_paymentMethod == 'cash' ? cash : bank) &&
                            _currentAmount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: InsufficientBalanceNotice(
                              amount: _currentAmount,
                              currentBalance: _paymentMethod == 'cash'
                                  ? cash
                                  : bank,
                              isOutflow: true,
                            ),
                          ),
                        const SizedBox(height: 24),
                        const QuickActionSectionLabel('Paid via'),
                        PaymentMethodChips(
                          value: _paymentMethod,
                          onChanged: (v) => setState(() => _paymentMethod = v),
                          creditLabel: 'Pay Later',
                          cashBalance: cash,
                          bankBalance: bank,
                        ),
                      ] else ...[
                        QuickActionAmountCard(
                          amountController: _rawUsedController,
                          amountLabel: 'Raw Materials Used',
                          onAmountChanged: () => setState(() {}),
                        ),
                        if (rawUsed > rawMaterials && rawUsed > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 18,
                                  color: scheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Insufficient raw materials.',
                                    style: TextStyle(
                                      color: scheme.error,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        QuickActionAmountCard(
                          amountController: _laborController,
                          amountLabel: 'Direct Labor',
                          onAmountChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        // Clean "Total Finished Goods" Box to replace previous footer
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Finished Goods',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${formatAmount(totalFinishedGoods)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
      bottomNavigationBar: isAcquire && _balanceStream != null
          ? StreamBuilder<double>(
              stream: _balanceStream,
              builder: (context, snap) {
                final balance = snap.data ?? 0.0;
                final insufficient =
                    _paymentMethod != 'credit' &&
                    _currentAmount > balance &&
                    _currentAmount > 0;
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
