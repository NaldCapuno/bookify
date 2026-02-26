import 'package:flutter/material.dart';

class EmptyReportPlaceholder extends StatelessWidget {
  final String message;
  const EmptyReportPlaceholder({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      // Added Center for better UI
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
