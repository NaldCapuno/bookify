import 'package:flutter/material.dart';

class SignupController extends ChangeNotifier {
  // These "controllers" grab the text the user types into the boxes
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final companyController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  void toggleLoading(bool value) {
    isLoading = value;
    notifyListeners(); // This tells the UI to "redraw" itself
  }

  // This mirrors your Figma logic: Check passwords then "sign up"
  Future<void> handleSignup(BuildContext context) async {
    if (passwordController.text != confirmPasswordController.text) {
      _showError(context, 'Passwords do not match');
      return;
    }
    
    toggleLoading(true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate a wait
    toggleLoading(false);

    if(!context.mounted) return;
    
    _showError(context, 'Account created! (Simulation)');
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
