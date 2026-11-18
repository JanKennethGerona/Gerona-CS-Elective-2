import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'auth_providers.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    // When the user logs out, clear the cart automatically
    ref.listen(currentUserProvider, (previous, next) {
      if (previous != null && next == null) {
        state = [];
      }
    });
    return [];
  }

  int get itemCount => state.fold(0, (sum, i) => sum + i.quantity);
  double get total => state.fold(0.0, (sum, i) => sum + i.subtotal);

  bool addToCart(Product product) {
    if (product.stock <= 0) return false;

    final index = state.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      final current = state[index];
      if (current.quantity >= product.stock) {
        return false; // cannot exceed available stock
      }
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i]
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
    return true;
  }

  void increment(int productId) {
    final index = state.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      final item = state[index];
      if (item.quantity < item.product.stock) {
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == index)
              state[i].copyWith(quantity: state[i].quantity + 1)
            else
              state[i]
        ];
      }
    }
  }

  void decrement(int productId) {
    final index = state.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      final item = state[index];
      if (item.quantity > 1) {
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == index)
              state[i].copyWith(quantity: state[i].quantity - 1)
            else
              state[i]
        ];
      } else {
        removeFromCart(productId);
      }
    }
  }

  void removeFromCart(int productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});
