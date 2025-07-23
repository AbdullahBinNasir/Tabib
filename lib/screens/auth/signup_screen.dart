import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:tabib/screens/home/home_screen.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_input_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  // Medical Theme Colors
  static const Color primaryMedical = Color(0xFF2E7D8F); // Teal blue
  static const Color secondaryMedical = Color(0xFF4A90A4); // Light teal
  static const Color accentMedical = Color(0xFF7FB3D3); // Sky blue
  static const Color backgroundMedical = Color(0xFFF8FAFB); // Off white
  static const Color cardMedical = Color(0xFFFFFFFF); // Pure white
  static const Color textPrimary = Color(0xFF1A365D); // Dark blue-gray
  static const Color textSecondary = Color(0xFF4A5568); // Medium gray
  static const Color successMedical = Color(0xFF38A169); // Medical green
  static const Color errorMedical = Color(0xFFE53E3E); // Medical red
  static const Color borderMedical = Color(0xFFE2E8F0); // Light gray

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryMedical,
              onPrimary: Colors.white,
              surface: cardMedical,
              onSurface: textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Passwords do not match'),
            backgroundColor: errorMedical,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      final success = await context.read<AuthProvider>().signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            dateOfBirth: _dateOfBirthController.text,
          );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundMedical,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cardMedical,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primaryMedical.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryMedical),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Medical Header Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardMedical,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryMedical.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Medical Cross Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryMedical.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.medical_services_outlined,
                        size: 48,
                        color: primaryMedical,
                      ),
                    ).animate().scale(delay: const Duration(milliseconds: 200)),
                    const SizedBox(height: 20),
                    Text(
                      'Create Medical Account',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn().slideY(begin: -0.2),
                    const SizedBox(height: 8),
                    Text(
                      'Join our healthcare platform for better medical care',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: textSecondary,
                            height: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn().slideY(
                          begin: -0.2,
                          delay: const Duration(milliseconds: 200),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Form Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardMedical,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryMedical.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildMedicalInputField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: _fullNameController,
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                        delay: 400,
                      ),
                      
                      _buildMedicalInputField(
                        label: 'Email Address',
                        hint: 'Enter your email',
                        controller: _emailController,
                        icon: Icons.email_outlined,
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
                        delay: 600,
                      ),
                      
                      _buildMedicalInputField(
                        label: 'Phone Number',
                        hint: 'Enter your phone number',
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                        delay: 800,
                      ),
                      
                      _buildMedicalInputField(
                        label: 'Address',
                        hint: 'Enter your address',
                        controller: _addressController,
                        icon: Icons.location_on_outlined,
                        isMultiline: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                        delay: 1000,
                      ),
                      
                      _buildMedicalInputField(
                        label: 'Date of Birth',
                        hint: 'Select your date of birth',
                        controller: _dateOfBirthController,
                        icon: Icons.calendar_today_outlined,
                        readOnly: true,
                        onTap: _selectDate,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your date of birth';
                          }
                          try {
                            final date = DateTime.parse(value);
                            if (date.isAfter(DateTime.now())) {
                              return 'Date of birth cannot be in the future';
                            }
                          } catch (e) {
                            return 'Invalid date format';
                          }
                          return null;
                        },
                        delay: 1200,
                      ),
                      
                      _buildMedicalInputField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        delay: 1400,
                      ),
                      
                      _buildMedicalInputField(
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        controller: _confirmPasswordController,
                        icon: Icons.lock_outline,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        delay: 1600,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Error Display
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          if (authProvider.error != null) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: errorMedical.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: errorMedical.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, 
                                       color: errorMedical, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authProvider.error!,
                                      style: TextStyle(
                                        color: errorMedical,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      
                      // Sign Up Button
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryMedical, secondaryMedical],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primaryMedical.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _handleSignup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return authProvider.isLoading
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Creating Account...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.medical_services, 
                                             color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Create Medical Account',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    );
                            },
                          ),
                        ),
                      ).animate().fadeIn().slideY(
                            begin: 0.2,
                            delay: const Duration(milliseconds: 1800),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isMultiline = false,
    bool readOnly = false,
    VoidCallback? onTap,
    required int delay,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: backgroundMedical,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderMedical, width: 1.5),
            ),
            child: TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: keyboardType,
              obscureText: isPassword,
              readOnly: readOnly,
              onTap: onTap,
              maxLines: isMultiline ? 3 : 1,
              style: TextStyle(
                fontSize: 16,
                color: textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: textSecondary.withOpacity(0.6),
                  fontSize: 15,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryMedical.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: primaryMedical, size: 20),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                errorStyle: TextStyle(
                  color: errorMedical,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ).animate().fadeIn().slideX(
            begin: -0.2,
            delay: Duration(milliseconds: delay),
          ),
    );
  }
}