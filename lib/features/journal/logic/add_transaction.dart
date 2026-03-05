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

  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final FocusNode _descFocus = FocusNode();

  List<AccountWithCategory> _availableAccounts = [];
  bool _isLoadingAccounts = true;

  // Creates a new line and attaches the "Format on Leave" listeners
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

  // Parses the text, adds commas, and updates the UI
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

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('MM/dd/yyyy').format(_selectedDate);

    _loadAccounts();
    _descController.addListener(() {
      setState(() {});
    });

    lines = [
      _createNewRow(isDefaultDebit: true),
      _createNewRow(isDefaultDebit: false),
    ];
  }

  @override
  void dispose() {
    _descController.dispose();
    _dateController.dispose();
    _descFocus.dispose();
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

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        // Force a neutral/monochrome theme on the date picker
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black, // Selection color
              onPrimary: Colors.white, // Text inside selection
              surface: Colors.white, // Background
              onSurface: Colors.black, // Text color
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
    List<AccountWithCategory> filteredAccounts = List.from(_availableAccounts);
    final TextEditingController searchController = TextEditingController();

    final selectedAccountId = lines[lineIndex].accountId;
    final GlobalKey selectedItemKey = GlobalKey();

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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search Bar
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search accounts or categories...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: groupedData.entries.map((entry) {
                            final categoryName = entry.key;
                            final accounts = entry.value;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Header
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  color: Colors.grey[100],
                                  child: Text(
                                    categoryName.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),

                                // Accounts under this category
                                ...accounts.map((element) {
                                  final isDebit =
                                      element.category.normalBalance ==
                                      NormalBalance.debit;
                                  final isSelectedAccount =
                                      selectedAccountId == element.account.id;

                                  final badgeText = isDebit
                                      ? 'Debit Account'
                                      : 'Credit Account';
                                  final badgeColor = isDebit
                                      ? Colors.blue[700]!
                                      : Colors.orange[700]!;
                                  final badgeBg = isDebit
                                      ? Colors.blue[50]!
                                      : Colors.orange[50]!;

                                  return Container(
                                    key: isSelectedAccount
                                        ? selectedItemKey
                                        : null,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 2.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelectedAccount
                                          ? Colors.grey[100]
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        element.account.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isSelectedAccount
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: Colors.black,
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
                                          ),
                                        ),
                                        child: Text(
                                          badgeText,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: badgeColor,
                                            letterSpacing: 0.3,
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
      AppToast.show(
        context,
        message: 'Description is required.',
        isError: true,
      );
      _descFocus.requestFocus();
      return;
    }

    for (int i = 0; i < lines.length; i++) {
      bool hasAccount = lines[i].accountId != null;
      bool hasAmount = lines[i].amount > 0;

      if (hasAccount != hasAmount || (!hasAccount && !hasAmount && i < 2)) {
        AppToast.show(
          context,
          message: 'Please complete the missing account details.',
          isError: true,
        );
        lines[i].amountFocus.requestFocus();
        return;
      }
    }

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

    final selectedIds = validLines.map((l) => l.accountId).toList();
    if (selectedIds.length != selectedIds.toSet().length) {
      AppToast.show(
        context,
        message: 'Duplicate accounts detected. Each line must be unique.',
        isError: true,
      );
      return;
    }

    bool isBalanced = (totalDebit - totalCredit).abs() < 0.01 && totalDebit > 0;
    if (!isBalanced) {
      AppToast.show(
        context,
        message: 'Total Debit and Credit must balance perfectly.',
        isError: true,
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
        referenceNo: null, // Null to trigger auto-generation in the DAO
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
    return Container(
      padding: EdgeInsets.only(
        top: 40,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      decoration: const BoxDecoration(
        color: Colors.white, // Pure white background
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildModernField(
              label: "Date",
              hint: "Select Date",
              icon: Icons.calendar_today_outlined,
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),

            _buildModernField(
              label: "Description *",
              hint: "Transaction description",
              icon: Icons.edit_note_outlined,
              controller: _descController,
              focusNode: _descFocus,
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
                      foregroundColor:
                          Colors.grey[800], // Neutral gray/black text
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Solid Black
                      foregroundColor: Colors.white, // Solid White
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Save Entry",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
      style: const TextStyle(color: Colors.black, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: errorText != null ? Colors.red : Colors.grey[700],
        ),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, size: 22, color: Colors.grey[700]),
        errorText: errorText,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
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
            onPressed: () {
              setState(() => lines.add(_createNewRow()));
            },
            icon: Icon(
              Icons.add_circle_outline,
              size: 20,
              color: Colors.grey[800],
            ),
            label: Text(
              "Add Another Account",
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey[300]!, width: 1.5),
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
    final selectedAccountId = lines[index].accountId;
    final accountName = selectedAccountId != null
        ? _availableAccounts
              .firstWhere((a) => a.account.id == selectedAccountId)
              .account
              .name
        : "Select Account";

    bool showAccountError = _hasAttemptedSave && selectedAccountId == null;
    bool showAmountError = _hasAttemptedSave && lines[index].amount <= 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: showAccountError
                            ? Colors.red
                            : Colors.grey[300]!,
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
                              fontSize: 15,
                              color: showAccountError
                                  ? Colors.red
                                  : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_circle_outlined,
                          color: showAccountError
                              ? Colors.red
                              : Colors.grey[400],
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[400]),
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

          // --- BOTTOM ROW: Single Amount Field + Sliding Toggle ---
          Row(
            children: [
              // Amount Input
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
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: "Amount *",
                    labelStyle: TextStyle(
                      color: showAmountError ? Colors.red : Colors.grey[500],
                      fontSize: 13,
                    ),
                    prefixText: '₱ ',
                    prefixStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: showAmountError
                        ? Colors.red[50]
                        : Colors.grey[100], // Minimalist light gray box
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide
                          .none, // Removes underline/borders for the modern look
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

              // Premium Sliding Toggle
              Container(
                width: 150,
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Gray background
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
                            color: Colors.white, // White Pill
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
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
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
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
                                  fontSize: 14,
                                  fontWeight: lines[index].isDebit
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: lines[index].isDebit
                                      ? Colors.blue[600]
                                      : Colors.grey[600], // Blue for Debit
                                ),
                                child: const Text("Debit"),
                              ),
                            ),
                          ),
                        ),
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
                                  fontSize: 14,
                                  fontWeight: !lines[index].isDebit
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: !lines[index].isDebit
                                      ? Colors.orange[700]
                                      : Colors.grey[600], // Orange for Credit
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

  Widget _buildTableFooter() {
    final colorScheme = Theme.of(context).colorScheme;
    bool isBalanced = (totalDebit - totalCredit).abs() < 0.01 && totalDebit > 0;
    double difference = (totalDebit - totalCredit).abs();
    bool hasAmounts = totalDebit > 0 || totalCredit > 0;

    final selectedAccounts = lines
        .where((l) => l.accountId != null)
        .map((l) => l.accountId)
        .toList();
    bool hasDuplicates =
        selectedAccounts.length != selectedAccounts.toSet().length;

    Color boxColor = (!hasAmounts && !hasDuplicates)
        ? Colors.grey[50]! // Very light gray default
        : (hasDuplicates || !isBalanced ? Colors.red[50]! : Colors.green[50]!);

    Color borderColor = (!hasAmounts && !hasDuplicates)
        ? Colors.grey[200]!
        : (hasDuplicates || !isBalanced
              ? Colors.red[200]!
              : Colors.green[200]!);

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
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "₱ ${NumberFormat('#,##0.00').format(totalDebit)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
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
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "₱ ${NumberFormat('#,##0.00').format(totalCredit)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          if (hasAmounts || hasDuplicates) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Colors.black12),
            ),
            if (hasDuplicates)
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.red[700],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Duplicate accounts detected",
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBalanced ? "Balanced" : "Out of Balance",
                    style: TextStyle(
                      color: isBalanced ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isBalanced)
                    Text(
                      "Difference: ₱ ${NumberFormat('#,##0.00').format(difference)}",
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
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
