import 'package:flutter/material.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';

class IncomeStatementScreen extends StatelessWidget {
  const IncomeStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Income Statement', showBackButton: true),
      body: Center(child: Text('Income Statement details go here')),
    );
  }
}
