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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.05)),
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
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.black54,
                  size: 20,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: onClear,
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF2F4F7),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // NEW: DR/CR Filter Toggle
          _buildFilterToggle(),
        ],
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildFilterButton('ALL', BalanceFilter.all),
          _buildFilterButton('DR', BalanceFilter.dr),
          _buildFilterButton('CR', BalanceFilter.cr),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, BalanceFilter filter) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blueGrey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
