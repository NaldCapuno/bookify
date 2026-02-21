import 'package:flutter/material.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';

class CashFlowScreen extends StatelessWidget {
  const CashFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Cash Flow', showBackButton: true),
      body: Center(child: Text('Cash Flow details go here')),
    );
  }
}
