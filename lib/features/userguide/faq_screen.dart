import 'package:flutter/material.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expandedIndex;

  static const List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'How do I add a new transaction?',
      answer:
          'Go to the Journal tab and tap the "New Entry" button (the + button). '
          'Enter the date and a short description of what happened (e.g. "Sold goods to a customer"). '
          'Then add at least two lines: pick an account for each line and enter either a Debit or a Credit amount. '
          'The total of all Debits must equal the total of all Credits before you can save. '
          'Think of it like: every time money or value moves, it comes from one place (Credit) and goes to another (Debit).',
    ),
    _FaqItem(
      question: 'Why won\'t the app let me save my entry?',
      answer:
          'The app only saves when your entry is "balanced." That means: Total Debits must equal Total Credits. '
          'Also make sure you have a description, at least two lines, no duplicate accounts in the same entry, '
          'and each line has either a debit or a credit (not both). If you see a red message when saving, '
          'check those points and adjust the amounts until both totals match.',
    ),
    _FaqItem(
      question: 'What does "void" mean?',
      answer:
          'Voiding an entry means you cancel it without deleting it. The entry stays in the Journal so you have a record, '
          'but the app will ignore it when showing your Ledger and Reports—as if it never happened. '
          'Use this when you entered something by mistake or the transaction was cancelled. Voiding cannot be undone.',
    ),
    _FaqItem(
      question: 'Why don\'t I see an account in the Ledger?',
      answer:
          'The Ledger only lists accounts that have at least one transaction. If you created an account but never used it '
          'in any journal entry, it won\'t show under that category yet. Add a journal entry that uses that account, '
          'and it will appear in the Ledger under the right category (Assets, Liabilities, etc.).',
    ),
    _FaqItem(
      question: 'How does the app figure out my account balance?',
      answer:
          'For each account, the app adds up all the Debits and all the Credits from your (non-voided) entries. '
          'Some accounts (like Cash, Inventory) normally have a "Debit" balance: Balance = Debits minus Credits. '
          'Others (like Sales, Loans) normally have a "Credit" balance: Balance = Credits minus Debits. '
          'The app uses the account type to show the correct sign so your Ledger and Reports make sense.',
    ),
    _FaqItem(
      question: 'What does "locked" mean on an account?',
      answer:
          'An account becomes "locked" after it has been used in at least one saved journal entry. '
          'Locked accounts can\'t be deleted (to keep your history correct), but you can still "archive" them '
          'to hide them from the main list if you no longer use them.',
    ),
    _FaqItem(
      question: 'Can I delete an account?',
      answer:
          'You can only delete accounts that have never been used in any journal entry. '
          'If an account has been used even once, you\'ll need to archive it instead. '
          'Archiving hides the account from the active list but keeps your past data intact.',
    ),
    _FaqItem(
      question: 'Why don\'t my reports show my latest entries?',
      answer:
          'Reports use the date range you choose and only include entries that are not voided. '
          'Check that the date range includes the day you added the entry, and that the entry wasn\'t voided. '
          'If you voided it by mistake, you would need to add a new entry to correct the report.',
    ),
    _FaqItem(
      question: 'Where is my data stored?',
      answer:
          'Your data is stored on your device in a local database. Nothing is sent to the cloud unless you use a backup or sync feature. '
          'What you enter (and what was set up when you started) is what the app uses—there is no fake or sample data mixed in.',
    ),
    _FaqItem(
      question: 'How do I change my name or business details?',
      answer:
          'Tap your profile picture (or avatar) in the top-right of the screen, then choose "Profile." '
          'Edit the fields you want (name, email, business name, address, etc.) and tap "Save Changes." '
          'Username and email are required; the rest is optional.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'FAQs',
        showBackButton: true,
        onBackTap: () => Navigator.maybePop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1E),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_faqs.length, (index) {
            final faq = _faqs[index];
            final isExpanded = _expandedIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                elevation: 1,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _expandedIndex = isExpanded ? null : index;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState:
                        isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    firstChild: _buildQuestionRow(faq.question, isExpanded: false),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildQuestionRow(faq.question, isExpanded: true),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            faq.answer,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuestionRow(String question, {required bool isExpanded}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              question,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1C1E),
              ),
            ),
          ),
          Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.grey[600],
            size: 24,
          ),
        ],
      ),
    );
  }
}
