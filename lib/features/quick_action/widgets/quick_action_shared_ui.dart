import 'package:flutter/material.dart';

/// Format amount for display (e.g. "5,000.00").
String formatAmount(double value) {
  if (value == value.truncateToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
}

double parseAmount(TextEditingController c) {
  return double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0.0;
}

/// Before/After balance header shown above the amount card.
class BeforeAfterBalanceHeader extends StatelessWidget {
  const BeforeAfterBalanceHeader({
    super.key,
    required this.label,
    required this.before,
    required this.after,
  });

  final String label;
  final double before;
  final double after;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BeforeAfterColumn(
              title: 'BEFORE',
              label: label,
              value: before,
            ),
          ),
          Container(
            width: 1,
            height: 44,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _BeforeAfterColumn(
              title: 'AFTER',
              label: label,
              value: after,
            ),
          ),
        ],
      ),
    );
  }
}

class _BeforeAfterColumn extends StatelessWidget {
  const _BeforeAfterColumn({
    required this.title,
    required this.label,
    required this.value,
  });

  final String title;
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 2),
        Text(
          '₱ ${formatAmount(value)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}

/// Amount card in Record Sale style: optional balance line, TOTAL AMOUNT label, large input.
/// NOTE: Balance display moved to chips + before/after header per new UX.
class QuickActionAmountCard extends StatelessWidget {
  const QuickActionAmountCard({
    super.key,
    required this.amountController,
    required this.amountLabel,
    // Back-compat (no longer shown in this widget)
    this.balanceStream,
    this.balanceLabel,
    this.checkInsufficient = false,
    this.currencyPrefix = '₱ ',
    this.onAmountChanged,
  });

  final TextEditingController amountController;
  final String amountLabel;
  final Stream<double>? balanceStream;
  final String? balanceLabel;
  final bool checkInsufficient;
  final String currencyPrefix;
  final VoidCallback? onAmountChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            amountLabel.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: currencyPrefix,
              hintText: '0.00',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (_) => onAmountChanged?.call(),
          ),
        ],
      ),
    );
  }
}

/// Shows "Insufficient balance" when [amount] > [balance]. Call from parent with parsed amount and stream balance.
class InsufficientBalanceNotice extends StatelessWidget {
  const InsufficientBalanceNotice({
    super.key,
    required this.amount,
    required this.currentBalance,
    this.isOutflow = true,
  });

  final double amount;
  final double currentBalance;
  final bool isOutflow;

  @override
  Widget build(BuildContext context) {
    if (!isOutflow || amount <= 0 || amount <= currentBalance) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Text(
            'Insufficient balance in selected account.',
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal chips for Cash / Bank / Unpaid (or Pay Later). Green when selected.
class PaymentMethodChips extends StatelessWidget {
  const PaymentMethodChips({
    super.key,
    required this.value,
    required this.onChanged,
    this.cashLabel = 'Cash',
    this.bankLabel = 'Bank',
    this.creditLabel = 'Unpaid',
    this.creditIcon = Icons.timer_outlined,
    this.cashBalance,
    this.bankBalance,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String cashLabel;
  final String bankLabel;
  final String creditLabel;
  final IconData creditIcon;
  final double? cashBalance;
  final double? bankBalance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Chip(
            label: cashLabel,
            icon: Icons.money,
            isSelected: value == 'cash',
            onTap: () => onChanged('cash'),
            balance: cashBalance,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            label: bankLabel,
            icon: Icons.account_balance,
            isSelected: value == 'bank',
            onTap: () => onChanged('bank'),
            balance: bankBalance,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            label: creditLabel,
            icon: creditIcon,
            isSelected: value == 'credit',
            onTap: () => onChanged('credit'),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.balance,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double? balance;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFF2E7D32).withValues(alpha: 0.12) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade600,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade700,
                ),
              ),
              if (balance != null) ...[
                const SizedBox(height: 6),
                Text(
                  '₱ ${formatAmount(balance!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Two-option chips (e.g. Cash / Bank only).
class CashBankChips extends StatelessWidget {
  const CashBankChips({
    super.key,
    required this.value,
    required this.onChanged,
    this.cashBalance,
    this.bankBalance,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final double? cashBalance;
  final double? bankBalance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Chip(
            label: 'Cash',
            icon: Icons.money,
            isSelected: value == 'cash',
            onTap: () => onChanged('cash'),
            balance: cashBalance,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            label: 'Bank',
            icon: Icons.account_balance,
            isSelected: value == 'bank',
            onTap: () => onChanged('bank'),
            balance: bankBalance,
          ),
        ),
      ],
    );
  }
}

/// Section label in uppercase grey (e.g. "PAYMENT METHOD").
class QuickActionSectionLabel extends StatelessWidget {
  const QuickActionSectionLabel(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Details card: Description and Date with underline style.
class QuickActionDetailsCard extends StatelessWidget {
  const QuickActionDetailsCard({
    super.key,
    required this.descriptionController,
    required this.dateText,
    required this.onDateTap,
    this.descriptionLabel = 'Description',
    this.descriptionHint,
  });

  final TextEditingController descriptionController;
  final String dateText;
  final VoidCallback onDateTap;
  final String descriptionLabel;
  final String? descriptionHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: descriptionLabel,
              hintText: descriptionHint,
              prefixIcon: const Icon(Icons.description_outlined, color: Colors.black87),
              border: const UnderlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            maxLines: 2,
          ),
          const Divider(height: 24),
          InkWell(
            onTap: onDateTap,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Icons.calendar_today_outlined, color: Colors.black87),
                border: UnderlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                dateText,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Green full-width save button.
class QuickActionSaveButton extends StatelessWidget {
  const QuickActionSaveButton({
    super.key,
    required this.onPressed,
    required this.isSaving,
    this.label = 'Save Entry',
  });

  final VoidCallback? onPressed;
  final bool isSaving;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isSaving ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isSaving ? 'Saving...' : label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// Returns the account code for balance display when user selects cash/bank/credit.
/// For outflow: cash=101, bank=102. For inflow same. Credit returns null (no single balance).
int? accountCodeForPaymentMethod(String method) {
  switch (method) {
    case 'cash':
      return 101;
    case 'bank':
      return 102;
    default:
      return null;
  }
}
