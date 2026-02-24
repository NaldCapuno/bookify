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
  int? _selectedCategoryId;

  // Cache the stream to prevent database flicker during the "blink"
  late final Stream<List<AccountCategory>> _categoryStream;

  @override
  void initState() {
    super.initState();
    _categoryStream = appDb.select(appDb.accountCategories).watch(); //
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      await appDb
          .into(appDb.accounts)
          .insert(
            AccountsCompanion.insert(
              code: int.parse(_codeController.text),
              name: _nameController.text,
              categoryId: _selectedCategoryId!,
              isLocked: const drift.Value(false),
            ),
          );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detects the keyboard height
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: [
        Positioned(
          // This creates the "Blink" effect. Positioned updates instantly
          // without the resizing animation of a standard container.
          bottom: keyboardHeight,
          left: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Form only takes needed space
              children: [
                // Minimalist handle
                Container(
                  width: 35,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodyMedium!,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Add New Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        StreamBuilder<List<AccountCategory>>(
                          stream: _categoryStream, //
                          builder: (context, snapshot) {
                            final categories = snapshot.data ?? [];
                            return DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              value: _selectedCategoryId,
                              items: categories
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat.id,
                                      child: Text(cat.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedCategoryId = val),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            labelText: 'Code',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1C1E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Save Account'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
