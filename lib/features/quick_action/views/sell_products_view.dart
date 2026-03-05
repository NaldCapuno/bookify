import 'package:bookkeeping/core/database/app_database.dart';
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
  final _totalController = TextEditingController();
  final _productNameController = TextEditingController();
  final _totalProductsController = TextEditingController();
  final _qtySoldController = TextEditingController();
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
    _totalController.dispose();
    _productNameController.dispose();
    _totalProductsController.dispose();
    _qtySoldController.dispose();
    _discountController.dispose();
    _cogsController.dispose();
    _descController.dispose();
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
    final totalRaw = _totalController.text.replaceAll(',', '').trim();
    final discountRaw = _discountController.text.replaceAll(',', '').trim();
    final cogsRaw = _cogsController.text.replaceAll(',', '').trim();
    final productName = _productNameController.text.trim();
    final totalProductsRaw = _totalProductsController.text.replaceAll(',', '').trim();
    final qtySoldRaw = _qtySoldController.text.replaceAll(',', '').trim();

    final total = double.tryParse(totalRaw) ?? 0;
    final totalProducts = int.tryParse(totalProductsRaw) ?? 0;
    final qtySold = int.tryParse(qtySoldRaw) ?? 0;
    final parsedDiscount = double.tryParse(discountRaw);
    final double discount = parsedDiscount == null
        ? 0
        : parsedDiscount < 0
            ? 0
            : parsedDiscount;
    final cogs = double.tryParse(cogsRaw) ?? 0;

    if (desc.isEmpty || total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description and total amount are required.')),
      );
      return;
    }

    if (productName.isNotEmpty && totalProducts > 0 && qtySold > totalProducts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity sold cannot exceed total products.')),
      );
      return;
    }

    final netCash = total - discount;
    if (netCash <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discount cannot be equal to or exceed total amount.')),
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
        description: productName.isEmpty
            ? desc
            : 'Product: $productName${qtySold > 0 ? ' (Qty sold: $qtySold)' : ''} — $desc',
        referenceNo: null,
        lines: lines,
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

  @override
  Widget build(BuildContext context) {
    final isCreditSale = _selectedPaymentMethod == 'credit';
    final totalProducts = int.tryParse(_totalProductsController.text.trim()) ?? 0;
    final qtySold = int.tryParse(_qtySoldController.text.trim()) ?? 0;
    final remaining = (totalProducts - qtySold);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Record Sale',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          QuickActionAmountCard(
            amountController: _totalController,
            amountLabel: 'Total Amount',
            balanceStream: _balanceStream,
            balanceLabel: _balanceLabel,
            checkInsufficient: false,
            onAmountChanged: () => setState(() {}),
          ),
          const SizedBox(height: 24),
          const QuickActionSectionLabel('Payment Method'),
          PaymentMethodChips(
            value: _selectedPaymentMethod,
            onChanged: (v) => setState(() => _selectedPaymentMethod = v),
          ),
          if (isCreditSale)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will be recorded as an Account Receivable.',
                      style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _productNameController,
                  decoration: const InputDecoration(
                    labelText: 'What product is this?',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                    border: UnderlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const Divider(height: 24),
                TextField(
                  controller: _totalProductsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total products available (Finished Goods)',
                    prefixIcon: Icon(Icons.warehouse_outlined),
                    border: UnderlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const Divider(height: 24),
                TextField(
                  controller: _qtySoldController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'How many will you sell?',
                    prefixIcon: Icon(Icons.shopping_cart_outlined),
                    border: UnderlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (totalProducts > 0 && qtySold >= 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Finished Goods remaining: ${remaining < 0 ? 0 : remaining}',
                        style: TextStyle(
                          fontSize: 12,
                          color: remaining < 0 ? Colors.red.shade700 : Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
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
            descriptionHint: 'Describe what was sold and any notes',
          ),
          const SizedBox(height: 16),
          _buildExtraField(
            controller: _discountController,
            label: 'Is there a discount? (optional amount)',
            icon: Icons.percent,
          ),
          const SizedBox(height: 12),
          _buildExtraField(
            controller: _cogsController,
            label: 'Total value of goods sold (COGS)',
            icon: Icons.inventory_2_outlined,
          ),
        ],
      ),
      bottomNavigationBar: QuickActionSaveButton(
        onPressed: _save,
        isSaving: _isSaving,
        label: 'Save Transaction',
      ),
    );
  }

  Widget _buildExtraField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black87),
          border: const UnderlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
