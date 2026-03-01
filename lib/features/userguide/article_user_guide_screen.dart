import 'package:flutter/material.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';

/// Article-style user guide: intro, getting started, main sections, glossary, tips, troubleshooting.
class ArticleUserGuideScreen extends StatelessWidget {
  const ArticleUserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Article User Guide',
        showBackButton: true,
        onBackTap: () => Navigator.maybePop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _Section(
            colorScheme: colorScheme,
            icon: Icons.info_outline,
            title: 'Welcome to Bookify',
            body:
                'This app helps you keep a simple record of your business money: what came in, what went out, '
                'and what you own or owe. You don\'t need to know bookkeeping—this guide explains everything in plain language.',
            indentFirstLine: true,
          ),
          _Section(
            colorScheme: colorScheme,
            icon: Icons.home_outlined,
            title: 'Getting started',
            body:
                'After you sign in, you\'ll see the Dashboard. Use the bottom tabs to move between: '
                'Dashboard (overview), Journal (where you record transactions), Ledger (account balances), '
                'Reports (income, balance sheet, cash flow), and Accounts (manage your account list). '
                'Tap your profile picture at the top right to open Profile or Settings.',
            indentFirstLine: true,
          ),
          _Section(
            colorScheme: colorScheme,
            icon: Icons.book_outlined,
            title: 'The Journal',
            body:
                'The Journal is where you record every money event—sales, purchases, expenses, loans, and so on. '
                'Each entry has a date, a description, and at least two lines. On each line you pick an account '
                'and enter either a Debit or a Credit amount. The rule: total Debits must equal total Credits. '
                'Think of it as "money (or value) came from here (Credit) and went there (Debit)." '
                'Tap the + button to add a new entry. You can edit or void entries from the list.',
            indentFirstLine: true,
          ),
          _Section(
            colorScheme: colorScheme,
            icon: Icons.description_outlined,
            title: 'The Ledger',
            body:
                'The Ledger shows each account and its balance. It only lists accounts that have at least one transaction. '
                'So if you create an account but never use it in a journal entry, it won\'t show up until you do. '
                'Balances are calculated from all your non-voided entries. This view helps you see where your money is '
                'and what you owe at a glance.',
            indentFirstLine: true,
          ),
          _Section(
            colorScheme: colorScheme,
            icon: Icons.account_tree_outlined,
            title: 'Accounts',
            body:
                'Accounts are the categories you use in the Journal—e.g. Cash, Sales, Rent, Inventory, Loans. '
                'You can add new accounts from the Accounts tab. Once an account is used in a saved entry, '
                'it becomes "locked" so it can\'t be deleted (to keep your history correct). You can still archive it '
                'to hide it from the main list. Only accounts that have never been used can be deleted.',
            indentFirstLine: true,
          ),
          _Section(
            colorScheme: colorScheme,
            icon: Icons.analytics_outlined,
            title: 'Reports',
            body:
                'Reports summarize your data over a date range you choose. The Income Statement shows profit or loss, '
                'the Balance Sheet shows what you own and owe, and the Cash Flow shows how cash moved. '
                'Only non-voided entries are included, and only within the selected dates. If something\'s missing, '
                'check the date range and make sure the entry wasn\'t voided.',
            indentFirstLine: true,
          ),
          _Section(
            colorScheme: colorScheme,
            icon: Icons.menu_book_outlined,
            title: 'Key terms',
            body:
                '• Debit / Credit: In each entry, money or value is taken from one side (Credit) and given to another (Debit). '
                'Total Debits must equal total Credits.\n\n'
                '• Void: Cancel an entry so it no longer affects Ledger or Reports, but it stays in the Journal as a record.\n\n'
                '• Ledger: A list of accounts and their balances based on your journal entries.\n\n'
                '• Account: A category for recording money (e.g. Cash, Sales, Expenses).\n\n'
                '• Locked account: An account that has been used in at least one entry; it can be archived but not deleted.',
            indentFirstLine: false,
          ),
          _Section(
            colorScheme: colorScheme,
            icon: Icons.lightbulb_outline,
            title: 'Tips',
            body:
                '• Enter transactions soon after they happen so you don\'t forget.\n\n'
                '• Use clear descriptions (e.g. "Office rent for January") so you can find entries later.\n\n'
                '• Before saving, check that Debits = Credits; the app will not save until they match.\n\n'
                '• Don\'t use the same account twice in one entry—use different accounts for each line.\n\n'
                '• Your data stays on your device unless you use a backup or sync feature.',
            indentFirstLine: false,
          ),
          _Section(
            colorScheme: colorScheme,
            icon: Icons.report_problem_outlined,
            title: 'Troubleshooting',
            body:
                '• Entry won\'t save: Make sure total Debits equal total Credits, you have a description, '
                'at least two lines, no duplicate accounts in the same entry, and each line has either a debit or credit (not both).\n\n'
                '• Account missing in Ledger: Add a journal entry that uses that account; the Ledger only shows accounts with transactions.\n\n'
                '• Report looks wrong: Confirm the date range and that the relevant entries are not voided.\n\n'
                '• Can\'t delete an account: If it\'s been used in any entry, archive it instead of deleting.',
            indentFirstLine: false,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.colorScheme,
    required this.icon,
    required this.title,
    required this.body,
    this.indentFirstLine = true,
  });

  final ColorScheme colorScheme;
  final IconData icon;
  final String title;
  final String body;
  final bool indentFirstLine;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = TextStyle(
      fontSize: 15,
      height: 1.5,
      color: colorScheme.onSurface,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          indentFirstLine
              ? Text.rich(
                  TextSpan(
                    style: bodyStyle,
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: SizedBox(
                          width: 24,
                          height: 18,
                        ),
                      ),
                      TextSpan(text: body),
                    ],
                  ),
                )
              : Text(
                  body,
                  style: bodyStyle,
                ),
        ],
      ),
    );
  }
}
