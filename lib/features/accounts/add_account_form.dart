import 'package:bookkeeping/core/database/tables/accounts_table.dart';
import 'package:flutter/material.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/widgets/app_toast.dart';
import 'package:drift/drift.dart' as drift;

class AddAccountForm extends StatefulWidget {
  const AddAccountForm({super.key});

  @override
  State<AddAccountForm> createState() => _AddAccountFormState();
}

class _AddAccountFormState extends State<AddAccountForm> {
  bool? _isCodeAvailable;
  bool _isValidatingCode = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeController = TextEditingController();
  final _typeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _balanceController =
      TextEditingController(); // Controller for Normal Balance

  int? _selectedTypeId;
  int? _selectedCategoryId;
  bool? _isDebit; // Store the balance selection as a boolean
  bool _isSaving = false;

  List<AccountCategory> _allCategories = [];
  List<AccountCategory> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final data = await appDb.accountsDao.getAllCategories();
    setState(() => _allCategories = data);
  }

  List<AccountCategory> get _types =>
      _allCategories.where((c) => c.parent == null).toList();

  // --- Picker Logic ---

  void _showTypePicker() {
  _showCustomPicker(
    title: 'Select Account Type',
    items: _types.map((t) => t.name).toList(),
    onSelect: (name) {
      final type = _types.firstWhere((t) => t.name == name);

      setState(() {
        _selectedTypeId = type.id;
        _typeController.text = type.name;

        // Guess default balance based on standard accounting rules
        // ID 1=Asset, 2=Liability, 3=Equity, 4=Revenue, 5=Expense
        final isDebitType = (type.id == 1 || type.id == 5);
        _isDebit = isDebitType;
        _balanceController.text = isDebitType ? 'Debit' : 'Credit';

        _selectedCategoryId = null;
        _categoryController.clear();
        _filteredCategories = _allCategories.where((c) => c.parent == type.id).toList();
      });

      Future.delayed(Duration.zero, () => _showCategoryPicker());
    },
  );
}

  void _showCategoryPicker() {
    if (_selectedTypeId == null) return;
    _showCustomPicker(
      title: 'Select Category',
      items: _filteredCategories.map((c) => c.name).toList(),
      onSelect: (name) {
        final cat = _filteredCategories.firstWhere((c) => c.name == name);
        setState(() {
          _selectedCategoryId = cat.id;
          _categoryController.text = cat.name;
        });
      },
    );
  }

  void _showBalancePicker() {
    _showCustomPicker(
      title: 'Select Normal Balance',
      items: ['Debit', 'Credit'],
      onSelect: (val) {
        setState(() {
          _balanceController.text = val;
          _isDebit = val == 'Debit';
        });
      },
    );
  }

  void _showCustomPicker({
    required String title,
    required List<String> items,
    required Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            ...items.map(
              (item) => ListTile(
                title: Text(item),
                onTap: () {
                  onSelect(item);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Submission Logic ---

  Future<void> _submitData() async {
  if (_formKey.currentState!.validate() && _selectedCategoryId != null && _isDebit != null) {
    setState(() => _isSaving = true);

    final entity = AccountsCompanion.insert(
      name: _nameController.text.trim(),
      code: int.parse(_codeController.text.trim()),
      description: drift.Value(_descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim()),
      categoryId: _selectedCategoryId!,
      // Bind the normal balance from the state to the account
      normalBalance: _isDebit! ? NormalBalance.debit : NormalBalance.credit, 
      isLocked: const drift.Value(false),
    );

    try {
      await appDb.accountsDao.addAccount(entity);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      AppToast.show(context, message: 'Error: $e', isError: true);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),

                // 1. TOP ROW: Type and Category (2 Columns)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildReadOnlyField(
                        label: 'Type',
                        controller: _typeController,
                        onTap: _showTypePicker,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildReadOnlyField(
                        label: 'Category',
                        controller: _categoryController,
                        onTap: _showCategoryPicker,
                        enabled: _selectedTypeId != null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Account Name (Full width)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // 3. Account Code (Full width)
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  onChanged: _checkCodeAvailability, // Triggers the live check
                  decoration: InputDecoration(
                    labelText: 'Account Code',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.numbers),
                    // --- LIVE FEEDBACK ICON ---
                    suffixIcon: _isValidatingCode
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : (_isCodeAvailable == null
                              ? null
                              : Icon(
                                  _isCodeAvailable!
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: _isCodeAvailable!
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.error,
                                )),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (_isCodeAvailable == false)
                      return 'Code is already in use';

                    // (You can also add your 101-199 range logic here!)
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _balanceController,
                  readOnly: true, // Remains true so the keyboard doesn't pop up
                  onTap: _showBalancePicker, // User can click to change
                  decoration: const InputDecoration(
                    labelText: 'Normal Balance',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                    suffixIcon: Icon(
                      Icons.arrow_drop_down,
                    ), // Add the arrow so they know it's a menu
                    hintText: 'Select balance',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 32),

                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.arrow_drop_down),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        fillColor: enabled ? null : colorScheme.surfaceContainerHighest,
        filled: !enabled,
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildSaveButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ElevatedButton(
      onPressed: _isSaving ? null : _submitData,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _isSaving
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onPrimary,
              ),
            )
          : Text(
              'Save Account',
              style: theme.textTheme.labelLarge,
            ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'New Account',
          style: theme.textTheme.titleLarge,
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: colorScheme.onSurface),
        ),
      ],
    );
  }

  Future<void> _checkCodeAvailability(String value) async {
    if (value.isEmpty) {
      setState(() => _isCodeAvailable = null);
      return;
    }

    final code = int.tryParse(value);
    if (code == null) return;

    setState(() => _isValidatingCode = true);

    // Check your database (using the method we discussed earlier)
    final isTaken = await appDb.accountsDao.isCodeTaken(code);

    setState(() {
      _isCodeAvailable = !isTaken; // Available if NOT taken
      _isValidatingCode = false;
    });
  }
}
