import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../utils/lego_theme.dart';
import 'signup_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final service = ref.read(supabaseServiceProvider);
    try {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: $e'),
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
                                    const Text(
                                      'Builder Sign In',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: LegoTheme.black,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

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
                                    const SizedBox(height: 14),

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
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Please enter password';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    // Sign In Button
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: LegoTheme.blue,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: _isLoading
                                          ? null
                                          : _submitEmailSignIn,
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: Colors.white),
                                            )
                                          : const Text(
                                              'Sign In',
                                              style: TextStyle(
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
                                    const SizedBox(height: 20),

                                    // Switch to Register
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text('Need a brick account?'),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const SignUpPage()),
                                            );
                                          },
                                          child: const Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: LegoTheme.green,
                                            ),
                                          ),
                                        ),
                                      ],
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
