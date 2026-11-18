import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import 'auth_providers.dart';
import 'cart_provider.dart';

final customerOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  final raw = await service.fetchCustomerOrders();
  return raw.map((m) => OrderModel.fromJson(m)).toList();
});

final adminOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  final raw = await service.fetchAdminOrders();
  return raw.map((m) => OrderModel.fromJson(m)).toList();
});

class CheckoutNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() async => null;

  Future<Map<String, dynamic>> submitOrder() async {
    state = const AsyncValue.loading();
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      final err = Exception('Cart is empty');
      state = AsyncValue.error(err, StackTrace.current);
      throw err;
    }

    final payload = cart
        .map((i) => {
              'product_id': i.product.id,
              'quantity': i.quantity,
            })
        .toList();

    try {
      final service = ref.read(supabaseServiceProvider);
      final result = await service.placeOrder(payload);

      // Emptied after a successful order
      ref.read(cartProvider.notifier).clearCart();
      ref.invalidate(customerOrdersProvider);
      ref.invalidate(adminOrdersProvider);

      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final checkoutProvider =
    AsyncNotifierProvider<CheckoutNotifier, Map<String, dynamic>?>(() {
  return CheckoutNotifier();
});
