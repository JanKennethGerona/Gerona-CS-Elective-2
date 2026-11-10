import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  // LEGO Theme Palette
  static const Color legoRed = Color(0xFFD11013);
  static const Color legoYellow = Color(0xFFFFD500);
  static const Color legoBlue = Color(0xFF0055BF);
  static const Color legoGreen = Color(0xFF00852B);
  static const Color legoBlack = Color(0xFF1B1B1B);
  static const Color legoPlateBg = Color(0xFFF4F1EA);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    bool success;
    if (_isSignUp) {
      success = await authProvider.signUpWithEmail(email, password);
      if (mounted && success && authProvider.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Brick built! Please check your email to confirm.'),
            backgroundColor: legoGreen,
          ),
        );
      }
    } else {
      success = await authProvider.signInWithEmail(email, password);
    }

    if (mounted && !success && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: legoRed,
        ),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = context.read<AuthProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await authProvider.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Google Sign In error: $e'),
            backgroundColor: legoRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: legoPlateBg,
      body: Stack(
        children: [
          // Background Stud Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _LegoStudBackgroundPainter(),
            ),
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
                      // LEGO Studs Header on the Card
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          6,
                          (index) => Container(
                            width: 28,
                            height: 12,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: legoRed,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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

                      // Main LEGO Brick Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: legoRed, width: 4),
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
                            // Top Red Brick Header Bar with Logo
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: const BoxDecoration(
                                color: legoRed,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                              ),
                              child: Column(
                                children: [
                                  // BRICKED Style Badge Logo
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: legoRed,
                                      border: Border.all(color: legoYellow, width: 3),
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
                                        fontFamily: 'sans-serif',
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            offset: Offset(2, 2),
                                            blurRadius: 0,
                                          ),
                                          Shadow(
                                            color: legoYellow,
                                            offset: Offset(-1, -1),
                                            blurRadius: 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'Build Your Imagination, Brick by Brick.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: legoYellow,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Form and Buttons Body
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Mode Selector: Sign In vs Sign Up
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _LegoTabButton(
                                            title: 'Sign In',
                                            isSelected: !_isSignUp,
                                            brickColor: legoBlue,
                                            onTap: () => setState(() => _isSignUp = false),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _LegoTabButton(
                                            title: 'Register',
                                            isSelected: _isSignUp,
                                            brickColor: legoGreen,
                                            onTap: () => setState(() => _isSignUp = true),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // Email Input
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: 'Email Address',
                                        hintText: 'builder@lego.com',
                                        prefixIcon: const Icon(Icons.email_outlined, color: legoBlue),
                                        filled: true,
                                        fillColor: const Color(0xFFF9F9F9),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 2),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 2),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: legoBlue, width: 2.5),
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!val.contains('@') || !val.contains('.')) {
                                          return 'Enter a valid email address';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 14),

                                    // Password Input
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: const Icon(Icons.lock_outline, color: legoBlue),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: Colors.grey.shade600,
                                          ),
                                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF9F9F9),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 2),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 2),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: legoBlue, width: 2.5),
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (val.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    // Action Button (LEGO Brick 3D Style)
                                    _LegoBrickButton(
                                      text: _isSignUp ? 'Build Account' : 'Sign In',
                                      color: _isSignUp ? legoGreen : legoBlue,
                                      isLoading: authProvider.isLoading,
                                      onTap: authProvider.isLoading ? null : _submitEmailAuth,
                                    ),
                                    const SizedBox(height: 20),

                                    // Divider with LEGO mini bricks
                                    Row(
                                      children: [
                                        Expanded(child: Container(height: 2, color: Colors.grey.shade300)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                          child: Text(
                                            'OR CONNECT WITH',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.0,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                        Expanded(child: Container(height: 2, color: Colors.grey.shade300)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Google OAuth Button (LEGO themed with bold border and 3D shadow)
                                    InkWell(
                                      onTap: authProvider.isLoading ? null : _signInWithGoogle,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 13),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.black87, width: 2.5),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              alignment: Alignment.center,
                                              child: const Text(
                                                'G',
                                                style: TextStyle(
                                                  color: Color(0xFF4285F4),
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              'Continue with Google',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: legoBlack,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
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

                      // Bottom LEGO studs decorative row
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegoDot(color: legoRed),
                          _LegoDot(color: legoYellow),
                          _LegoDot(color: legoBlue),
                          _LegoDot(color: legoGreen),
                        ],
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

// LEGO 3D Brick Button
class _LegoBrickButton extends StatelessWidget {
  final String text;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  const _LegoBrickButton({
    required this.text,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withValues(alpha: 0.25), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// LEGO Tab Segment Button
class _LegoTabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color brickColor;
  final VoidCallback onTap;

  const _LegoTabButton({
    required this.title,
    required this.isSelected,
    required this.brickColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? brickColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black.withValues(alpha: 0.2) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _LegoDot extends StatelessWidget {
  final Color color;

  const _LegoDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black26, width: 1.5),
      ),
    );
  }
}

// Background Painter that draws subtle LEGO plate studs grid
class _LegoStudBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2DDD3)
      ..style = PaintingStyle.fill;

    const spacing = 36.0;
    const radius = 6.0;

    for (double x = 18; x < size.width; x += spacing) {
      for (double y = 18; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
