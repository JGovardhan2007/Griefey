import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _isLoading = ValueNotifier<bool>(false);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset('assets/images/griefey_logo.png', height: 100),
                const SizedBox(height: 16),
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.oswald(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to manage grievances',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    filled: true,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    filled: true,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ValueListenableBuilder<bool>(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, child) {
                    return isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _login,
                            child: const Text('Login'),
                          );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text('New here? Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _isLoading.dispose();
    super.dispose();
  }
}
