import 'package:flutter/material.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';

class BalanceSheetScreen extends StatelessWidget {
  const BalanceSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Balance Sheet', showBackButton: true),
      body: Center(child: Text('Balance Sheet details go here')),
    );
  }
}
