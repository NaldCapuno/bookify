import 'package:flutter/material.dart';

// Define an enum for the filter state to keep code clean
enum BalanceFilter { all, dr, cr }

class AccountSearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String searchQuery;
  final FocusNode? focusNode;

  // NEW: Filter parameters
  final BalanceFilter selectedFilter;
  final ValueChanged<BalanceFilter> onFilterChanged;

  const AccountSearchHeader({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          // Search Bar takes up available space
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: theme.textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.cancel,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: onClear,
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildFilterToggle(context),
        ],
      ),
    );
  }

  Widget _buildFilterToggle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildFilterButton(context, 'ALL', BalanceFilter.all),
          _buildFilterButton(context, 'DR', BalanceFilter.dr),
          _buildFilterButton(context, 'CR', BalanceFilter.cr),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, String label, BalanceFilter filter) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall!.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
