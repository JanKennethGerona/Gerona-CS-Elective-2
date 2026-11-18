import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../admin/admin_shell.dart';
import 'login_page.dart';
import '../customer/customer_shell.dart';
import '../../providers/auth_providers.dart';
import '../../utils/lego_theme.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  String? _lastNotifiedUserId;
  bool _showingDialog = false;

  void _handleAuthDialogs(BuildContext context, User user) {
    if (!mounted) return;
    _lastNotifiedUserId = user.id;

    final createdAt = DateTime.tryParse(user.createdAt);
    final lastSignInAt = user.lastSignInAt != null
        ? DateTime.tryParse(user.lastSignInAt!)
        : null;

    final isFirstTime = createdAt != null &&
        (lastSignInAt == null ||
            lastSignInAt.difference(createdAt).inSeconds.abs() <= 5);

    final provider = user.appMetadata['provider'] as String? ?? 'Google';
    final email = user.email ?? 'your account';

    setState(() => _showingDialog = true);

    if (isFirstTime) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: LegoTheme.green, width: 3),
          ),
          title: const Row(
            children: [
              Icon(Icons.celebration, color: LegoTheme.green, size: 28),
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
              Text('You are signing in for the first time using $provider ($email).'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: LegoTheme.green.withValues(alpha: 0.1),
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
                backgroundColor: LegoTheme.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: LegoTheme.blue, width: 3),
          ),
          title: const Row(
            children: [
              Icon(Icons.history, color: LegoTheme.blue, size: 28),
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
              Text('You have previously signed in using $provider ($email).'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: LegoTheme.blue.withValues(alpha: 0.1),
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
                ref.read(supabaseServiceProvider).signOut();
              },
              child: const Text(
                'Switch Account',
                style: TextStyle(color: Colors.red),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: LegoTheme.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      _lastNotifiedUserId = null;
      return const LoginPage();
    }

    // Google / First-time prompt trigger
    if (_lastNotifiedUserId != currentUser.id && !_showingDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAuthDialogs(context, currentUser);
      });
    }

    // Load role to route to either AdminShell or CustomerShell
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile?.isAdmin == true) {
          return const AdminShell();
        }
        return const CustomerShell();
      },
      loading: () => const Scaffold(
        backgroundColor: LegoTheme.plateBg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: LegoTheme.red,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Verifying Builder Credentials...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: LegoTheme.red),
              const SizedBox(height: 12),
              Text('Profile error: $e'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.read(supabaseServiceProvider).signOut(),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
