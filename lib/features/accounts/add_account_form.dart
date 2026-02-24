import 'package:flutter/material.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:drift/drift.dart' as drift;

class AddAccountForm extends StatefulWidget {
  const AddAccountForm({super.key});

  @override
  State<AddAccountForm> createState() => _AddAccountFormState();
}

class _AddAccountFormState extends State<AddAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  // Display controllers for the selection fields
  final _typeController = TextEditingController();
  final _categoryController = TextEditingController();

  int? _selectedTypeId;
  int? _selectedCategoryId;
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
    setState(() {
      _allCategories = data;
    });
  }

  // Filters root types (Asset, Liability, etc. where parent is null)
  List<AccountCategory> get _types =>
      _allCategories.where((c) => c.parent == null).toList();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _typeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // --- Picker Logic ---

  void _showTypePicker() {
    _showCustomPicker(
      title: 'Select Account Type',
      items: _types,
      onSelect: (type) {
        setState(() {
          _selectedTypeId = type.id;
          _typeController.text = type.name;

          // Reset Category when Type changes
          _selectedCategoryId = null;
          _categoryController.clear();
          _filteredCategories = _allCategories
              .where((c) => c.parent == type.id)
              .toList();
        });
        Future.delayed(Duration.zero, () {
          if (mounted) _showCategoryPicker();
        });
      },
    );
  }

  void _showCategoryPicker() {
    if (_selectedTypeId == null) return;
    _showCustomPicker(
      title: 'Select Category',
      items: _filteredCategories,
      onSelect: (cat) {
        setState(() {
          _selectedCategoryId = cat.id;
          _categoryController.text = cat.name;
        });
      },
    );
  }

  void _showCustomPicker({
    required String title,
    required List<AccountCategory> items,
    required Function(AccountCategory) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.name),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () {
                      Navigator.pop(context);
                      onSelect(item);
                    },
                  );
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
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      setState(() => _isSaving = true);

      final entity = AccountsCompanion.insert(
        name: _nameController.text.trim(),
        code: int.parse(_codeController.text.trim()),
        categoryId: _selectedCategoryId!,
        isLocked: const drift.Value(false),
      );

      try {
        await appDb.accountsDao.addAccount(entity);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving account: $e')));
        }
      }
    }
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
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

                // Account Name
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

                // Account Code
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Account Code',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (int.tryParse(val) == null) return 'Must be a number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Type Selection
                TextFormField(
                  controller: _typeController,
                  readOnly: true,
                  onTap: _showTypePicker,
                  decoration: const InputDecoration(
                    labelText: 'Account Type',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                    prefixIcon: Icon(Icons.account_balance_outlined),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Select a type' : null,
                ),
                const SizedBox(height: 16),

                // Category Selection
                TextFormField(
                  controller: _categoryController,
                  readOnly: true,
                  enabled: _selectedTypeId != null,
                  onTap: _selectedTypeId == null ? null : _showCategoryPicker,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: const OutlineInputBorder(),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    suffixIcon: _selectedTypeId == null
                        ? null
                        : const Icon(Icons.arrow_drop_down),
                    prefixIcon: Icon(
                      Icons.category_outlined,
                      color: _selectedTypeId == null ? Colors.grey[300] : null,
                    ),
                    filled: _selectedTypeId == null,
                    fillColor: _selectedTypeId == null ? Colors.grey[50] : null,
                    hintText: _selectedTypeId == null
                        ? 'Select Type first'
                        : 'Choose a category',
                    labelStyle: TextStyle(
                      color: _selectedTypeId == null ? Colors.grey[400] : null,
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Select a category' : null,
                ),
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton(
                  onPressed: _isSaving ? null : _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1C1E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'New Account',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
