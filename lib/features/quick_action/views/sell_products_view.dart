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
  bool _isSaving = false;

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
  double get _discount {
    final d = double.tryParse(
      _discountController.text.replaceAll(',', '').trim(),
    );
    return d == null || d < 0 ? 0 : d;
  }

  double get _totalAmount =>
      (_sellingPrice - _discount).clamp(0.0, double.infinity);

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
    final total = _sellingPrice;
    final discount = _discount;
    final cogs = parseAmount(_cogsController);

    if (desc.isEmpty || total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('What was sold and selling price are required.'),
        ),
      );
      return;
    }

    final netCash = total - discount;
    if (netCash <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Discount cannot be equal to or exceed total amount.'),
        ),
      );
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
        amount: netCash,
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
        amount: total,
      ),
      if (cogs > 0)
        TemplateLine(
          accountCode: QuickActionAccounts.costOfGoodsSold,
          isDebit: true,
          amount: cogs,
        ),
      if (cogs > 0)
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save entry. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreditSale = _selectedPaymentMethod == 'credit';
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        // Set AppBar color to surface so it blends with the header below
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: scheme.primary),
        title: Text(
          'Record Sale',
          style:
              textTheme.headlineLarge?.copyWith(fontSize: 20) ??
              TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // =====================================
            // 1. PINNED HEADER (Always visible)
            // =====================================
            StreamBuilder<double>(
              stream: appDb.ledgerDao.watchBalanceForAccountCode(
                QuickActionAccounts.inventoryFinishedGoods,
              ),
              builder: (context, snap) {
                final balance = snap.data ?? 0.0;
                final cogs = parseAmount(_cogsController);
                final remaining = (balance - cogs).clamp(0.0, double.infinity);

                return BeforeAfterBalanceHeader(
                  label: 'Finished Goods',
                  before: balance,
                  after: remaining,
                );
              },
            ),

            // =====================================
            // 2. SCROLLABLE CONTENT (The Form)
            // =====================================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildExtraField(
                    context,
                    controller: _sellingPriceController,
                    label: 'Selling price',
                    icon: Icons.sell_outlined,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  _buildExtraField(
                    context,
                    controller: _discountController,
                    label: 'Is there a discount? (optional amount)',
                    icon: Icons.percent,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 16),
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
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${formatAmount(_totalAmount)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildExtraField(
                    context,
                    controller: _cogsController,
                    label: 'Total value of goods sold (COGS)',
                    icon: Icons.inventory_2_outlined,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  const QuickActionSectionLabel('Payment Method'),
                  PaymentMethodChips(
                    value: _selectedPaymentMethod,
                    onChanged: (v) =>
                        setState(() => _selectedPaymentMethod = v),
                  ),
                  if (isCreditSale)
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
                  QuickActionDetailsCard(
                    descriptionController: _descController,
                    dateText: _dateController.text,
                    onDateTap: _pickDate,
                    descriptionLabel: 'What was sold?',
                    descriptionHint:
                        'e.g. product name, quantity sold, discount if any',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: QuickActionSaveButton(
        onPressed: _save,
        isSaving: _isSaving,
        label: 'Save Transaction',
      ),
    );
  }

  Widget _buildExtraField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    VoidCallback? onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: scheme.onSurface),
          border: const UnderlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          // Call the format utility on focus lost
          // Note: Add FocusNode if you want strict format-on-unfocus,
          // or rely on onChanged as you have it here.
        ),
        onChanged: onChanged != null ? (_) => onChanged() : null,
      ),
    );
  }
}
