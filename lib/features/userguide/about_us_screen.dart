import 'package:flutter/material.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';

/// About Us screen: app name, what we do, features, who it's for, privacy, version.
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const Color _headingColor = Color(0xFF1A1C1E);
  static const Color _bodyColor = Color(0xFF3D4043);
  static const TextStyle _bodyStyle = TextStyle(
    fontSize: 15,
    height: 1.5,
    color: _bodyColor,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'About Us',
        showBackButton: true,
        onBackTap: () => Navigator.maybePop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildLogoAndTitle(),
          const SizedBox(height: 28),
          _Section(
            icon: Icons.info_outline,
            title: 'About Bookify',
            body:
                'Bookify helps you keep a simple record of your business money—what came in, what went out, '
                'and what you own or owe. Record transactions in the Journal, view account balances in the Ledger, '
                'and run reports such as Income Statement, Balance Sheet, and Cash Flow. You can manage your accounts, '
                'update your profile and business details, and export reports to PDF.',
            indentFirstLine: true,
            bodyStyle: _bodyStyle,
            headingColor: _headingColor,
          ),
          _Section(
            icon: Icons.check_circle_outline,
            title: 'What you can do',
            body:
                '• Journal — Record daily transactions with debits and credits.\n\n'
                '• Ledger — See each account\'s balance at a glance.\n\n'
                '• Reports — Income Statement, Balance Sheet, and Cash Flow for any date range.\n\n'
                '• Accounts — Create and manage categories (e.g. Cash, Sales, Expenses).\n\n'
                '• Profile — Store your name, business name, and contact details.\n\n'
                '• Export — Generate PDFs of your reports.',
            indentFirstLine: false,
            bodyStyle: _bodyStyle,
            headingColor: _headingColor,
          ),
          _Section(
            icon: Icons.people_outline,
            title: 'Who it\'s for',
            body:
                'Whether you run a small business, freelance, or just want to keep track of your money, '
                'Bookify explains everything in plain language. No accounting background is required.',
            indentFirstLine: true,
            bodyStyle: _bodyStyle,
            headingColor: _headingColor,
          ),
          _Section(
            icon: Icons.security_outlined,
            title: 'Your data',
            body:
                'Your data is stored on your device. We don\'t collect or upload your financial information '
                'unless you use a backup or sync feature.',
            indentFirstLine: true,
            bodyStyle: _bodyStyle,
            headingColor: _headingColor,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF232D3F).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 44,
              color: Color(0xFF232D3F),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Bookify',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: _headingColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Digital Bookkeeping App',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Version 1.0.0',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
    required this.indentFirstLine,
    required this.bodyStyle,
    required this.headingColor,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool indentFirstLine;
  final TextStyle bodyStyle;
  final Color headingColor;

  @override
  Widget build(BuildContext context) {
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
                  color: const Color(0xFF232D3F).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF232D3F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: headingColor,
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
