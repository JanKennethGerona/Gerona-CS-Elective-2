import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/cart_model.dart';
import '../state/theme_model.dart';

class BrickedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showCartButton;
  final bool showThemeToggle;
  final Widget? leading;

  const BrickedAppBar({
    super.key,
    this.title = 'Bricked',
    this.showCartButton = true,
    this.showThemeToggle = true,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeModel = context.watch<ThemeModel>();
    final cartModel = context.watch<CartModel>();

    return AppBar(
      leading: leading,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.extension,
              size: 20,
              color: theme.colorScheme.onSecondary,
            ),
          ),
          Text(
            title,
            style: theme.appBarTheme.titleTextStyle ??
                const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
      actions: [
        if (showThemeToggle)
          IconButton(
            key: const Key('theme_toggle_button'),
            tooltip: themeModel.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              themeModel.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeModel.toggleTheme();
            },
          ),
        if (showCartButton)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              key: const Key('appbar_cart_button'),
              tooltip: 'View Cart',
              onPressed: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                context.push('/cart');
              },
              icon: Badge.count(
                count: cartModel.totalItemCount,
                isLabelVisible: cartModel.totalItemCount > 0,
                backgroundColor: theme.colorScheme.secondary,
                textColor: theme.colorScheme.onSecondary,
                textStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
      ],
    );
  }
}
