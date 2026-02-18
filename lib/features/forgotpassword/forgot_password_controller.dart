import 'package:flutter/material.dart';

class ForgotPasswordController extends ChangeNotifier {
  final emailController = TextEditingController();
  bool isLoading = false;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> handleResetPassword(BuildContext context) async {
    final email = emailController.text.trim();

    if(email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }
    setLoading(true);

    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));

    setLoading(false);

    if(!context.mounted) return;

    // Show success and go back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reset link sent to $email!')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}