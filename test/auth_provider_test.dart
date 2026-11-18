import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/models/product.dart';
import 'package:my_first_flutter_ui/providers/cart_provider.dart';

void main() {
  group('CartNotifier Riverpod Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    final testProduct = Product(
      id: 1,
      createdAt: DateTime.now(),
      name: 'LEGO X-Wing',
      price: 49.99,
      stock: 2,
      categoryId: 1,
    );

    test('Initial cart state is empty', () {
      final cart = container.read(cartProvider);
      expect(cart, isEmpty);
      expect(container.read(cartProvider.notifier).itemCount, 0);
      expect(container.read(cartProvider.notifier).total, 0.0);
    });

    test('addToCart adds item and computes subtotal / running total', () {
      final notifier = container.read(cartProvider.notifier);

      final added = notifier.addToCart(testProduct);
      expect(added, isTrue);

      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.quantity, 1);
      expect(notifier.itemCount, 1);
      expect(notifier.total, 49.99);
    });

    test('addToCart respects available stock limit', () {
      final notifier = container.read(cartProvider.notifier);

      expect(notifier.addToCart(testProduct), isTrue); // Qty 1
      expect(notifier.addToCart(testProduct), isTrue); // Qty 2 (max stock)
      expect(notifier.addToCart(testProduct), isFalse); // Exceeds stock (fails)

      final cart = container.read(cartProvider);
      expect(cart.first.quantity, 2);
    });

    test('increment, decrement and clearCart work properly', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addToCart(testProduct);

      notifier.increment(testProduct.id);
      expect(container.read(cartProvider).first.quantity, 2);

      notifier.decrement(testProduct.id);
      expect(container.read(cartProvider).first.quantity, 1);

      notifier.clearCart();
      expect(container.read(cartProvider), isEmpty);
    });
  });
}
