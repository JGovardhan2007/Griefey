import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _isLoading = ValueNotifier<bool>(false);
  final _isPasswordVisible = ValueNotifier<bool>(false);

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.signUpWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
    );

    _isLoading.value = false;

    if (mounted && error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    // On success, the auth listener will navigate.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Create Your Account',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.oswald(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join us to get started',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 48),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isPasswordVisible,
                    builder: (context, isVisible, child) {
                      return _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: !isVisible,
                        suffixIcon: IconButton(
                          icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => _isPasswordVisible.value = !isVisible,
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isPasswordVisible,
                    builder: (context, isVisible, child) {
                      return _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        icon: Icons.lock_outline,
                        obscureText: !isVisible,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isLoading,
                    builder: (context, isLoading, child) {
                      return isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _signup,
                              child: const Text('Create Account'),
                            );
                    },
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Already have an account? Log In'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _isLoading.dispose();
    _isPasswordVisible.dispose();
    super.dispose();
  }
}
