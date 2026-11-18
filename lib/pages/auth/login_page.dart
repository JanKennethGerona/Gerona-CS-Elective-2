import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../utils/lego_theme.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstController = TextEditingController();
  final _lastController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstController.dispose();
    _lastController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final service = ref.read(supabaseServiceProvider);
    try {
      if (_isSignUp) {
        final res = await service.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          firstname: _firstController.text.trim(),
          lastname: _lastController.text.trim(),
        );
        if (mounted) {
          if (res?.user != null) {
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
      } else {
        final res = await service.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (res?.user == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign-in failed. Check credentials or email confirmation.'),
              backgroundColor: LegoTheme.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_isSignUp ? "Sign Up" : "Login"} error: $e'),
            backgroundColor: LegoTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    final service = ref.read(supabaseServiceProvider);
    try {
      await service.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In error: $e'),
            backgroundColor: LegoTheme.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LegoTheme.plateBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: LegoStudPainter()),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Decorative Studs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          6,
                          (index) => Container(
                            width: 28,
                            height: 12,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: LegoTheme.red,
                              borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(6)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  offset: const Offset(0, -1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Card Box
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: LegoTheme.red, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              offset: Offset(0, 8),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header Bar
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: const BoxDecoration(
                                color: LegoTheme.red,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10)),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: LegoTheme.red,
                                      border: Border.all(
                                          color: LegoTheme.yellow, width: 3),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'BRICKED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 26,
                                        letterSpacing: -0.5,
                                        shadows: [
                                          Shadow(
                                              color: Colors.black,
                                              offset: Offset(2, 2)),
                                          Shadow(
                                              color: LegoTheme.yellow,
                                              offset: Offset(-1, -1)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'Build Your Imagination, Brick by Brick.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: LegoTheme.yellow,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Segment Tabs: Sign In vs Register
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => setState(() => _isSignUp = false),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              decoration: BoxDecoration(
                                                color: !_isSignUp ? LegoTheme.blue : Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: !_isSignUp ? Colors.black26 : Colors.grey.shade300,
                                                  width: 2,
                                                ),
                                                boxShadow: !_isSignUp
                                                    ? [
                                                        const BoxShadow(
                                                          color: Colors.black26,
                                                          offset: Offset(0, 3),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  color: !_isSignUp ? Colors.white : Colors.grey.shade700,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => setState(() => _isSignUp = true),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              decoration: BoxDecoration(
                                                color: _isSignUp ? LegoTheme.green : Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: _isSignUp ? Colors.black26 : Colors.grey.shade300,
                                                  width: 2,
                                                ),
                                                boxShadow: _isSignUp
                                                    ? [
                                                        const BoxShadow(
                                                          color: Colors.black26,
                                                          offset: Offset(0, 3),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Register',
                                                style: TextStyle(
                                                  color: _isSignUp ? Colors.white : Colors.grey.shade700,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),

                                    // First & Last Name inputs (Sign Up only)
                                    if (_isSignUp) ...[
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
                                              validator: (val) => _isSignUp && (val == null || val.trim().isEmpty)
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
                                              validator: (val) => _isSignUp && (val == null || val.trim().isEmpty)
                                                  ? 'Required'
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                    ],

                                    // Email
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: 'Email Address',
                                        hintText: 'builder@lego.com',
                                        prefixIcon: const Icon(Icons.email_outlined,
                                            color: LegoTheme.blue),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        isDense: true,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!val.contains('@')) {
                                          return 'Invalid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // Password
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: const Icon(Icons.lock_outline,
                                            color: LegoTheme.blue),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined),
                                          onPressed: () => setState(() =>
                                              _obscurePassword =
                                                  !_obscurePassword),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        isDense: true,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Please enter password';
                                        }
                                        if (_isSignUp && val.length < 6) {
                                          return 'Minimum 6 chars';
                                        }
                                        return null;
                                      },
                                    ),

                                    // Confirm Password (Sign Up only)
                                    if (_isSignUp) ...[
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: _obscurePassword,
                                        decoration: const InputDecoration(
                                          labelText: 'Confirm Password *',
                                          prefixIcon: Icon(Icons.lock_reset, color: LegoTheme.blue),
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        validator: (val) {
                                          if (_isSignUp && val != _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                    const SizedBox(height: 20),

                                    // Action Button
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: _isSignUp ? LegoTheme.green : LegoTheme.blue,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: _isLoading
                                          ? null
                                          : _submitAuth,
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: Colors.white),
                                            )
                                          : Text(
                                              _isSignUp ? 'Build Account' : 'Sign In',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Google button
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13),
                                        side: const BorderSide(
                                            color: Colors.black87, width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: _isLoading
                                          ? null
                                          : _signInWithGoogle,
                                      icon: const Text(
                                        'G',
                                        style: TextStyle(
                                          color: Color(0xFF4285F4),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                      label: const Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: LegoTheme.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
