import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'pages/auth/auth_gate.dart';
import 'utils/lego_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase if credentials have been configured
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization note: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: BrickedShopApp(),
    ),
  );
}

class BrickedShopApp extends StatelessWidget {
  const BrickedShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BRICKED Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: LegoTheme.red,
          primary: LegoTheme.red,
          secondary: LegoTheme.yellow,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: LegoTheme.plateBg,
        cardTheme: const CardThemeData(
          color: Colors.white,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
