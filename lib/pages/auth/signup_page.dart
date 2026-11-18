import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../utils/lego_theme.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstController = TextEditingController();
  final _lastController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submitSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final service = ref.read(supabaseServiceProvider);
    try {
      final res = await service.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstname: _firstController.text.trim(),
        lastname: _lastController.text.trim(),
      );

      if (mounted) {
        if (res?.user != null) {
          Navigator.pop(context); // Back to login / auth gate
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account built successfully! Welcome builder.'),
              backgroundColor: LegoTheme.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please check your email to confirm registration.'),
              backgroundColor: LegoTheme.yellow,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up error: $e'),
            backgroundColor: LegoTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LegoTheme.plateBg,
      appBar: AppBar(
        backgroundColor: LegoTheme.red,
        title: const Text(
          'Register Account',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: LegoTheme.green, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    offset: Offset(0, 6),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Join the Builders',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: LegoTheme.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Every new account begins as a Customer role.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 18),

                    // First & Last Name
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstController,
                            decoration: const InputDecoration(
                              labelText: 'First Name *',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _lastController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name *',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address *',
                        hintText: 'builder@lego.com',
                        prefixIcon: Icon(Icons.email_outlined, color: LegoTheme.blue),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!val.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password *',
                        prefixIcon: const Icon(Icons.lock_outline, color: LegoTheme.blue),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Password required';
                        }
                        if (val.length < 6) return 'Minimum 6 chars';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscurePassword,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password *',
                        prefixIcon: Icon(Icons.lock_reset, color: LegoTheme.blue),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (val) {
                        if (val != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Submit button
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: LegoTheme.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : _submitSignUp,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Build Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
