import 'package:flutter/material.dart';

class SignupInput extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;

  const SignupInput({
    super.key, 
    required this.label, 
    required this.hint, 
    required this.icon, 
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, 
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
            filled: true,
            fillColor: const Color(0xFFF3F4F6), // Correct light gray
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            // Makes the field look interactive on focus
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 1),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}