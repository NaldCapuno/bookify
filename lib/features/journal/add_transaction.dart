import 'package:bookkeeping/core/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';

class JournalLine {
  int? accountId;
  double debit;
  double credit;

  JournalLine({this.accountId, this.debit = 0.0, this.credit = 0.0});
}

class AddJournalEntryForm extends StatefulWidget {
  const AddJournalEntryForm({super.key});

  @override
  State<AddJournalEntryForm> createState() => _AddJournalEntryFormState();
}

class _AddJournalEntryFormState extends State<AddJournalEntryForm> {
  double totalDebit = 0.0;
  double totalCredit = 0.0;
  List<JournalLine> lines = [JournalLine(), JournalLine()];

  final TextEditingController _refNoController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // NEW: Controller for the Date Field
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // NEW: State variables for accounts
  List<Account> _availableAccounts = [];
  bool _isLoadingAccounts = true;

  @override
  void initState() {
    super.initState();
    // Initialize the date field with today's date
    _dateController.text = DateFormat('MM/dd/yyyy').format(_selectedDate);
    // Fetch accounts from the database
    _loadAccounts();
  }

  // NEW: Fetch accounts from SQLite
  Future<void> _loadAccounts() async {
    try {
      final accounts = await appDb.journalEntryDao.getActiveAccounts();
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

  @override
  void dispose() {
    _refNoController.dispose();
    _descController.dispose();
    _dateController.dispose(); // Don't forget to dispose the new controller
    super.dispose();
  }

  void _calculateTotals() {
    setState(() {
      totalDebit = lines.fold(0, (sum, item) => sum + item.debit);
      totalCredit = lines.fold(0, (sum, item) => sum + item.credit);
    });
  }

  Future<void> _saveEntry() async {
    // 1. Validate the description is not empty (since your DB requires min 1 char)
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

    // 2. Filter out empty/incomplete lines (e.g., user added a line but didn't fill it)
    final validLines = lines
        .where(
          (line) =>
              line.accountId != null && (line.debit > 0 || line.credit > 0),
        )
        .toList();

    if (validLines.isEmpty) return;

    // 3. Map your UI 'JournalLine' into Drift's 'TransactionsCompanion'
    final companionLines = validLines.map((line) {
      // REMOVED .insert to avoid the required journalId error
      return TransactionsCompanion(
        // Everything must now be explicitly wrapped in drift.Value()
        accountId: drift.Value(line.accountId!),
        debit: drift.Value(line.debit),
        credit: drift.Value(line.credit),
      );
    }).toList();

    try {
      // 4. Call the DAO method using your global appDb instance
      await appDb.journalEntryDao.insertFullJournalEntry(
        date: _selectedDate,
        description: _descController.text.trim(),
        referenceNo: _refNoController.text.trim().isEmpty
            ? null
            : _refNoController.text.trim(),
        lines: companionLines,
      );

      // 5. Provide feedback and close the form
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journal entry saved safely!'),
            backgroundColor: Colors.green,
          ),
        );

        // Pass 'true' back to the parent screen so it knows to refresh the list
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
    bool isBalanced = (totalDebit - totalCredit).abs() < 0.01 && totalDebit > 0;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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

            // UPDATED: Date field now uses the picker
            _buildModernField(
              label: "Date",
              hint: "Select Date",
              icon: Icons.calendar_today,
              controller: _dateController,
              readOnly: true, // Prevents keyboard from popping up
              onTap: _pickDate, // Opens the calendar
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
                    onPressed: isBalanced ? _saveEntry : null,
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

  // UPDATED: Added readOnly and onTap parameters
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildRowHeader(),
          ...List.generate(lines.length, (index) => _buildRowInput(index)),
          _buildTableFooter(),
        ],
      ),
    );
  }

  Widget _buildRowHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "Account",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "Debit",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "Credit",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildRowInput(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              // UPDATED: Dynamic Accounts Dropdown
              child: _isLoadingAccounts
                  ? const SizedBox(
                      height: 48,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        hint: const Text(
                          "Select",
                          style: TextStyle(fontSize: 13),
                        ),
                        isExpanded: true,
                        value: lines[index].accountId,
                        // Map the database accounts to DropdownMenuItems
                        items: _availableAccounts.map((account) {
                          return DropdownMenuItem<int>(
                            value: account.id,
                            child: Text(
                              account.name,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow
                                  .ellipsis, // Prevents long names from breaking UI
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => lines[index].accountId = val),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _buildAmountInput(
              onChanged: (val) {
                lines[index].debit = double.tryParse(val) ?? 0;
                _calculateTotals();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _buildAmountInput(
              onChanged: (val) {
                lines[index].credit = double.tryParse(val) ?? 0;
                _calculateTotals();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[300], size: 20),
            onPressed: lines.length > 2
                ? () => setState(() {
                    lines.removeAt(index);
                    _calculateTotals();
                  })
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput({required Function(String) onChanged}) {
    return TextField(
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildTableFooter() {
    bool isBalanced = (totalDebit - totalCredit).abs() < 0.01 && totalDebit > 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        children: [
          TextButton.icon(
            onPressed: () => setState(() => lines.add(JournalLine())),
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Add Line"),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "₱ ${totalDebit.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isBalanced ? Colors.green : Colors.black87,
                ),
              ),
              const SizedBox(width: 40),
              Text(
                "₱ ${totalCredit.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isBalanced ? Colors.green : Colors.black87,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ],
      ),
    );
  }
}
