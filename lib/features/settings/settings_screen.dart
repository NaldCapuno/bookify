import 'package:flutter/material.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Settings', showBackButton: true),
      body: Center(child: Text('Settings go here')),
    );
  }
}
