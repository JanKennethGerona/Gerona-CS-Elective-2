import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_confirmation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';
import '../state/cart_model.dart';

class AppRouter {
  static GoRouter createRouter(CartModel cartModel) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: cartModel,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            return ProductDetailScreen(productId: productId);
          },
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/checkout',
          redirect: (context, state) {
            // Guard: Reachable only after at least one item is in the cart
            if (cartModel.isEmpty) {
              return '/cart';
            }
            return null;
          },
          builder: (context, state) => const CheckoutConfirmationScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('404 - Page Not Found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Return Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
