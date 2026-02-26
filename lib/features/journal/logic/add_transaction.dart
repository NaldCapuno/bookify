import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/journal_entry_daos.dart';
import 'package:bookkeeping/core/database/tables/account_categories_table.dart';
import 'package:bookkeeping/core/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';

class JournalLine {
  int? accountId;
  bool isDebit; // TRUE = Debit, FALSE = Credit
  double amount; // Only ONE amount value now!

  final TextEditingController amountController;
  final FocusNode amountFocus;

  // These getters automatically format the data for your SQLite Database!
  double get debit => isDebit ? amount : 0.0;
  double get credit => !isDebit ? amount : 0.0;

  JournalLine({
    this.accountId,
    this.isDebit = true, // Defaults to Debit
    this.amount = 0.0,
  }) : amountController = TextEditingController(),
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

  // Creates a new line and attaches the "Format on Leave" listeners
  JournalLine _createNewRow({bool isDefaultDebit = true}) {
    final line = JournalLine(isDebit: isDefaultDebit);

    // Only one focus node to listen to now!
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

    // SMART DEFAULTS: Row 1 is Debit, Row 2 is Credit.
    // This perfectly satisfies your client's mental model automatically!
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
                            // Trim whitespace and lowercase the query once
                            final trimmedQuery = query.trim().toLowerCase();

                            filteredAccounts = _availableAccounts.where((a) {
                              final matchAccount = a.account.name
                                  .toLowerCase()
                                  .contains(trimmedQuery);
                              final matchCategory = a.category.name
                                  .toLowerCase()
                                  .contains(trimmedQuery);
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

                          // 4. Design the actual account list item
                          // 4. Design the actual account list item
                          itemBuilder: (context, element) {
                            final isDebit =
                                element.category.normalBalance ==
                                NormalBalance.debit;

                            // Plain English Labels
                            final badgeText = isDebit
                                ? 'Debit Account'
                                : 'Credit Account';

                            // BRINGING BACK THE LIVELY COLORS
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
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ), // Keeps the modern pill shape
                                ),
                                child: Text(
                                  badgeText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight
                                        .bold, // Bold to match the vibrant color
                                    color: badgeColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  lines[lineIndex].accountId =
                                      element.account.id;
                                  // Auto-Toggle to match the account type
                                  lines[lineIndex].isDebit = isDebit;
                                  _calculateTotals();
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
    setState(() => _hasAttemptedSave = true);

    // 1. Check Description (Auto-scrolls to the top if empty)
    if (_descController.text.trim().isEmpty) {
      AppToast.show(
        context,
        message: 'Description is required.',
        isError: true,
      );
      _descFocus.requestFocus(); // MAGIC: Auto-scrolls to the description box!
      return;
    }

    // 2. Check for partially filled or completely empty required lines
    for (int i = 0; i < lines.length; i++) {
      bool hasAccount = lines[i].accountId != null;
      bool hasAmount = lines[i].amount > 0;

      // If a line is missing either an account or an amount (or if we don't have 2 lines filled yet)
      if (hasAccount != hasAmount || (!hasAccount && !hasAmount && i < 2)) {
        AppToast.show(
          context,
          message: 'Please complete the missing account details.',
          isError: true,
        );
        lines[i].amountFocus
            .requestFocus(); // MAGIC: Auto-scrolls to the specific offending row!
        return;
      }
    }

    // 3. Filter the complete, valid lines
    final validLines = lines
        .where((line) => line.accountId != null && line.amount > 0)
        .toList();

    if (validLines.length < 2) {
      AppToast.show(
        context,
        message: 'A journal entry must contain at least two accounts.',
        isError: true,
      );
      return;
    }

    // 4. Duplicate Check
    final selectedIds = validLines.map((l) => l.accountId).toList();
    if (selectedIds.length != selectedIds.toSet().length) {
      AppToast.show(
        context,
        message: 'Duplicate accounts detected. Each line must be unique.',
        isError: true,
      );
      return;
    }

    // 5. Balance Check
    bool isBalanced = (totalDebit - totalCredit).abs() < 0.01 && totalDebit > 0;
    if (!isBalanced) {
      AppToast.show(
        context,
        message: 'Total Debit and Credit must balance perfectly.',
        isError: true,
      );
      return;
    }

    // 6. Save to Database
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
        AppToast.show(
          context,
          message: 'Journal entry saved successfully!',
          icon: Icons.check_circle_outline,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Database Error: $e");
      if (mounted) {
        AppToast.show(
          context,
          message: 'Failed to save journal entry. Please try again.',
          isError: true,
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
              label: "Description *",
              hint: "Transaction description",
              icon: Icons.edit_note,
              controller: _descController,
              focusNode: _descFocus, // NEW: Link the focus node!
              errorText:
                  (_hasAttemptedSave && _descController.text.trim().isEmpty)
                  ? 'Description is required'
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
                    // ALWAYS ENABLED NOW. The function handles the rejection.
                    onPressed: _saveEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
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
        errorText: errorText, // NEW: Shows the error if provided
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
        ? _availableAccounts
              .firstWhere((a) => a.account.id == selectedAccountId)
              .account
              .name
        : "Select Account";

    // 1. Check for errors in this specific row
    bool showAccountError = _hasAttemptedSave && selectedAccountId == null;
    bool showAmountError = _hasAttemptedSave && lines[index].amount <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TOP ROW: Account Selector ---
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showAccountSearchSheet(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      // Turn box Red if account is missing
                      color: showAccountError
                          ? Colors.red.shade50
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: showAccountError
                            ? Colors.red.shade300
                            : Colors.grey.shade200,
                        width: showAccountError ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            showAccountError
                                ? "Account Required *"
                                : accountName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  selectedAccountId != null || showAccountError
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              // Turn text Red if account is missing
                              color: showAccountError
                                  ? Colors.red.shade700
                                  : (selectedAccountId != null
                                        ? Colors.black87
                                        : Colors.grey.shade600),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_circle_outlined,
                          color: showAccountError
                              ? Colors.red.shade300
                              : Colors.blueGrey.shade300,
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
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- BOTTOM ROW: Single Amount Field + Premium Sliding Toggle ---
          Row(
            children: [
              // 1. The Single Amount Input
              Expanded(
                child: TextFormField(
                  controller: lines[index].amountController,
                  focusNode: lines[index].amountFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: "Amount *",
                    labelStyle: TextStyle(
                      // Turn label Red if amount is missing
                      color: showAmountError
                          ? Colors.red.shade700
                          : Colors.grey.shade500,
                      fontSize: 13,
                    ),
                    prefixText: '₱ ',
                    prefixStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: showAmountError
                        ? Colors.red.shade50
                        : Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    // Turn underline Red if amount is missing
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: showAmountError
                            ? Colors.red.shade400
                            : Colors.grey.shade200,
                        width: showAmountError ? 1.5 : 1.0,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black87, width: 2),
                    ),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    String cleanVal = val.replaceAll(',', '');
                    lines[index].amount = double.tryParse(cleanVal) ?? 0;
                    _calculateTotals();
                  },
                ),
              ),
              const SizedBox(width: 12),

              // 2. The Premium Sliding Toggle (AnimatedAlign + Stack)
              Container(
                width: 140, // Fixed width so it always looks consistent
                height: 48, // Matches the text field height perfectly
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24), // Fully rounded pill
                ),
                child: Stack(
                  children: [
                    // THE SLIDING BACKGROUND PILL
                    AnimatedAlign(
                      alignment: lines[index].isDebit
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      duration: const Duration(milliseconds: 250),
                      curve:
                          Curves.easeOutCubic, // Buttery smooth iOS-style curve
                      child: FractionallySizedBox(
                        widthFactor: 0.5, // Always takes exactly half the width
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // THE TEXT AND TAP ZONES
                    Row(
                      children: [
                        // Debit Tap Zone
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior
                                .opaque, // Ensures the whole half is tappable
                            onTap: () {
                              setState(() {
                                lines[index].isDebit = true;
                                _calculateTotals();
                              });
                            },
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: lines[index].isDebit
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: lines[index].isDebit
                                      ? Colors.blue.shade700
                                      : Colors.grey.shade500,
                                ),
                                child: const Text("Debit"),
                              ),
                            ),
                          ),
                        ),
                        // Credit Tap Zone
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                lines[index].isDebit = false;
                                _calculateTotals();
                              });
                            },
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: !lines[index].isDebit
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: !lines[index].isDebit
                                      ? Colors.orange.shade700
                                      : Colors.grey.shade500,
                                ),
                                child: const Text("Credit"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // // Helper for the minimalist toggle switch
  // Widget _buildToggleOption({
  //   required String title,
  //   required bool isSelected,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 200),
  //       curve: Curves.easeOutCubic,
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       decoration: BoxDecoration(
  //         color: isSelected ? Colors.white : Colors.transparent,
  //         borderRadius: BorderRadius.circular(8),
  //         boxShadow: isSelected
  //             ? [
  //                 BoxShadow(
  //                   color: Colors.black.withValues(alpha:0.05),
  //                   blurRadius: 4,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ]
  //             : [],
  //       ),
  //       child: Text(
  //         title,
  //         style: TextStyle(
  //           fontSize: 13,
  //           fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
  //           color: isSelected ? Colors.black87 : Colors.grey.shade500,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildAmountInput({
  //   required String label,
  //   required TextEditingController controller,
  //   required FocusNode focusNode,
  //   required Function(String) onChanged,
  // }) {
  //   return TextFormField(
  //     controller: controller, // Linked here
  //     focusNode: focusNode, // Linked here
  //     keyboardType: const TextInputType.numberWithOptions(decimal: true),
  //     textAlign: TextAlign.right,
  //     style: const TextStyle(
  //       fontSize: 16,
  //       fontWeight: FontWeight.w600,
  //       color: Colors.black87,
  //     ),
  //     decoration: InputDecoration(
  //       labelText: label,
  //       labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
  //       hintText: '0.00',
  //       hintStyle: TextStyle(color: Colors.grey.shade400),
  //       prefixText: '₱ ',
  //       prefixStyle: const TextStyle(
  //         color: Colors.black87,
  //         fontSize: 16,
  //         fontWeight: FontWeight.w600,
  //       ),
  //       filled: true,
  //       fillColor: Colors.grey.shade50,
  //       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //       border: UnderlineInputBorder(
  //         borderSide: BorderSide(color: Colors.grey.shade300),
  //       ),
  //       enabledBorder: UnderlineInputBorder(
  //         borderSide: BorderSide(color: Colors.grey.shade300),
  //       ),
  //       focusedBorder: const UnderlineInputBorder(
  //         borderSide: BorderSide(color: Colors.blueGrey, width: 2),
  //       ),
  //       isDense: true,
  //     ),
  //     onChanged: onChanged,
  //   );
  // }

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
