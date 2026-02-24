import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/journal_entry_daos.dart';
import 'package:bookkeeping/core/widgets/app_fab.dart';
import 'package:bookkeeping/features/journal/logic/add_transaction.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  // 2. State variable to track the selected filter
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Weekly',
    'Monthly',
    'Quarterly',
    'Yearly',
  ];
  void _openAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddJournalEntryForm(),
    );
  }

  List<JournalSummary> _filterSummaries(List<JournalSummary> summaries) {
    if (_selectedFilter == 'All') return summaries;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return summaries.where((summary) {
      final date = summary.journal.date;
      final summaryDate = DateTime(date.year, date.month, date.day);

      if (_selectedFilter == 'Yearly') {
        return summaryDate.year == today.year;
      } else if (_selectedFilter == 'Quarterly') {
        final currentQuarter = (today.month - 1) ~/ 3 + 1;
        final summaryQuarter = (summaryDate.month - 1) ~/ 3 + 1;
        return summaryDate.year == today.year &&
            summaryQuarter == currentQuarter;
      } else if (_selectedFilter == 'Monthly') {
        return summaryDate.year == today.year &&
            summaryDate.month == today.month;
      } else if (_selectedFilter == 'Weekly') {
        final diff = today.difference(summaryDate).inDays;
        return diff >= 0 && diff <= 7;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterChips(),

          Expanded(
            child: StreamBuilder<List<JournalSummary>>(
              stream: appDb.journalEntryDao.watchJournalSummaries(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final rawList = snapshot.data ?? [];
                final filteredList = _filterSummaries(rawList);

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text(
                      _selectedFilter == 'All'
                          ? 'No journal entries yet.'
                          : 'No entries for this $_selectedFilter period.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 15.0,
                    bottom: 80.0,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final summary = filteredList[index];

                    final dateString = DateFormat(
                      'MMM dd, yyyy',
                    ).format(summary.journal.date);
                    final formattedAmount = NumberFormat(
                      '#,##0.00',
                    ).format(summary.totalAmount);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: JournalEntryCard(
                        key: ValueKey(summary.journal.id),
                        id: summary.journal.id.toString(),
                        date: dateString,
                        title: summary.journal.description,
                        accounts: summary.accountCount,
                        amount: formattedAmount,
                        isInitiallyVoided: summary.journal.isVoid,
                        details: summary.details,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AppFloatingActionButton(
        label: 'New Entry',
        icon: Icons.add,
        onPressed: () => _openAddTransaction(context),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // 1. Better overall padding for the entire row of chips
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = filter == _selectedFilter;

          return Padding(
            // 2. Slightly wider gap between each individual chip
            padding: const EdgeInsets.only(right: 10.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = filter);
                }
              },
              selectedColor: const Color(0xFF1A1C1E),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF1A1C1E)
                      : Colors.grey.shade300,
                ),
              ),
              showCheckmark: false,
              elevation: 0,
              // 3. Internal padding makes the chips taller and more "pill-shaped"
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class JournalEntryCard extends StatefulWidget {
  final String id;
  final String date;
  final String title;
  final int accounts;
  final String amount;
  final bool isInitiallyExpanded;
  final bool isInitiallyVoided;
  final List<TransactionWithAccount> details; // Receives nested DB details

  const JournalEntryCard({
    super.key,
    required this.id,
    required this.date,
    required this.title,
    required this.accounts,
    required this.amount,
    required this.details, // Required now
    this.isInitiallyExpanded = false,
    this.isInitiallyVoided = false,
  });

  @override
  State<JournalEntryCard> createState() => _JournalEntryCardState();
}

class _JournalEntryCardState extends State<JournalEntryCard> {
  late bool _isExpanded;
  late bool _isVoided;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
    _isVoided = widget.isInitiallyVoided; // Initialize with real DB state
  }

  Future<bool> _showVoidConfirmation(BuildContext context) async {
    if (_isVoided) return false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 16),
              const Text(
                'Void Transaction?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This entry will be marked as voided. You will still be able to view the details, but it cannot be un-voided.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Void Entry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Dismissible(
              key: ValueKey('journal_entry_${widget.id}'),
              direction: _isVoided
                  ? DismissDirection.none
                  : DismissDirection.endToStart,
              background: Container(
                color: Colors.red.shade50,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block, color: Colors.red.shade400, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      'VOID',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                bool shouldVoid = await _showVoidConfirmation(context);
                if (shouldVoid) {
                  // UPDATE DATABASE ON SWIPE
                  await appDb.journalEntryDao.markJournalAsVoided(
                    int.parse(widget.id),
                  );
                  setState(() => _isVoided = true);
                }
                return false;
              },
              child: Material(
                color: _isVoided ? Colors.grey.shade50 : Colors.white,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _isVoided
                        ? Colors.grey.shade300
                        : Colors.grey.shade200,
                  ),
                ),
                child: InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  splashColor: Colors.black.withValues(alpha: 0.05),
                  highlightColor: Colors.black.withValues(alpha: 0.05),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.date,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                AnimatedRotation(
                                  turns: _isExpanded ? 0.5 : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _isVoided
                                    ? Colors.grey
                                    : const Color(0xFF1A1C1E),
                                decoration: _isVoided
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Accounts: ',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${widget.accounts}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '|',
                                  style: TextStyle(color: Colors.grey.shade300),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Amount: ',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '₱${widget.amount}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: _isVoided
                                        ? Colors.grey
                                        : Colors.black,
                                    decoration: _isVoided
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: _isExpanded
                            ? Column(
                                children: [
                                  const Divider(height: 1),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Opacity(
                                      opacity: _isVoided ? 0.6 : 1.0,
                                      child: Column(
                                        children: [
                                          // NO MORE FUTURE BUILDER! We just map the details list directly.
                                          Column(
                                            children: widget.details.map((
                                              line,
                                            ) {
                                              bool isDebit =
                                                  line.transactionLine.debit >
                                                  0;
                                              double amountValue = isDebit
                                                  ? line.transactionLine.debit
                                                  : line.transactionLine.credit;
                                              final formattedAmount =
                                                  NumberFormat(
                                                    '#,##0.00',
                                                  ).format(amountValue);

                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 12.0,
                                                ),
                                                child: _buildAccountDetail(
                                                  name: line.account.name,
                                                  amount: formattedAmount,
                                                  isDebit: isDebit,
                                                ),
                                              );
                                            }).toList(),
                                          ),

                                          if (!_isVoided) ...[
                                            const SizedBox(height: 16),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton.icon(
                                                onPressed: () async {
                                                  bool shouldVoid =
                                                      await _showVoidConfirmation(
                                                        context,
                                                      );
                                                  if (shouldVoid) {
                                                    // UPDATE DATABASE ON BUTTON TAP
                                                    await appDb.journalEntryDao
                                                        .markJournalAsVoided(
                                                          int.parse(widget.id),
                                                        );
                                                    setState(
                                                      () => _isVoided = true,
                                                    );
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.block,
                                                  size: 16,
                                                  color: Colors.red,
                                                ),
                                                label: const Text(
                                                  'Void Entry',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isVoided) _buildVoidStamp(),
      ],
    );
  }

  Widget _buildVoidStamp() {
    return Positioned(
      right: 40,
      top: 30,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: -0.15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.4),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'VOIDED',
              style: TextStyle(
                color: Colors.red.withValues(alpha: 0.4),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDetail({
    required String name,
    required String amount,
    required bool isDebit,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAmountBox(
                  'Debit',
                  isDebit ? '₱$amount' : '—',
                  isDebit ? const Color(0xFFE8F5E9) : Colors.transparent,
                  isDebit ? const Color(0xFF2E7D32) : Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAmountBox(
                  'Credit',
                  !isDebit ? '₱$amount' : '—',
                  !isDebit ? const Color(0xFFE3F2FD) : Colors.transparent,
                  !isDebit ? const Color(0xFF1565C0) : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountBox(
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
