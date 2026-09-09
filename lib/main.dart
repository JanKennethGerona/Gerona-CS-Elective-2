import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'routing/app_router.dart';
import 'state/cart_model.dart';
import 'state/theme_model.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => CartModel()),
      ],
      child: const BrickedApp(),
    ),
  );
}

class BrickedApp extends StatefulWidget {
  const BrickedApp({super.key});

  @override
  State<BrickedApp> createState() => _BrickedAppState();
}

class _BrickedAppState extends State<BrickedApp> {
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    final themeModel = context.watch<ThemeModel>();
    final cartModel = context.read<CartModel>();

    _router ??= AppRouter.createRouter(cartModel);

    return MaterialApp.router(
      title: 'Bricked',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeModel.themeMode,
      routerConfig: _router,
    );
  }
}