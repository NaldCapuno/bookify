import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/theme/app_theme.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SellProductsView extends StatefulWidget {
  const SellProductsView({super.key});

  @override
  State<SellProductsView> createState() => _SellProductsViewState();
}

class _SellProductsViewState extends State<SellProductsView> {
  String _selectedPaymentMethod = 'cash';
  DateTime _selectedDate = DateTime.now();
  final _dateController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _cogsController = TextEditingController();
  final _descController = TextEditingController();

  bool _giveDiscount = false;
  bool _isSaving = false;
  double _currentInventory = 3000.0;

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
  double get _totalAmount => (_sellingPrice - _discount);
  double get _cogs => parseAmount(_cogsController);

  String? get _activeError {
    if (_cogs > 0 && _cogs > _currentInventory) {
      return "You don't have enough stock for this sale.";
    }
    if (_giveDiscount && _discount > 0 && _discount > _sellingPrice) {
      return "Discount is higher than the selling price.";
    }
    return null;
  }

  bool get _isValid =>
      _activeError == null &&
      _sellingPrice > 0 &&
      _cogs > 0 &&
      _descController.text.trim().isNotEmpty;

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

    if (desc.isEmpty || _sellingPrice <= 0 || _cogs <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all details before saving.'),
        ),
      );
      return;
    }

    if (_activeError != null) return;

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
      if (_discount > 0)
        TemplateLine(
          accountCode: QuickActionAccounts.salesDiscounts,
          isDebit: true,
          amount: _discount,
        ),
      TemplateLine(
        accountCode: QuickActionAccounts.salesRevenue,
        isDebit: false,
        amount: _sellingPrice,
      ),
      if (_cogs > 0) ...[
        TemplateLine(
          accountCode: QuickActionAccounts.costOfGoodsSold,
          isDebit: true,
          amount: _cogs,
        ),
        TemplateLine(
          accountCode: QuickActionAccounts.inventoryFinishedGoods,
          isDebit: false,
          amount: _cogs,
        ),
      ],
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
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Record Sale',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 320),
            children: [
              _buildHeroCard(scheme),
              const SizedBox(height: 28),
              _buildLabelledField(
                "How much goods do you wish to sell?",
                _cogsController,
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 20),
              _buildLabelledField(
                "How much is the selling price?",
                _sellingPriceController,
                customIconText: "₱",
                hideIconOnInput: false,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Give discount to customer?",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  _buildObviousToggle(scheme),
                ],
              ),
              if (_giveDiscount) ...[
                const SizedBox(height: 20),
                _buildLabelledField(
                  "Discount Amount",
                  _discountController,
                  icon: Icons.local_offer_outlined,
                  prefix: "₱",
                ),
              ],
              const SizedBox(height: 28),
              const Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              PaymentMethodChips(
                value: _selectedPaymentMethod,
                onChanged: (v) => setState(() => _selectedPaymentMethod = v),
              ),
              const SizedBox(height: 28),
              _buildLabelledField(
                "What did you sell?",
                _descController,
                icon: Icons.description_outlined,
                isNumeric: false,
                hint: "e.g. 5pcs Coffee Beans",
              ),
              const SizedBox(height: 28),
              const Text(
                "Date",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_month_outlined),
                      filled: true,
                      fillColor: scheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildGracefulSheet(scheme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(ColorScheme scheme) {
    return StreamBuilder<double>(
      stream: appDb.ledgerDao.watchBalanceForAccountCode(
        QuickActionAccounts.inventoryFinishedGoods,
      ),
      builder: (context, snap) {
        _currentInventory = snap.data ?? 3000.0;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURRENT INVENTORY',
                style: TextStyle(
                  color: scheme.onPrimary.withOpacity(0.7),
                  letterSpacing: 1.2,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '₱${formatAmount(_currentInventory)}',
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Worth of Finished Goods',
                style: TextStyle(
                  color: scheme.onPrimary.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildObviousToggle(ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn("No", !_giveDiscount, scheme),
          _toggleBtn("Yes", _giveDiscount, scheme),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, ColorScheme scheme) {
    return GestureDetector(
      onTap: () => setState(() => _giveDiscount = (label == "Yes")),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: active ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: active
                ? scheme.onPrimary
                : scheme.onSurfaceVariant.withOpacity(0.6),
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLabelledField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    String? customIconText,
    bool isNumeric = true,
    String? prefix,
    String? hint,
    bool hideIconOnInput = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final hasInput = controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          decoration: InputDecoration(
            prefixIcon: (hideIconOnInput && hasInput)
                ? null
                : (customIconText != null
                      ? Container(
                          width: 48,
                          alignment: Alignment.center,
                          child: Text(
                            customIconText,
                            style: TextStyle(
                              fontSize: 20,
                              color: scheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Icon(icon, size: 20, color: scheme.primary)),
            prefixText: prefix != null ? "$prefix " : null,
            prefixStyle: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
            ),
            hintText: hint,
            filled: true,
            fillColor: scheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(18),
          ),
        ),
      ],
    );
  }

  Widget _buildGracefulSheet(ColorScheme scheme) {
    final activeError = _activeError;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (activeError != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: scheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activeError,
                      style: TextStyle(
                        color: scheme.onErrorContainer,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _summaryLine("Subtotal", _sellingPrice, scheme),
          const SizedBox(height: 6),
          _summaryLine("Discount", _discount, scheme, isNegative: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _summaryLine("Total", _totalAmount, scheme, isBold: true),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.zero,
            child: QuickActionSaveButton(
              onPressed: (activeError != null) ? null : _save,
              isSaving: _isSaving,
              label: 'Save Transaction',
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryLine(
    String label,
    double amt,
    ColorScheme scheme, {
    bool isBold = false,
    bool isNegative = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          "${isNegative && amt > 0 ? '-' : ''}₱${formatAmount(amt.abs())}",
          style: TextStyle(
            fontSize: isBold ? 20 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isNegative && amt > 0
                ? Colors.redAccent
                : (isBold ? scheme.primary : null),
          ),
        ),
      ],
    );
  }
}
