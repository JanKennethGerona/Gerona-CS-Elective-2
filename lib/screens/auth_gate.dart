import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';
import 'shop_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Access strictly restricted to authenticated users only
    if (authProvider.isAuthenticated) {
      return const ShopScreen();
    }

    return const AuthScreen();
  }
}

