import 'package:flutter/material.dart';
import 'signup_controller.dart';
import 'widgets/signup_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final controller = SignupController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LOGO SECTION
                    const Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: Color(0xFF374151),
                    ),
                    const Text(
                      "BOOKKEEPING",
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Create your account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Start managing your books today",
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    // GOOGLE BUTTON
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/google_logo.png',
                            height: 20,
                            // Fallback if the image still fails to load
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.g_mobiledata,
                                  color: Colors.red,
                                ),
                          ),
                          const SizedBox(width: 12),
                          const Flexible(
                            child: Text(
                              "Continue with Google",
                              style: TextStyle(
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const _Divider(),

                    // INPUT FIELDS
                    SignupInput(
                      label: "Full Name",
                      hint: "John Doe",
                      icon: Icons.person_outline,
                      controller: controller.nameController,
                    ),
                    SignupInput(
                      label: "Email",
                      hint: "your@example.com",
                      icon: Icons.mail_outline,
                      controller: controller.emailController,
                    ),
                    SignupInput(
                      label: "Company Name (Optional)",
                      hint: "Your Company",
                      icon: Icons.business_outlined,
                      controller: controller.companyController,
                    ),
                    SignupInput(
                      label: "Password",
                      hint: "••••••••",
                      icon: Icons.lock_outline,
                      controller: controller.passwordController,
                      isPassword: true,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Must be at least 8 characters",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SignupInput(
                      label: "Confirm Password",
                      hint: "••••••••",
                      icon: Icons.lock_outline,
                      controller: controller.confirmPasswordController,
                      isPassword: true,
                    ),

                    const SizedBox(height: 12),

                    // SIGN UP BUTTON
                    ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () => controller.handleSignup(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Create account",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    const SizedBox(height: 24),
                    const _TermsText(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(child: Divider(color: Color(0xFFE5E7EB))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "OR",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Divider(color: Color(0xFFE5E7EB))),
        ],
      ),
    );
  }
}

class _TermsText extends StatelessWidget {
  const _TermsText();

  static const _linkStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFF2563EB),
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const _greyStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFF6B7280),
    height: 1.5,
  );

  static void _showTermsOrPolicy(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const SingleChildScrollView(
          child: Text('texts here', style: _greyStyle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text("By signing up, you agree to our ", style: _greyStyle),
            GestureDetector(
              onTap: () => _showTermsOrPolicy(context, 'Terms of Service'),
              child: const MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text("Terms of Service", style: _linkStyle),
              ),
            ),
            const Text(" and ", style: _greyStyle),
            GestureDetector(
              onTap: () => _showTermsOrPolicy(context, 'Privacy Policy'),
              child: const MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text("Privacy Policy", style: _linkStyle),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Already have an account? ",
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Sign in',
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
