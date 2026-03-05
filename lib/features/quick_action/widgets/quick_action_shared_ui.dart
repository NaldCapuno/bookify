import 'package:flutter/material.dart';

/// Format amount for display (e.g. "5,000.00").
String formatAmount(double value) {
  if (value == value.truncateToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
}

/// Amount card in Record Sale style: optional balance line, TOTAL AMOUNT label, large input.
/// [balanceStream] and [balanceLabel] when set show current balance above the amount.
/// [checkInsufficient] when true shows red "Insufficient balance" when amount > balance.
class QuickActionAmountCard extends StatelessWidget {
  const QuickActionAmountCard({
    super.key,
    required this.amountController,
    required this.amountLabel,
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
          if (balanceStream != null && balanceLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
                child: StreamBuilder<double>(
                stream: balanceStream,
                builder: (context, snap) {
                  final balance = snap.data ?? 0.0;
                  return Text(
                    '$balanceLabel ₱ ${formatAmount(balance)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
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
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String cashLabel;
  final String bankLabel;
  final String creditLabel;
  final IconData creditIcon;

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
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            label: bankLabel,
            icon: Icons.account_balance,
            isSelected: value == 'bank',
            onTap: () => onChanged('bank'),
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
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

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
  });

  final String value;
  final ValueChanged<String> onChanged;

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
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Chip(
            label: 'Bank',
            icon: Icons.account_balance,
            isSelected: value == 'bank',
            onTap: () => onChanged('bank'),
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
    this.descriptionHint,
  });

  final TextEditingController descriptionController;
  final String dateText;
  final VoidCallback onDateTap;
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
              labelText: 'Description',
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
