import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Format amount for display (e.g. "5,000.00").
String formatAmount(double value) {
  if (value.isNaN || value.isInfinite) return '0.00';
  return _amountFormatter.format(value);
}

double parseAmount(TextEditingController c) {
  return double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0.0;
}

void formatAmountController(TextEditingController c) {
  final raw = c.text.replaceAll(',', '').trim();
  if (raw.isEmpty) return;
  final parsed = double.tryParse(raw);
  if (parsed == null || parsed <= 0) {
    c.text = '';
    return;
  }
  c.text = _amountFormatter.format(parsed);
  c.selection = TextSelection.collapsed(offset: c.text.length);
}

final NumberFormat _amountFormatter = NumberFormat('#,##0.00');

/// Before/After balance header shown above the amount card.
/// Designed to stick to the top of the screen right under the AppBar.
class BeforeAfterBalanceHeader extends StatelessWidget {
  const BeforeAfterBalanceHeader({
    super.key,
    required this.label,
    required this.before,
    required this.after,
    this.beforeTitle = 'CURRENT',
    this.afterTitle = 'AFTER',
  });

  final String label;
  final double before;
  final double after;
  final String beforeTitle;
  final String afterTitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      // Padding adjusted for a full-width flush look
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        // Match the AppBar's surface color
        color: scheme.surface,
        // Only apply a bottom border to separate it from the scrolling content below
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BeforeAfterColumn(
              title: beforeTitle,
              label: label,
              value: before,
            ),
          ),
          Expanded(
            child: _BeforeAfterColumn(
              title: afterTitle,
              label: label,
              value: after,
              alignEnd: true,
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
    this.alignEnd = false,
  });

  final String title;
  final String label;
  final double value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontSize: 9,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontSize: 10,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 3),
        DefaultTextStyle(
          style:
              textTheme.titleMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ) ??
              TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              '₱ ${formatAmount(value)}',
              maxLines: 1,
              textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            ),
          ),
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
    this.errorText,

    /// Optional footer shown inside the card with lower hierarchy (e.g. "remaining" or total).
    this.footer,
  });

  final TextEditingController amountController;
  final String amountLabel;
  final Stream<double>? balanceStream;
  final String? balanceLabel;
  final bool checkInsufficient;
  final String currencyPrefix;
  final VoidCallback? onAmountChanged;
  final String? errorText;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasError = errorText != null && errorText!.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            amountLabel.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: hasError ? scheme.error : scheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            decoration: InputDecoration(
              filled: true,
              fillColor: scheme.surfaceContainerHighest,
              prefixText: currencyPrefix,
              hintText: '0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: hasError ? scheme.error : scheme.outlineVariant,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: hasError ? scheme.error : scheme.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: hasError ? scheme.error : scheme.outlineVariant,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: hasError ? scheme.error : scheme.outlineVariant,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: scheme.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: scheme.error),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
            ),
            onChanged: (_) => onAmountChanged?.call(),
            onEditingComplete: () {
              formatAmountController(amountController);
              onAmountChanged?.call();
              FocusScope.of(context).unfocus();
            },
          ),
          if (hasError) ...[
            const SizedBox(height: 6),
            Text(
              errorText!,
              style: TextStyle(
                fontSize: 12,
                color: scheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: 8),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              child: footer!,
            ),
          ],
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
    if (!isOutflow || amount <= 0 || amount <= currentBalance)
      return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: scheme.error),
          const SizedBox(width: 8),
          Text(
            'Insufficient balance in selected account.',
            style: TextStyle(
              color: scheme.error,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal chips for Cash / Bank / Unpaid (or Pay Later). Each has a distinct accent color.
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

  static const Color _cashColor = Color(0xFF2E7D32); // Green
  static const Color _bankColor = Color(0xFF1976D2); // Blue
  static const Color _creditColor = Color(
    0xFFE65100,
  ); // Orange/amber for Pay Later

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Chip(
              label: cashLabel,
              icon: Icons.money,
              isSelected: value == 'cash',
              onTap: () => onChanged('cash'),
              balance: cashBalance,
              accentColor: _cashColor,
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
              accentColor: _bankColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Chip(
              label: creditLabel,
              icon: creditIcon,
              isSelected: value == 'credit',
              onTap: () => onChanged('credit'),
              accentColor: _creditColor,
            ),
          ),
        ],
      ),
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
    this.accentColor,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double? balance;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = accentColor ?? scheme.primary;
    return Material(
      color: isSelected ? color.withValues(alpha: 0.15) : scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.4),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? color : color.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : scheme.onSurface,
                ),
              ),
              if (balance != null) ...[
                const SizedBox(height: 6),
                Text(
                  '₱ ${formatAmount(balance!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
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

  static const Color _cashColor = Color(0xFF2E7D32); // Green
  static const Color _bankColor = Color(0xFF1976D2); // Blue

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
            accentColor: _cashColor,
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
            accentColor: _bankColor,
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: scheme.onSurfaceVariant,
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
    this.descriptionErrorText,
    this.onDescriptionChanged,
  });

  final TextEditingController descriptionController;
  final String dateText;
  final VoidCallback onDateTap;
  final String descriptionLabel;
  final String? descriptionHint;
  final String? descriptionErrorText;
  final VoidCallback? onDescriptionChanged;

  @override
  Widget build(BuildContext context) {
    final hasDescError =
        descriptionErrorText != null && descriptionErrorText!.trim().isNotEmpty;

    InputDecoration fieldDecoration({
      required String label,
      required String hint,
      required IconData icon,
      bool isError = false,
    }) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        errorText: isError ? descriptionErrorText : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      );
    }

    return Column(
      children: [
        TextFormField(
          controller: TextEditingController(text: dateText),
          readOnly: true,
          onTap: onDateTap,
          decoration: fieldDecoration(
            label: 'Date',
            hint: 'Select Date',
            icon: Icons.calendar_today_outlined,
            isError: false,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: descriptionController,
          maxLines: 2,
          decoration: fieldDecoration(
            label: descriptionLabel,
            hint: descriptionHint ?? 'Add a short note...',
            icon: Icons.description_outlined,
            isError: hasDescError,
          ),
          onChanged: (_) => onDescriptionChanged?.call(),
        ),
      ],
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isSaving ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isSaving ? 'Saving...' : label,
            style:
                textTheme.labelLarge?.copyWith(fontSize: 16) ??
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
