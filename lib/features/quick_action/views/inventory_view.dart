import 'package:bookkeeping/core/database/app_database.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description is required.')),
      );
      return;
    }

    if (isAcquire) {
      final rawAmount = _amountController.text.replaceAll(',', '').trim();
      final amount = double.tryParse(rawAmount) ?? 0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amount is required.')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter the amount of Raw Materials used.'),
          ),
        );
        return;
      }

      if (labor < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Direct Labor cannot be negative.'),
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save inventory entry. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Stream<double>? get _balanceStream {
    if (widget.actionType != 'Acquire') return null;
    if (_paymentMethod == 'cash') {
      return appDb.ledgerDao.watchBalanceForAccountCode(QuickActionAccounts.cashOnHand);
    }
    if (_paymentMethod == 'bank') {
      return appDb.ledgerDao.watchBalanceForAccountCode(QuickActionAccounts.cashInBank);
    }
    return null;
  }

  String? get _balanceLabel {
    if (widget.actionType != 'Acquire') return null;
    if (_paymentMethod == 'cash') return 'Cash balance:';
    if (_paymentMethod == 'bank') return 'Bank balance:';
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
        backgroundColor: scheme.surfaceContainerHighest,
        elevation: 0,
        leading: BackButton(color: scheme.primary),
        title: Text(
          isAcquire ? 'Acquire Raw Materials' : 'Produce Finished Goods',
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
          final cash = balances[QuickActionAccounts.cashOnHand] ?? 0.0;
          final bank = balances[QuickActionAccounts.cashInBank] ?? 0.0;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (isAcquire) ...[
                if (_paymentMethod != 'credit') ...[
                  BeforeAfterBalanceHeader(
                    label: _paymentMethod == 'cash' ? 'Cash balance' : 'Bank balance',
                    before: _paymentMethod == 'cash' ? cash : bank,
                    after: (_paymentMethod == 'cash' ? cash : bank) - _currentAmount,
                  ),
                  const SizedBox(height: 16),
                ],
                QuickActionAmountCard(
                  amountController: _amountController,
                  amountLabel: 'Amount',
                  balanceStream: _balanceStream,
                  balanceLabel: _balanceLabel,
                  checkInsufficient: _paymentMethod != 'credit',
                  onAmountChanged: () => setState(() {}),
                ),
                if (_balanceStream != null)
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
            StreamBuilder<double>(
              stream: appDb.ledgerDao.watchBalanceForAccountCode(
                QuickActionAccounts.inventoryRawMaterials,
              ),
              builder: (context, snap) {
                final balance = snap.data ?? 0.0;
                final rawUsed = double.tryParse(
                      _rawUsedController.text.replaceAll(',', '').trim()) ??
                    0.0;
                final remaining = balance - rawUsed;
                final displayRemaining = remaining.clamp(0.0, double.infinity);
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Raw materials remaining: ${formatAmount(displayRemaining)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: remaining < 0 ? scheme.error : scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            QuickActionAmountCard(
              amountController: _laborController,
              amountLabel: 'Direct Labor',
              onAmountChanged: () => setState(() {}),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Builder(
                  builder: (context) {
                    final rawUsed = double.tryParse(
                          _rawUsedController.text.replaceAll(',', '').trim(),
                        ) ??
                        0.0;
                    final labor = double.tryParse(
                          _laborController.text.replaceAll(',', '').trim(),
                        ) ??
                        0.0;
                    final totalFinishedGoods = rawUsed + labor;
                    return Text(
                      'Total finished goods: ${formatAmount(totalFinishedGoods)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
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
          );
        },
      ),
      bottomNavigationBar: isAcquire && _balanceStream != null
          ? StreamBuilder<double>(
              stream: _balanceStream,
              builder: (context, snap) {
                final balance = snap.data ?? 0.0;
                final insufficient = _paymentMethod != 'credit' &&
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
