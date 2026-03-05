import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/journal_entry_daos.dart';
import 'package:bookkeeping/core/database/tables/account_categories_table.dart';
import 'package:bookkeeping/core/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';

class JournalLine {
  int? accountId;
  bool isDebit; // TRUE = Debit, FALSE = Credit
  double amount;

  final TextEditingController amountController;
  final FocusNode amountFocus;

  double get debit => isDebit ? amount : 0.0;
  double get credit => !isDebit ? amount : 0.0;

  JournalLine({this.accountId, this.isDebit = true, this.amount = 0.0})
    : amountController = TextEditingController(),
      amountFocus = FocusNode();

  void dispose() {
    amountController.dispose();
    amountFocus.dispose();
  }
}

class AddJournalEntryForm extends StatefulWidget {
  const AddJournalEntryForm({super.key});

  @override
  State<AddJournalEntryForm> createState() => _AddJournalEntryFormState();
}

class _AddJournalEntryFormState extends State<AddJournalEntryForm> {
  double totalDebit = 0.0;
  double totalCredit = 0.0;
  List<JournalLine> lines = [];
  bool _hasAttemptedSave = false;

  final TextEditingController _refNoController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final FocusNode _descFocus = FocusNode();

  List<AccountWithCategory> _availableAccounts = [];
  bool _isLoadingAccounts = true;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('MM/dd/yyyy').format(_selectedDate);
    _loadAccounts();
    _descController.addListener(() => setState(() {}));

    // Default starting rows: One Debit, One Credit
    lines = [
      _createNewRow(isDefaultDebit: true),
      _createNewRow(isDefaultDebit: false),
    ];
  }

  @override
  void dispose() {
    _refNoController.dispose();
    _descController.dispose();
    _dateController.dispose();
    for (var line in lines) {
      line.dispose();
    }
    super.dispose();
  }

  JournalLine _createNewRow({bool isDefaultDebit = true}) {
    final line = JournalLine(isDebit: isDefaultDebit);
    line.amountFocus.addListener(() {
      if (!line.amountFocus.hasFocus) {
        _formatAmount(line.amountController, (val) {
          line.amount = val;
          _calculateTotals();
        });
      }
    });
    return line;
  }

  void _formatAmount(
    TextEditingController controller,
    Function(double) updateValue,
  ) {
    if (controller.text.isEmpty) return;
    String cleanText = controller.text.replaceAll(',', '');
    double? parsedValue = double.tryParse(cleanText);

    if (parsedValue != null && parsedValue > 0) {
      controller.text = NumberFormat('#,##0.00').format(parsedValue);
      updateValue(parsedValue);
    } else {
      controller.text = '';
      updateValue(0.0);
    }
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await appDb.journalEntryDao.getAccountsWithCategories();
      if (mounted) {
        setState(() {
          _availableAccounts = accounts;
          _isLoadingAccounts = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingAccounts = false);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  void _calculateTotals() {
    setState(() {
      totalDebit = lines.fold(0, (sum, item) => sum + item.debit);
      totalCredit = lines.fold(0, (sum, item) => sum + item.credit);
    });
  }

  void _showAccountSearchSheet(int lineIndex) {
    List<AccountWithCategory> filteredAccounts = List.from(_availableAccounts);
    final TextEditingController searchController = TextEditingController();
    final selectedAccountId = lines[lineIndex].accountId;
    final GlobalKey selectedItemKey = GlobalKey();
    final colorScheme = Theme.of(context).colorScheme;

    Map<String, List<AccountWithCategory>> groupAccounts(
      List<AccountWithCategory> accounts,
    ) {
      final Map<String, List<AccountWithCategory>> grouped = {};
      for (var a in accounts) {
        grouped.putIfAbsent(a.category.name, () => []).add(a);
      }
      return grouped;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (selectedItemKey.currentContext != null) {
                Scrollable.ensureVisible(
                  selectedItemKey.currentContext!,
                  duration: Duration.zero,
                  alignment: 0.3,
                );
              }
            });

            final groupedData = groupAccounts(filteredAccounts);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 16,
                right: 16,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: Column(
                  children: [
                    Text(
                      "Select Account",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search accounts or categories...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (query) {
                        setSheetState(() {
                          final trimmedQuery = query.trim().toLowerCase();
                          filteredAccounts = _availableAccounts.where((a) {
                            return a.account.name.toLowerCase().contains(
                                  trimmedQuery,
                                ) ||
                                a.category.name.toLowerCase().contains(
                                  trimmedQuery,
                                );
                          }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: groupedData.entries.map((entry) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Text(
                                    entry.key.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurfaceVariant,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                ...entry.value.map((element) {
                                  final isSelected =
                                      selectedAccountId == element.account.id;
                                  final isDebit =
                                      element.category.normalBalance ==
                                      NormalBalance.debit;
                                  return Container(
                                    key: isSelected ? selectedItemKey : null,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? colorScheme.surfaceContainerHighest
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        element.account.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDebit
                                              ? colorScheme.primaryContainer
                                              : colorScheme.tertiaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          isDebit ? 'Debit' : 'Credit',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isDebit
                                                ? colorScheme.primary
                                                : colorScheme.tertiary,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          lines[lineIndex].accountId =
                                              element.account.id;
                                          lines[lineIndex].isDebit = isDebit;
                                          _calculateTotals();
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                }),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveEntry() async {
    setState(() => _hasAttemptedSave = true);

    if (_descController.text.trim().isEmpty) {
      _descFocus.requestFocus();
      return;
    }

    final validLines = lines
        .where((l) => l.accountId != null && l.amount > 0)
        .toList();
    bool isBalanced = (totalDebit - totalCredit).abs() < 0.01 && totalDebit > 0;

    if (validLines.length < 2 || !isBalanced) {
      AppToast.show(
        context,
        message: 'Please ensure entry is balanced and unique.',
        isError: true,
      );
      return;
    }

    try {
      final companionLines = validLines
          .map(
            (line) => TransactionsCompanion(
              accountId: drift.Value(line.accountId!),
              debit: drift.Value(line.debit),
              credit: drift.Value(line.credit),
            ),
          )
          .toList();

      await appDb.journalEntryDao.insertFullJournalEntry(
        date: _selectedDate,
        description: _descController.text.trim(),
        referenceNo: _refNoController.text.trim().isEmpty
            ? null
            : _refNoController.text.trim(),
        lines: companionLines,
      );

      if (mounted) {
        AppToast.show(
          context,
          message: 'Saved successfully!',
          icon: Icons.check_circle_outline,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        AppToast.show(context, message: 'Error saving entry.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        top: 40,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                "New Journal Entry",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildModernField(
              label: "Date",
              hint: "Select Date",
              icon: Icons.calendar_today,
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            _buildModernField(
              label: "Reference No.",
              hint: "Optional",
              icon: Icons.tag,
              controller: _refNoController,
            ),
            const SizedBox(height: 16),
            _buildModernField(
              label: "Description *",
              hint: "Transaction description",
              icon: Icons.edit_note,
              controller: _descController,
              focusNode: _descFocus,
              errorText:
                  (_hasAttemptedSave && _descController.text.trim().isEmpty)
                  ? 'Required'
                  : null,
            ),
            const SizedBox(height: 24),
            _buildEntryTable(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Save Entry"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool readOnly = false,
    VoidCallback? onTap,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        errorText: errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildEntryTable() {
    return Column(
      children: [
        ...List.generate(lines.length, (index) => _buildRowInput(index)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => lines.add(_createNewRow())),
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text(
              "Add Another Account",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTableFooter(),
      ],
    );
  }

  Widget _buildRowInput(int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedAccountId = lines[index].accountId;
    final accountName = selectedAccountId != null
        ? _availableAccounts
              .firstWhere((a) => a.account.id == selectedAccountId)
              .account
              .name
        : "Select Account";

    bool showAccountError = _hasAttemptedSave && selectedAccountId == null;
    bool showAmountError = _hasAttemptedSave && lines[index].amount <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _showAccountSearchSheet(index),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: showAccountError
                    ? colorScheme.errorContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: showAccountError
                      ? colorScheme.error
                      : colorScheme.outlineVariant,
                  width: showAccountError ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      showAccountError ? "Account Required *" : accountName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: showAccountError
                            ? colorScheme.error
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_circle_outlined,
                    color: showAccountError
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: lines[index].amountController,
                  focusNode: lines[index].amountFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: "Amount *",
                    labelStyle: TextStyle(
                      color: showAmountError
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    prefixText: '₱ ',
                    filled: true,
                    fillColor: showAmountError
                        ? colorScheme.errorContainer
                        : colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: showAmountError
                            ? colorScheme.error
                            : colorScheme.outlineVariant,
                        width: showAmountError ? 1.5 : 1.0,
                      ),
                    ),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    lines[index].amount =
                        double.tryParse(val.replaceAll(',', '')) ?? 0;
                    _calculateTotals();
                  },
                ),
              ),
              const SizedBox(width: 12),
              _buildSlidingToggle(index),
              if (lines.length > 2)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: () => setState(() {
                    lines.removeAt(index);
                    _calculateTotals();
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlidingToggle(int index) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 140,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: lines[index].isDebit
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onSurface.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _toggleZone(index, "Debit", true),
              _toggleZone(index, "Credit", false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toggleZone(int index, String label, bool isDebit) {
    final colorScheme = Theme.of(context).colorScheme;
    final active = lines[index].isDebit == isDebit;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() {
          lines[index].isDebit = isDebit;
          _calculateTotals();
        }),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              color: active
                  ? (isDebit ? colorScheme.primary : colorScheme.tertiary)
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableFooter() {
    final colorScheme = Theme.of(context).colorScheme;
    bool isBalanced = (totalDebit - totalCredit).abs() < 0.01 && totalDebit > 0;
    double diff = (totalDebit - totalCredit).abs();
    bool hasAmounts = totalDebit > 0 || totalCredit > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: !hasAmounts
            ? colorScheme.surfaceContainerHighest
            : (isBalanced
                  ? colorScheme.primaryContainer
                  : colorScheme.errorContainer),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: !hasAmounts
              ? colorScheme.outlineVariant
              : (isBalanced ? colorScheme.primary : colorScheme.error),
        ),
      ),
      child: Column(
        children: [
          _footerRow("Total Debit", totalDebit),
          const SizedBox(height: 8),
          _footerRow("Total Credit", totalCredit),
          if (hasAmounts) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBalanced ? "Balanced" : "Out of Balance",
                  style: TextStyle(
                    color: isBalanced ? colorScheme.primary : colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isBalanced)
                  Text(
                    "Diff: ₱ ${NumberFormat('#,##0.00').format(diff)}",
                    style: TextStyle(
                      color: colorScheme.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _footerRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "₱ ${NumberFormat('#,##0.00').format(amount)}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
