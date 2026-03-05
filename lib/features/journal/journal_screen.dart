import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/journal_entry_daos.dart';
import 'package:bookkeeping/core/widgets/app_fab.dart';
import 'package:bookkeeping/features/journal/logic/add_transaction.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:bookkeeping/core/services/walkthrough_service.dart';

class JournalScreen extends StatefulWidget {
  final int selectedIndex;
  final int myIndex;

  const JournalScreen({
    super.key,
    required this.selectedIndex,
    required this.myIndex,
  });

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final GlobalKey _filterKey = GlobalKey();
  final GlobalKey _emptyStateKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();

  bool _hasShownTour = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeStartJournalTour();
    });
  }

  @override
  void didUpdateWidget(covariant JournalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == widget.myIndex && !_hasShownTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeStartJournalTour();
      });
    }
  }

  void _maybeStartJournalTour() {
    if (!mounted || _hasShownTour || widget.selectedIndex != widget.myIndex) {
      return;
    }
    _hasShownTour = true;
    WalkthroughService.showJournalTour(
      context,
      filterKey: _filterKey,
      emptyKey: _emptyStateKey,
      fabKey: _fabKey,
    );
  }

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }

                final rawList = snapshot.data ?? [];
                final filteredList = _filterSummaries(rawList);

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text(
                      key: _emptyStateKey,
                      _selectedFilter == 'All'
                          ? 'No journal entries yet.'
                          : 'No entries for this $_selectedFilter period.',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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
                        // ✅ Pass the reference number to the card
                        referenceNo: summary.journal.referenceNo ?? '',
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
        key: _fabKey,
        label: 'New Entry',
        icon: Icons.add,
        onPressed: () => _openAddTransaction(context),
      ),
    );
  }

  Widget _buildFilterChips() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SingleChildScrollView(
      key: _filterKey,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 20.0,
        bottom: 20.0,
      ),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = filter == _selectedFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = filter);
                }
              },
              selectedColor: colorScheme.primary,
              backgroundColor: colorScheme.surface,
              labelStyle: theme.textTheme.bodyMedium!.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                ),
              ),
              showCheckmark: false,
              elevation: 0,
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
  final String referenceNo; // ✅ ADDED Reference Number
  final String date;
  final String title;
  final int accounts;
  final String amount;
  final bool isInitiallyVoided;
  final List<TransactionWithAccount> details;

  const JournalEntryCard({
    super.key,
    required this.id,
    required this.referenceNo, // ✅ ADDED Reference Number
    required this.date,
    required this.title,
    required this.accounts,
    required this.amount,
    required this.details,
    this.isInitiallyVoided = false,
  });

  @override
  State<JournalEntryCard> createState() => _JournalEntryCardState();
}

class _JournalEntryCardState extends State<JournalEntryCard> {
  late bool _isVoided;

  @override
  void initState() {
    super.initState();
    _isVoided = widget.isInitiallyVoided;
  }

  Future<bool> _showVoidConfirmation(BuildContext context) async {
    if (_isVoided) return false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
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
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Icon(Icons.error_outline, color: colorScheme.error, size: 50),
              const SizedBox(height: 16),
              Text('Void Transaction?', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'This entry will be marked as voided. You will still be able to view the details, but it cannot be un-voided.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        'Cancel',
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Void Entry'),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // SORTING LOGIC: Separate debits and credits, then combine them (Debits top, Credits bottom)
    final debits = widget.details
        .where((d) => d.transactionLine.debit > 0)
        .toList();
    final credits = widget.details
        .where((d) => d.transactionLine.credit > 0)
        .toList();
    final sortedDetails = [...debits, ...credits];

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
                color: colorScheme.error.withValues(alpha: 0.2),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block, color: colorScheme.error, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      'VOID',
                      style: theme.textTheme.labelMedium!.copyWith(
                        color: colorScheme.error,
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
                  await appDb.journalEntryDao.markJournalAsVoided(
                    int.parse(widget.id),
                  );
                  setState(() => _isVoided = true);
                }
                return false;
              },
              child: Material(
                color: _isVoided
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _isVoided
                        ? colorScheme.outlineVariant
                        : colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Opacity(
                    opacity: _isVoided ? 0.6 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- HEADER: Date, Reference No, and Description ---
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

                            // ✅ DISPLAY REFERENCE NUMBER HERE
                            if (widget.referenceNo.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  '#${widget.referenceNo}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.title,
                          style: theme.textTheme.titleSmall!.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            decoration: _isVoided
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // --- TABLE HEADERS ---
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                "ACCOUNT",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: Text(
                                  "DEBIT",
                                  textAlign: TextAlign.right,
                                  style: theme.textTheme.bodySmall!.copyWith(
                                    fontSize: 10,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: Text(
                                  "CREDIT",
                                  textAlign: TextAlign.right,
                                  style: theme.textTheme.bodySmall!.copyWith(
                                    fontSize: 10,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // --- BODY: The Accounts List ---
                        ...sortedDetails.map((detail) {
                          bool isDebit = detail.transactionLine.debit > 0;
                          double amount = isDebit
                              ? detail.transactionLine.debit
                              : detail.transactionLine.credit;
                          final formattedAmount = NumberFormat(
                            '#,##0.00',
                          ).format(amount);

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              top: 6.0,
                              bottom: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                              border: Border(
                                left: BorderSide(
                                  color: colorScheme.primary,
                                  width: 3.5,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      detail.account.name,
                                      style: theme.textTheme.bodyMedium!
                                          .copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: colorScheme.onSurface,
                                            decoration: _isVoided
                                                ? TextDecoration.lineThrough
                                                : null,
                                            height: 1.3,
                                          ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        isDebit ? formattedAmount : '',
                                        textAlign: TextAlign.right,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        !isDebit ? formattedAmount : '',
                                        textAlign: TextAlign.right,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
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
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'VOIDED',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
