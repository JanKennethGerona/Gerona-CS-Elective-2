import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';
import 'shop_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastNotifiedUserId;
  bool _showingDialog = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      final user = authProvider.currentUser!;
      
      // Check if this session change needs a first-time or returning-user alert
      if (_lastNotifiedUserId != user.id && !_showingDialog) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleAuthDialogs(context, user);
        });
      }

      return const ShopScreen();
    }

    // Reset when signed out
    _lastNotifiedUserId = null;
    return const AuthScreen();
  }

  void _handleAuthDialogs(BuildContext context, User user) {
    if (!mounted) return;
    _lastNotifiedUserId = user.id;

    // Determine if user is brand new or returning
    // Supabase sets createdAt and lastSignInAt. If they differ by more than a few seconds, user is returning.
    final createdAt = DateTime.tryParse(user.createdAt);
    final lastSignInAt = user.lastSignInAt != null ? DateTime.tryParse(user.lastSignInAt!) : null;

    final isFirstTime = createdAt != null &&
        (lastSignInAt == null ||
            lastSignInAt.difference(createdAt).inSeconds.abs() <= 5);

    final provider = user.appMetadata['provider'] as String? ?? 'Google';
    final email = user.email ?? 'your account';

    setState(() => _showingDialog = true);

    if (isFirstTime) {
      // First-time sign in welcome dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF00852B), width: 3), // LEGO Green
          ),
          title: const Row(
            children: [
              Icon(Icons.celebration, color: Color(0xFF00852B), size: 28),
              SizedBox(width: 10),
              Text(
                'Welcome New Builder!',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are signing in for the first time using $provider ($email).',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00852B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Your BRICKED account has been successfully created. Ready to build your imagination?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00852B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _showingDialog = false);
              },
              child: const Text('Start Building!'),
            ),
          ],
        ),
      );
    } else {
      // Returning user confirmation dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF0055BF), width: 3), // LEGO Blue
          ),
          title: const Row(
            children: [
              Icon(Icons.history, color: Color(0xFF0055BF), size: 28),
              SizedBox(width: 10),
              Text(
                'Existing Account Found',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have previously signed in using $provider ($email).',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0055BF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Do you want to log in to your existing account?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _showingDialog = false);
                context.read<AuthProvider>().signOut();
              },
              child: const Text(
                'Switch Account',
                style: TextStyle(color: Colors.red),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0055BF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _showingDialog = false);
              },
              child: const Text('Continue to Account'),
            ),
          ],
        ),
      );
    }
  }
}
