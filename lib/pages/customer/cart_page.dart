import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_providers.dart';
import '../../utils/lego_theme.dart';
import 'checkout_confirmation_page.dart';

class CartPage extends ConsumerStatefulWidget {
  final VoidCallback onContinueShopping;
  final VoidCallback onViewOrders;

  const CartPage({
    super.key,
    required this.onContinueShopping,
    required this.onViewOrders,
  });

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool _isCheckingOut = false;

  Future<void> _handleCheckout() async {
    setState(() => _isCheckingOut = true);
    try {
      final result = await ref.read(checkoutProvider.notifier).submitOrder();
      final orderId = result['order_id'] is int
          ? result['order_id'] as int
          : int.parse(result['order_id'].toString());
      final total = (result['total'] as num?)?.toDouble() ?? 0.0;

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CheckoutConfirmationPage(
              orderId: orderId,
              total: total,
              onContinueShopping: () {
                Navigator.pop(context);
                widget.onContinueShopping();
              },
              onViewOrders: () {
                Navigator.pop(context);
                widget.onViewOrders();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checkout failed: $e'),
            backgroundColor: LegoTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartProvider.notifier).total;
    final count = ref.watch(cartProvider.notifier).itemCount;

    return Scaffold(
      backgroundColor: LegoTheme.plateBg,
      appBar: AppBar(
        backgroundColor: LegoTheme.red,
        title: const Text(
          'Your Brick Cart',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              tooltip: 'Clear Cart',
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: LegoTheme.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Snap some LEGO sets into your box!',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: LegoTheme.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: widget.onContinueShopping,
                      child: const Text('Start Shopping'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: cart.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFDCD7CC),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F000000),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Product Icon / image
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F4EE),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: const Icon(
                                Icons.extension,
                                color: LegoTheme.red,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${item.product.price.toStringAsFixed(2)} each • ${item.product.stock} available',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: LegoTheme.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quantity Controls
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      size: 20),
                                  onPressed: () => ref
                                      .read(cartProvider.notifier)
                                      .decrement(item.product.id),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      size: 20),
                                  onPressed: item.quantity < item.product.stock
                                      ? () => ref
                                          .read(cartProvider.notifier)
                                          .increment(item.product.id)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Running Total & Checkout Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFDCD7CC), width: 2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x10000000),
                        offset: Offset(0, -3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Running Total ($count items):',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: LegoTheme.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: LegoTheme.green,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isCheckingOut ? null : _handleCheckout,
                          child: _isCheckingOut
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Snap & Checkout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
