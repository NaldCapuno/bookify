import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                // Header with Add Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chart of Accounts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Add Account',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // ASSETS Section
                _buildSectionHeader('ASSETS'),
                _buildAccountItem('101', 'Cash on Hand', 'Current Assets'),
                _buildAccountItem(
                  '102',
                  'Cash in Bank - Checking',
                  'Current Assets',
                ),
                _buildAccountItem(
                  '103',
                  'Cash in Bank - Savings',
                  'Current Assets',
                ),
                _buildAccountItem('104', 'Petty Cash Fund', 'Current Assets'),
                _buildAccountItem(
                  '110',
                  'Accounts Receivable - Trade',
                  'Current Assets',
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFFF8FAFC),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.blueGrey.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildAccountItem(String code, String name, String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              code,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Wrap this section in Expanded to take up only the available middle space
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Use Flexible so the name can shrink, and add ellipsis
                Flexible(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1C1E),
                    ),
                    overflow: TextOverflow.ellipsis, // Adds the "..."
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                // Ensure the Tag stays visible
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 9),
                  ),
                ),
              ],
            ),
          ),
          // // The buttons will now stay safely on the right
          // IconButton(
          //   icon: Icon(
          //     Icons.edit_outlined,
          //     size: 18,
          //     color: Colors.grey.shade400,
          //   ),
          //   onPressed: () {},
          //   visualDensity: VisualDensity.compact,
          //   padding: EdgeInsets.zero,
          //   constraints: const BoxConstraints(),
          // ),
          // const SizedBox(width: 8),
          // IconButton(
          //   icon: Icon(
          //     Icons.delete_outline,
          //     size: 18,
          //     color: Colors.grey.shade400,
          //   ),
          //   onPressed: () {},
          //   visualDensity: VisualDensity.compact,
          //   padding: EdgeInsets.zero,
          //   constraints: const BoxConstraints(),
          // ),
        ],
      ),
    );
  }
}
