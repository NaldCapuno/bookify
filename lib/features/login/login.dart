import 'package:flutter/material.dart';
import '/core/widgets/login_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- LOGIC SECTION ---
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        // Navigate to main navigation screen
        Navigator.pushReplacementNamed(context, '/main');
        print("Logged in as ${_emailController.text}");
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoading = false);
    print("Google Login Success");
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- UI SECTION ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 448),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Header
                const Icon(
                  Icons.account_balance_wallet,
                  size: 48,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome to Digital Bookkeeper (Copy)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 32),

                // Social Login
                GoogleSignInButton(
                  onPressed: _handleGoogleLogin,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),
                const OrDivider(),
                const SizedBox(height: 24),

                // Inputs
                LabeledInput(
                  label: 'Email',
                  hint: 'your@example.com',
                  icon: Icons.mail_outline,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                LabeledInput(
                  label: 'Password',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                // Sign In Button
                PrimaryButton(
                  text: 'Sign in',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),

                // Footer
                _buildFooterLinks(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // kept as a local helper since it's specific to this page's layout
  Widget _buildFooterLinks() {
    // 1. Use Wrap instead of Row to handle small screens automatically
    return Wrap(
      alignment: WrapAlignment.spaceBetween, // Pushes items to edges like Row
      crossAxisAlignment: WrapCrossAlignment.center, // Vertically centers them
      spacing: 20, // Horizontal space between items
      runSpacing: 10, // Vertical space if they wrap to a new line
      children: [
        // Forgot Password Button
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Forgot password?',
            style: TextStyle(color: Color(0xFF4B5563)),
          ),
        ),

        // Sign Up Section
        Row(
          mainAxisSize: MainAxisSize.min, // Keeps this group tight together
          children: [
            const Text(
              'Need an account? ',
              style: TextStyle(color: Color(0xFF4B5563)),
            ),
            TextButton(
              onPressed: () {
                // Add navigation here later
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Sign up',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
