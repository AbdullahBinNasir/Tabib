import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_input_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _resetEmailSent = false;

  // Color scheme constants
  static const Color primaryBlue = Color(0xFF0B7285);
  static const Color secondaryBlue = Color(0xFF0891B2);
  static const Color backgroundColor = Color(0xFFF8FFFE);
  static const Color headingTextColor = Color(0xFF0E7490);
  static const Color secondaryTextColor = Color(0xFF64748B);
  static const Color errorColor = Color(0xFFDC2626);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<AuthProvider>().resetPassword(
            _emailController.text.trim(),
          );

      if (success && mounted) {
        setState(() {
          _resetEmailSent = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: headingTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 64,
                  color: primaryBlue,
                ).animate().fadeIn().scale(),
                const SizedBox(height: 32),
                Text(
                  'Reset Password',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: headingTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(begin: -0.2),
                const SizedBox(height: 16),
                Text(
                  _resetEmailSent
                      ? 'Password reset email has been sent. Please check your inbox.'
                      : 'Enter your email address and we\'ll send you instructions to reset your password.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: secondaryTextColor,
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(
                      begin: -0.2,
                      delay: const Duration(milliseconds: 200),
                    ),
                const SizedBox(height: 32),
                if (!_resetEmailSent) ...[                  
                  CustomInputField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ).animate().fadeIn().slideX(
                        begin: -0.2,
                        delay: const Duration(milliseconds: 400),
                      ),
                  const SizedBox(height: 24),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.error != null) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            authProvider.error!,
                            style: const TextStyle(color: errorColor),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _handleResetPassword,
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Send Reset Link',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                      },
                    ),
                  ).animate().fadeIn().slideY(
                        begin: 0.2,
                        delay: const Duration(milliseconds: 600),
                      ),
                ] else ...[                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ).animate().fadeIn().scale(
                        delay: const Duration(milliseconds: 400),
                      ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}