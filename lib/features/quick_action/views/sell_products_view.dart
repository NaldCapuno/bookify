import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/theme/app_theme.dart';
import 'package:bookkeeping/core/widgets/app_toast.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SellProductsView extends StatefulWidget {
  const SellProductsView({super.key});

  static const String _title = 'Record Sale';

  @override
  State<SellProductsView> createState() => _SellProductsViewState();
}

class _SellProductsViewState extends State<SellProductsView> {
  String _selectedPaymentMethod = 'cash';
  bool _giveDiscount = false;
  bool _isSaving = false;
  bool _attemptedSubmit = false;

  DateTime _selectedDate = DateTime.now();
  final _dateController = TextEditingController();

  final _sellingPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _cogsController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('MM/dd/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _sellingPriceController.dispose();
    _discountController.dispose();
    _cogsController.dispose();
    _descController.dispose();
    super.dispose();
  }

  double get _sellingPrice => parseAmount(_sellingPriceController);
  double get _discount =>
      _giveDiscount ? parseAmount(_discountController) : 0.0;
  double get _cogs => parseAmount(_cogsController);
  double get _totalAmount => _sellingPrice - _discount;

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

  Future<void> _save({required double finishedGoodsBefore}) async {
    final desc = _descController.text.trim();
    final sellingPrice = _sellingPrice;
    final cogs = _cogs;
    final discount = _discount;

    final missingRequired = desc.isEmpty || sellingPrice <= 0 || cogs <= 0;
    final discountInvalid =
        _giveDiscount && discount > 0 && discount >= sellingPrice;
    final insufficientStock =
        cogs > 0 && finishedGoodsBefore > 0 && cogs > finishedGoodsBefore;

    if (missingRequired || discountInvalid || insufficientStock) {
      setState(() => _attemptedSubmit = true);
      return;
    }

    int paymentAccountCode;
    switch (_selectedPaymentMethod) {
      case 'cash':
        paymentAccountCode = QuickActionAccounts.cashOnHand;
        break;
      case 'bank':
        paymentAccountCode = QuickActionAccounts.cashInBank;
        break;
      case 'credit':
        paymentAccountCode = QuickActionAccounts.accountsReceivable;
        break;
      default:
        paymentAccountCode = QuickActionAccounts.cashOnHand;
    }

    final lines = <TemplateLine>[
      TemplateLine(
        accountCode: paymentAccountCode,
        isDebit: true,
        amount: _totalAmount,
      ),
      if (discount > 0)
        TemplateLine(
          accountCode: QuickActionAccounts.salesDiscounts,
          isDebit: true,
          amount: discount,
        ),
      TemplateLine(
        accountCode: QuickActionAccounts.salesRevenue,
        isDebit: false,
        amount: sellingPrice,
      ),
      TemplateLine(
        accountCode: QuickActionAccounts.costOfGoodsSold,
        isDebit: true,
        amount: cogs,
      ),
      TemplateLine(
        accountCode: QuickActionAccounts.inventoryFinishedGoods,
        isDebit: false,
        amount: cogs,
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
        AppToast.show(
          context,
          message: 'Failed to save sale. Please try again.',
          isError: true,
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
          SellProductsView._title,
          style:
              textTheme.headlineLarge?.copyWith(fontSize: 20) ??
              TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<double>(
        stream: appDb.ledgerDao.watchBalanceForAccountCode(
          QuickActionAccounts.inventoryFinishedGoods,
        ),
        builder: (context, snap) {
          final finishedGoodsBefore = snap.data ?? 0.0;
          final remaining = finishedGoodsBefore - _cogs;
          final displayRemaining = remaining.clamp(0.0, double.infinity);

          final cogsMissing = _attemptedSubmit && _cogs <= 0;
          final sellingPriceMissing = _attemptedSubmit && _sellingPrice <= 0;
          final descMissing =
              _attemptedSubmit && _descController.text.trim().isEmpty;

          final insufficientStock =
              _cogs > 0 &&
              finishedGoodsBefore > 0 &&
              _cogs > finishedGoodsBefore;
          final discountInvalid =
              _giveDiscount &&
              _discount > 0 &&
              _discount >= _sellingPrice &&
              _sellingPrice > 0;

          return SafeArea(
            top: false,
            child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: scheme.tertiary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.tertiary, width: 1),
                ),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: scheme.onSurface, fontSize: 14),
                      children: [
                        const TextSpan(text: 'You currently have '),
                        TextSpan(
                          text: '₱ ${formatAmount(finishedGoodsBefore)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                            fontSize: 16,
                          ),
                        ),
                        const TextSpan(text: ' Finished Goods.'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'How much goods do you wish to sell?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _cogsController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  filled: true,
                  fillColor: scheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: cogsMissing || insufficientStock
                          ? scheme.error
                          : scheme.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: cogsMissing || insufficientStock
                          ? scheme.error
                          : scheme.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: cogsMissing || insufficientStock
                          ? scheme.error
                          : scheme.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 6),
              if (insufficientStock) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "You don't have enough stock for this sale.",
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Selling price',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _sellingPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  filled: true,
                  fillColor: scheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: sellingPriceMissing
                          ? scheme.error
                          : scheme.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: sellingPriceMissing
                          ? scheme.error
                          : scheme.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: sellingPriceMissing
                          ? scheme.error
                          : scheme.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Give discount?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _discountToggleButton(
                          label: 'No',
                          isActive: !_giveDiscount,
                          scheme: scheme,
                          onTap: () => setState(() => _giveDiscount = false),
                        ),
                        _discountToggleButton(
                          label: 'Yes',
                          isActive: _giveDiscount,
                          scheme: scheme,
                          onTap: () => setState(() => _giveDiscount = true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_giveDiscount) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _discountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    filled: true,
                    fillColor: scheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: discountInvalid
                            ? scheme.error
                            : scheme.outlineVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: discountInvalid
                            ? scheme.error
                            : scheme.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: discountInvalid ? scheme.error : scheme.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (discountInvalid) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Discount cannot be equal to or exceed the selling price.',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              const QuickActionSectionLabel('Payment Method'),
              PaymentMethodChips(
                value: _selectedPaymentMethod,
                onChanged: (v) => setState(() => _selectedPaymentMethod = v),
              ),
              if (_selectedPaymentMethod == 'credit')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: context.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This will be recorded as an Account Receivable.',
                          style: TextStyle(
                            color: context.warning,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'What did you sell?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Arabica Coffee Beans',
                  filled: true,
                  fillColor: scheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: descMissing ? scheme.error : scheme.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: descMissing ? scheme.error : scheme.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: descMissing ? scheme.error : scheme.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              Text(
                'Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: scheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<double>(
        stream: appDb.ledgerDao.watchBalanceForAccountCode(
          QuickActionAccounts.inventoryFinishedGoods,
        ),
        builder: (context, snap) {
          final finishedGoodsBefore = snap.data ?? 0.0;
          final scheme = Theme.of(context).colorScheme;
          final totalInvalid =
              _attemptedSubmit && _sellingPrice > 0 && _totalAmount <= 0;
          return Material(
            color: Colors.transparent,
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.18),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _summaryRow('Subtotal', _sellingPrice, scheme),
                          const SizedBox(height: 4),
                          _summaryRow('Discount', _discount, scheme),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          _summaryRow(
                            'Total',
                            _totalAmount,
                            scheme,
                            isBold: true,
                          ),
                          if (totalInvalid) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 18,
                                  color: scheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Total must be greater than 0.',
                                    style: TextStyle(
                                      color: scheme.error,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    QuickActionSaveButton(
                      onPressed: () =>
                          _save(finishedGoodsBefore: finishedGoodsBefore),
                      isSaving: _isSaving,
                      label: 'Save Transaction',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _summaryRow(
    String label,
    double amount,
    ColorScheme scheme, {
    bool isBold = false,
  }) {
    final display = amount.isNaN || amount.isInfinite ? 0.0 : amount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
        Text(
          '₱ ${formatAmount(display.abs())}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _discountToggleButton({
    required String label,
    required bool isActive,
    required ColorScheme scheme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? scheme.onSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? scheme.surface : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
