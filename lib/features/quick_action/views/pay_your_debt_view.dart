import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PayYourDebtView extends StatefulWidget {
  const PayYourDebtView({super.key});

  static const String _title = 'Pay your Debt';

  @override
  State<PayYourDebtView> createState() => _PayYourDebtViewState();
}

class _PayYourDebtViewState extends State<PayYourDebtView> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  String _debtType = 'ap';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description and amount are required.')),
      );
      return;
    }

    final int debitCode = _debtType == 'ap'
        ? QuickActionAccounts.accountsPayable
        : QuickActionAccounts.longTermLoans;

    final creditCode = _paymentMethod == 'cash'
        ? QuickActionAccounts.cashOnHand
        : QuickActionAccounts.cashInBank;

    final debtBefore = await appDb.ledgerDao
        .watchBalanceForAccountCode(debitCode)
        .first;
    if (amount > debtBefore) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment amount cannot exceed the recorded debt. Reduce the amount.',
            ),
          ),
        );
      }
      return;
    }

    final cashOrBankBefore = await appDb.ledgerDao
        .watchBalanceForAccountCode(creditCode)
        .first;
    if (amount > cashOrBankBefore) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Insufficient balance in selected payment method. Reduce the amount.',
            ),
          ),
        );
      }
      return;
    }

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
          const SnackBar(
            content: Text('Failed to save payment. Please try again.'),
          ),
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
          PayYourDebtView._title,
          style:
              textTheme.headlineLarge?.copyWith(fontSize: 20) ??
              TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<Map<int, double>>(
        stream: appDb.ledgerDao.watchBalancesForAccountCodes({
          QuickActionAccounts.cashOnHand,
          QuickActionAccounts.cashInBank,
          QuickActionAccounts.accountsPayable,
          QuickActionAccounts.longTermLoans,
        }),
        builder: (context, snap) {
          final balances =
              snap.data ??
              {
                QuickActionAccounts.cashOnHand: 0.0,
                QuickActionAccounts.cashInBank: 0.0,
                QuickActionAccounts.accountsPayable: 0.0,
                QuickActionAccounts.longTermLoans: 0.0,
              };
          final cash = balances[QuickActionAccounts.cashOnHand] ?? 0.0;
          final bank = balances[QuickActionAccounts.cashInBank] ?? 0.0;
          final amount = parseAmount(_amountController);

          final isCash = _paymentMethod == 'cash';
          final cashOrBankBefore = isCash ? cash : bank;
          final cashOrBankAfter = cashOrBankBefore - amount;

          final payableDebt =
              balances[QuickActionAccounts.accountsPayable] ?? 0.0;
          final loanDebt = balances[QuickActionAccounts.longTermLoans] ?? 0.0;

          final selectedDebtBefore = _debtType == 'ap' ? payableDebt : loanDebt;

          final exceedsDebt = amount > 0 && amount > selectedDebtBefore;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              BeforeAfterBalanceHeader(
                label: isCash ? 'Cash balance' : 'Bank balance',
                before: cashOrBankBefore,
                after: cashOrBankAfter,
              ),
              const SizedBox(height: 16),
              QuickActionAmountCard(
                amountController: _amountController,
                amountLabel: 'Amount',
                onAmountChanged: () => setState(() {}),
              ),
              InsufficientBalanceNotice(
                amount: amount,
                currentBalance: cashOrBankBefore,
                isOutflow: true,
              ),
              if (exceedsDebt)
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
                          'Amount cannot exceed recorded debt (${formatAmount(selectedDebtBefore)}).',
                          style: TextStyle(
                            color: scheme.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              const QuickActionSectionLabel('Debt Account'),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _DebtChip(
                          label: 'Payable',
                          isSelected: _debtType == 'ap',
                          onTap: () => setState(() => _debtType = 'ap'),
                          accentColor: const Color(0xFF1976D2), // Blue
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DebtChip(
                          label: 'Loan',
                          isSelected: _debtType == 'loan',
                          onTap: () => setState(() => _debtType = 'loan'),
                          accentColor: const Color(0xFF7B1FA2), // Purple
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _SelectedDebtBalanceCard(
                debtType: _debtType,
                payableDebt: payableDebt,
                loanDebt: loanDebt,
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
            ],
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<Map<int, double>>(
        stream: appDb.ledgerDao.watchBalancesForAccountCodes({
          QuickActionAccounts.cashOnHand,
          QuickActionAccounts.cashInBank,
          QuickActionAccounts.accountsPayable,
          QuickActionAccounts.longTermLoans,
        }),
        builder: (context, snap) {
          final balances =
              snap.data ??
              {
                QuickActionAccounts.cashOnHand: 0.0,
                QuickActionAccounts.cashInBank: 0.0,
                QuickActionAccounts.accountsPayable: 0.0,
                QuickActionAccounts.longTermLoans: 0.0,
              };

          final cash = balances[QuickActionAccounts.cashOnHand] ?? 0.0;
          final bank = balances[QuickActionAccounts.cashInBank] ?? 0.0;
          final amount = parseAmount(_amountController);

          final isCash = _paymentMethod == 'cash';
          final cashOrBankBefore = isCash ? cash : bank;
          final insufficientCashOrBank =
              amount > 0 && amount > cashOrBankBefore;

          final int debtCode;
          if (_debtType == 'ap') {
            debtCode = QuickActionAccounts.accountsPayable;
          } else {
            debtCode = QuickActionAccounts.longTermLoans;
          }
          final debtBefore = balances[debtCode] ?? 0.0;
          final exceedsDebt = amount > 0 && amount > debtBefore;

          return QuickActionSaveButton(
            onPressed: (insufficientCashOrBank || exceedsDebt) ? null : _save,
            isSaving: _isSaving,
            label: 'Save Entry',
          );
        },
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
              color: isSelected
                  ? accentColor
                  : accentColor.withValues(alpha: 0.4),
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

class _SelectedDebtBalanceCard extends StatelessWidget {
  const _SelectedDebtBalanceCard({
    required this.debtType,
    required this.payableDebt,
    required this.loanDebt,
  });

  final String debtType;
  final double payableDebt;
  final double loanDebt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = debtType == 'ap' ? 'Payable balance' : 'Loan balance';
    final value = (debtType == 'ap' ? payableDebt : loanDebt).abs();

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
              '$label: ${formatAmount(value)}',
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
