import 'package:flutter/material.dart';
import '../../utils/lego_theme.dart';

class CheckoutConfirmationPage extends StatelessWidget {
  final int orderId;
  final double total;
  final VoidCallback onContinueShopping;
  final VoidCallback onViewOrders;

  const CheckoutConfirmationPage({
    super.key,
    required this.orderId,
    required this.total,
    required this.onContinueShopping,
    required this.onViewOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LegoTheme.plateBg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: LegoStudPainter())),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: LegoTheme.green, width: 3.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        offset: Offset(0, 8),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: LegoTheme.green.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: LegoTheme.green,
                          size: 52,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Order Placed!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: LegoTheme.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your LEGO bricks are being prepared.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: LegoTheme.plateBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFDCD7CC)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Order Number:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '#$orderId',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: LegoTheme.blue,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Paid:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '\$${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    color: LegoTheme.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: LegoTheme.blue,
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onViewOrders,
                        icon: const Icon(Icons.receipt_long),
                        label: const Text(
                          'View My Orders',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          side: const BorderSide(color: LegoTheme.black, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onContinueShopping,
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text(
                          'Continue Shopping',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: LegoTheme.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
