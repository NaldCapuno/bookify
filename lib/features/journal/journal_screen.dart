import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/journal_entry_daos.dart';
import 'package:bookkeeping/features/journal/add_transaction.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  void _openAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddJournalEntryForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. The New Entry Button fixed at the top
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildNewEntryButton(context),
        ),

        // 2. The Dynamic List of Entries
        Expanded(
          // 1. Change the type to List<JournalSummary>
          child: StreamBuilder<List<JournalSummary>>(
            // 2. Listen to our new powerful joined query
            stream: appDb.journalEntryDao.watchJournalSummaries(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final summaryList = snapshot.data ?? [];

              if (summaryList.isEmpty) {
                return const Center(
                  child: Text(
                    'No journal entries yet. Tap above to create one!',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: summaryList.length,
                itemBuilder: (context, index) {
                  // 'summary' now holds the Journal AND the computed totals
                  final summary = summaryList[index];

                  final dateString = DateFormat(
                    'MMM dd, yyyy',
                  ).format(summary.journal.date);

                  // Format the amount with commas (e.g., 80000.0 becomes "80,000.00")
                  final formattedAmount = NumberFormat(
                    '#,##0.00',
                  ).format(summary.totalAmount);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: JournalEntryCard(
                      id: summary.journal.id.toString(),
                      date: dateString,
                      title: summary.journal.description,

                      // 3. Inject the live calculated data directly into your card!
                      accounts: summary.accountCount,
                      amount: formattedAmount,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewEntryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () => _openAddTransaction(context),
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          'New Journal Entry',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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

  const JournalEntryCard({
    super.key,
    required this.id,
    required this.date,
    required this.title,
    required this.accounts,
    required this.amount,
    this.isInitiallyExpanded = false,
  });

  @override
  State<JournalEntryCard> createState() => _JournalEntryCardState();
}

class _JournalEntryCardState extends State<JournalEntryCard> {
  late bool _isExpanded;
  bool _isVoided = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  // Changed to return a Future<bool> so Dismissible knows what the user chose
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
                      // Return false if canceled
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
                      // Return true if confirmed
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

    return result ??
        false; // If user taps outside the bottom sheet, return false
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          // We wrap the Material inside a Dismissible for the slide effect
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Dismissible(
              key: ValueKey('journal_entry_${widget.id}'),
              direction: _isVoided
                  ? DismissDirection
                        .none // Disable swiping if already voided
                  : DismissDirection.endToStart, // Swipe right to left
              // What shows behind the card when swiping
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

              // The logic when the swipe completes
              confirmDismiss: (direction) async {
                // Show bottom sheet
                bool shouldVoid = await _showVoidConfirmation(context);
                if (shouldVoid) {
                  setState(() => _isVoided = true);
                }
                // ALWAYS return false so the card snaps back into the list.
                // We don't want to actually delete the widget, just change it to voided!
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
                  // Removed onLongPress!
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
                                // Smooth animated rotation for the arrow!
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
                                          _buildAccountDetail(
                                            name: 'Cash',
                                            amount: widget.amount,
                                            isDebit: true,
                                          ),
                                          const SizedBox(height: 12),
                                          _buildAccountDetail(
                                            name: "Owner's Capital",
                                            amount: widget.amount,
                                            isDebit: false,
                                          ),

                                          // Optional: You can also show a subtle Void button here
                                          // so users have two ways to void (Swipe AND Tap)
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
