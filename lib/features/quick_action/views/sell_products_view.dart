import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/theme/app_theme.dart';
import 'package:bookkeeping/features/quick_action/quick_action_journal_service.dart';
import 'package:bookkeeping/features/quick_action/widgets/quick_action_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for TextInputFormatter
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

  final _cogsFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _discountFocus = FocusNode();

  bool _giveDiscount = false;
  bool _isSaving = false;
  double _currentInventory = 3000.0;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('MM/dd/yyyy').format(_selectedDate);

    _cogsFocus.addListener(() => setState(() {}));
    _priceFocus.addListener(() => setState(() {}));
    _discountFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _dateController.dispose();
    _sellingPriceController.dispose();
    _discountController.dispose();
    _cogsController.dispose();
    _descController.dispose();
    _cogsFocus.dispose();
    _priceFocus.dispose();
    _discountFocus.dispose();
    super.dispose();
  }

  // Helper to parse the comma-separated text back to double
  double _parseDisplayAmount(String value) {
    return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
  }

  double get _sellingPrice => _parseDisplayAmount(_sellingPriceController.text);
  double get _discount =>
      _giveDiscount ? _parseDisplayAmount(_discountController.text) : 0.0;
  double get _totalAmount => (_sellingPrice - _discount);
  double get _cogs => _parseDisplayAmount(_cogsController.text);

  String? get _activeError {
    if (_cogs > 0 && _currentInventory > 0 && _cogs > _currentInventory) {
      return "You don't have enough stock for this sale.";
    }
    if (_giveDiscount && _discount > 0 && _discount > _sellingPrice) {
      return "Discount is higher than the selling price.";
    }
    return null;
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
    if (desc.isEmpty || _sellingPrice <= 0 || _cogs <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all details.')),
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
              _buildInventoryNotice(scheme),
              const SizedBox(height: 32),

              _buildModernInput(
                "How much goods do you wish to sell?",
                _cogsController,
                _cogsFocus,
                hint: "0.00",
              ),
              const SizedBox(height: 24),
              _buildModernInput(
                "Selling price",
                _sellingPriceController,
                _priceFocus,
                hint: "0.00",
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Give discount?",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  _buildObviousToggle(scheme),
                ],
              ),

              if (_giveDiscount) ...[
                const SizedBox(height: 24),
                _buildModernInput(
                  "Discount amount",
                  _discountController,
                  _discountFocus,
                  hint: "0.00",
                ),
              ],

              const SizedBox(height: 32),
              const Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              PaymentMethodChips(
                value: _selectedPaymentMethod,
                onChanged: (v) => setState(() => _selectedPaymentMethod = v),
              ),

              const SizedBox(height: 32),
              _buildModernInput(
                "What did you sell?",
                _descController,
                null,
                isNumeric: false,
                hint: "e.g. Arabica Coffee Beans",
              ),

              const SizedBox(height: 32),
              const Text(
                "Date",
                style: TextStyle(
                  fontSize: 14,
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
                      filled: true,
                      fillColor: scheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
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

  Widget _buildInventoryNotice(ColorScheme scheme) {
    return StreamBuilder<double>(
      stream: appDb.ledgerDao.watchBalanceForAccountCode(
        QuickActionAccounts.inventoryFinishedGoods,
      ),
      builder: (context, snap) {
        _currentInventory = snap.data ?? 3000.0;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2196F3), width: 1),
          ),
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  const TextSpan(text: "You currently have "),
                  TextSpan(
                    text: _currencyFormatter.format(_currentInventory),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                      fontSize: 16,
                    ),
                  ),
                  const TextSpan(text: " Finished Goods."),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernInput(
    String label,
    TextEditingController controller,
    FocusNode? focusNode, {
    bool isNumeric = true,
    String? hint,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isFocused = focusNode?.hasFocus ?? false;
    final hasText = controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (val) => setState(() {}),
          inputFormatters: isNumeric
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  _CurrencyInputFormatter(),
                ]
              : [],
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          decoration: InputDecoration(
            // Peso Sign Fix: Scale and Baseline alignment
            prefixText: (isNumeric && (isFocused || hasText)) ? "₱ " : null,
            prefixStyle: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              height: 0.85, // Pulls the Peso sign up to align with numbers
            ),
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.withOpacity(0.7),
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: scheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: scheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildObviousToggle(ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: active ? scheme.onPrimary : scheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
            color: Colors.black12,
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
          QuickActionSaveButton(
            onPressed: (activeError != null) ? null : _save,
            isSaving: _isSaving,
            label: 'Save Transaction',
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
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          "${isNegative && amt > 0 ? '-' : ''}${_currencyFormatter.format(amt.abs())}",
          style: TextStyle(
            fontSize: 18,
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

// Custom Formatter to handle Real-time commas and .00 decimals
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) return newValue;

    double value = double.parse(newValue.text);
    final formatter = NumberFormat("#,##0.00", "en_US");
    String newText = formatter.format(value / 100);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
