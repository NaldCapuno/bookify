import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/journal_entry_daos.dart';
import 'package:bookkeeping/core/database/tables/account_categories_table.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';

class JournalLine {
  int? accountId;
  double debit;
  double credit;

  // Controllers and FocusNodes for dynamic formatting
  final TextEditingController debitController;
  final TextEditingController creditController;
  final FocusNode debitFocus;
  final FocusNode creditFocus;

  JournalLine({this.accountId, this.debit = 0.0, this.credit = 0.0})
    : debitController = TextEditingController(),
      creditController = TextEditingController(),
      debitFocus = FocusNode(),
      creditFocus = FocusNode();

  // Prevents memory leaks when a row is deleted
  void dispose() {
    debitController.dispose();
    creditController.dispose();
    debitFocus.dispose();
    creditFocus.dispose();
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

  final TextEditingController _refNoController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // NEW: Controller for the Date Field
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  List<AccountWithCategory> _availableAccounts = [];
  bool _isLoadingAccounts = true;

  // Creates a new line and attaches the "Format on Leave" listeners
  JournalLine _createNewRow() {
    final line = JournalLine();

    // Listen to the Debit box
    line.debitFocus.addListener(() {
      if (!line.debitFocus.hasFocus) {
        _formatAmount(line.debitController, (val) {
          line.debit = val;
          _calculateTotals();
        });
      }
    });

    // Listen to the Credit box
    line.creditFocus.addListener(() {
      if (!line.creditFocus.hasFocus) {
        _formatAmount(line.creditController, (val) {
          line.credit = val;
          _calculateTotals();
        });
      }
    });

    return line;
  }

  // Parses the text, adds commas, and updates the UI
  void _formatAmount(
    TextEditingController controller,
    Function(double) updateValue,
  ) {
    if (controller.text.isEmpty) return;

    // 1. Strip out any existing commas so Dart can parse it as a double
    String cleanText = controller.text.replaceAll(',', '');
    double? parsedValue = double.tryParse(cleanText);

    if (parsedValue != null && parsedValue > 0) {
      // 2. Format with commas and exactly 2 decimal places
      controller.text = NumberFormat('#,##0.00').format(parsedValue);
      updateValue(parsedValue);
    } else {
      // Clear the box if they typed garbage
      controller.text = '';
      updateValue(0.0);
    }
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('MM/dd/yyyy').format(_selectedDate);
    _loadAccounts();
    _descController.addListener(() {
      setState(() {});
    });

    // Initialize the first two rows using our new method
    lines = [_createNewRow(), _createNewRow()];
  }

  @override
  void dispose() {
    _refNoController.dispose();
    _descController.dispose();
    _dateController.dispose();
    // Dispose of all line controllers
    for (var line in lines) {
      line.dispose();
    }
    super.dispose();
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
      debugPrint("Error loading accounts: $e");
      if (mounted) setState(() => _isLoadingAccounts = false);
    }
  }

  // NEW: Modern Date Picker Logic
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), // How far back they can scroll
      lastDate: DateTime(2100), // How far forward they can scroll
      builder: (context, child) {
        // Optional: Customize the calendar colors here if you want it to match your dark slate theme
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueGrey, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
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
    // Hold our filtered combined list
    List<AccountWithCategory> filteredAccounts = List.from(_availableAccounts);
    final TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 16,
                right: 16,
              ),
              child: DraggableScrollableSheet(
                initialChildSize: 0.6,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) {
                  return Column(
                    children: [
                      const Text(
                        "Select Account",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search Bar
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Search accounts or categories...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                        onChanged: (query) {
                          setSheetState(() {
                            // Filter by BOTH account name and category name
                            filteredAccounts = _availableAccounts.where((a) {
                              final matchAccount = a.account.name
                                  .toLowerCase()
                                  .contains(query.toLowerCase());
                              final matchCategory = a.category.name
                                  .toLowerCase()
                                  .contains(query.toLowerCase());
                              return matchAccount || matchCategory;
                            }).toList();
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // THE STICKY GROUPED LIST
                      Expanded(
                        child: GroupedListView<AccountWithCategory, String>(
                          controller: scrollController,
                          elements: filteredAccounts,
                          // 1. Tell it what to group by (the category name)
                          groupBy: (element) => element.category.name,

                          // 2. Turn on the sticky headers!
                          useStickyGroupSeparators: true,

                          // 3. Design the sticky header
                          groupSeparatorBuilder: (String categoryName) =>
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                color: Colors
                                    .grey
                                    .shade100, // Light background to separate it
                                child: Text(
                                  categoryName.toUpperCase(), // e.g., "ASSETS"
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey.shade700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),

                          // 4. Design the actual account list item with DR/CR Badge
                          itemBuilder: (context, element) {
                            // Determine if the normal balance is debit or credit
                            final isDebit =
                                element.category.normalBalance ==
                                NormalBalance.debit;

                            // Set up colors and text based on the balance type
                            final badgeText = isDebit ? 'DR' : 'CR';
                            final badgeColor = isDebit
                                ? Colors.blue.shade700
                                : Colors.orange.shade700;
                            final badgeBg = isDebit
                                ? Colors.blue.shade50
                                : Colors.orange.shade50;

                            return ListTile(
                              title: Text(
                                element.account.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // THE NEW NORMAL BALANCE BADGE
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: badgeColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  badgeText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: badgeColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  lines[lineIndex].accountId =
                                      element.account.id;
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveEntry() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a description.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    final validLines = lines
        .where(
          (line) =>
              line.accountId != null && (line.debit > 0 || line.credit > 0),
        )
        .toList();

    if (validLines.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A journal entry must contain at least two accounts.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (validLines.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A journal entry must contain at least two accounts.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedIds = validLines.map((l) => l.accountId).toList();
    if (selectedIds.length != selectedIds.toSet().length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An account cannot be used more than once.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final companionLines = validLines.map((line) {
      return TransactionsCompanion(
        accountId: drift.Value(line.accountId!),
        debit: drift.Value(line.debit),
        credit: drift.Value(line.credit),
      );
    }).toList();

    try {
      await appDb.journalEntryDao.insertFullJournalEntry(
        date: _selectedDate,
        description: _descController.text.trim(),
        referenceNo: _refNoController.text.trim().isEmpty
            ? null
            : _refNoController.text.trim(),
        lines: companionLines,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journal entry saved safely!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Database Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int validLinesCount = lines
        .where((l) => l.accountId != null && (l.debit > 0 || l.credit > 0))
        .length;

    final selectedAccounts = lines
        .where((l) => l.accountId != null)
        .map((l) => l.accountId)
        .toList();
    bool hasDuplicates =
        selectedAccounts.length != selectedAccounts.toSet().length;

    bool isBalanced = (totalDebit - totalCredit).abs() < 0.01 && totalDebit > 0;
    bool hasDescription = _descController.text.trim().isNotEmpty;

    bool canSave =
        isBalanced && hasDescription && validLinesCount >= 2 && !hasDuplicates;

    return Container(
      padding: EdgeInsets.only(
        top: 40,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                "New Journal Entry",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
              label: "Description",
              hint: "Transaction description",
              icon: Icons.edit_note,
              controller: _descController,
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
                    // Use 'canSave' instead of 'isBalanced'
                    onPressed: canSave ? _saveEntry : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
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
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
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
        // 1. The individual account cards
        ...List.generate(lines.length, (index) => _buildRowInput(index)),

        const SizedBox(height: 8),

        // 2. The new standalone "Add Another Account" Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              // Assuming you are using the _createNewRow() method we made earlier!
              setState(() => lines.add(_createNewRow()));
            },
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text(
              "Add Another Account",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white, // Makes it pop like a button
              foregroundColor: Colors.blueGrey.shade700,
              side: BorderSide(color: Colors.blueGrey.shade200, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 3. The cleaned-up totals footer
        _buildTableFooter(),
      ],
    );
  }

  Widget _buildRowInput(int index) {
    final selectedAccountId = lines[index].accountId;
    final accountName = selectedAccountId != null
        // Notice we added .account.id and .account.name here!
        ? _availableAccounts
              .firstWhere((a) => a.account.id == selectedAccountId)
              .account
              .name
        : "Select Account";

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Account Selector and Delete Button
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showAccountSearchSheet(
                    index,
                  ), // Opens our new search sheet
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            accountName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: selectedAccountId != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: selectedAccountId != null
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                            ),
                            overflow: TextOverflow
                                .ellipsis, // Fades out if extremely long
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_circle_outlined,
                          color: Colors.blueGrey.shade300,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                onPressed: lines.length > 2
                    ? () => setState(() {
                        lines.removeAt(index);
                        _calculateTotals();
                      })
                    : null, // Disable delete if only 2 lines remain
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bottom Row: Debit and Credit side-by-side (now much wider!)
          Row(
            children: [
              Expanded(
                child: _buildAmountInput(
                  label: "Debit",
                  controller: lines[index].debitController,
                  focusNode: lines[index].debitFocus,
                  onChanged: (val) {
                    String cleanVal = val.replaceAll(',', '');
                    double parsed = double.tryParse(cleanVal) ?? 0;
                    lines[index].debit = parsed;

                    // RULE 1: Mutual Exclusivity. If Debit has a value, clear Credit.
                    if (parsed > 0) {
                      lines[index].credit = 0;
                      lines[index].creditController.clear();
                    }
                    _calculateTotals();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountInput(
                  label: "Credit",
                  controller: lines[index].creditController,
                  focusNode: lines[index].creditFocus,
                  onChanged: (val) {
                    String cleanVal = val.replaceAll(',', '');
                    double parsed = double.tryParse(cleanVal) ?? 0;
                    lines[index].credit = parsed;

                    // RULE 1: Mutual Exclusivity. If Credit has a value, clear Debit.
                    if (parsed > 0) {
                      lines[index].debit = 0;
                      lines[index].debitController.clear();
                    }
                    _calculateTotals();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller, // Linked here
      focusNode: focusNode, // Linked here
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        hintText: '0.00',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixText: '₱ ',
        prefixStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey, width: 2),
        ),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildTableFooter() {
    bool isBalanced = (totalDebit - totalCredit).abs() < 0.01 && totalDebit > 0;
    double difference = (totalDebit - totalCredit).abs();
    bool hasAmounts = totalDebit > 0 || totalCredit > 0;

    // Check for duplicates here as well for the UI warning
    final selectedAccounts = lines
        .where((l) => l.accountId != null)
        .map((l) => l.accountId)
        .toList();
    bool hasDuplicates =
        selectedAccounts.length != selectedAccounts.toSet().length;

    // Determine box color (Red if out of balance OR if duplicates are found)
    Color boxColor = !hasAmounts && !hasDuplicates
        ? Colors.grey.shade50
        : (hasDuplicates || !isBalanced
              ? Colors.red.shade50
              : Colors.green.shade50);

    Color borderColor = !hasAmounts && !hasDuplicates
        ? Colors.grey.shade200
        : (hasDuplicates || !isBalanced
              ? Colors.red.shade200
              : Colors.green.shade200);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Debit",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "₱ ${NumberFormat('#,##0.00').format(totalDebit)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Credit",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "₱ ${NumberFormat('#,##0.00').format(totalCredit)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          // Show the Status, Difference, or Duplicate Warning
          if (hasAmounts || hasDuplicates) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),

            // If duplicates exist, prioritize showing the Duplicate Error
            if (hasDuplicates)
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Duplicate accounts detected",
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            // Otherwise, show the normal balance status
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBalanced ? "Balanced" : "Out of Balance",
                    style: TextStyle(
                      color: isBalanced
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isBalanced)
                    Text(
                      "Difference: ₱ ${NumberFormat('#,##0.00').format(difference)}",
                      style: TextStyle(
                        color: Colors.red.shade700,
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
}
