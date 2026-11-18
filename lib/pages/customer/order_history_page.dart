import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/order_providers.dart';
import '../../utils/lego_theme.dart';
import '../../widgets/async_value_view.dart';

class OrderHistoryPage extends ConsumerWidget {
  final VoidCallback onContinueShopping;

  const OrderHistoryPage({super.key, required this.onContinueShopping});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
      case 'delivered':
        return LegoTheme.green;
      case 'shipped':
      case 'processing':
        return LegoTheme.blue;
      case 'cancelled':
      case 'returned':
      case 'refunded':
        return LegoTheme.red;
      default:
        return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerOrdersProvider);
    final dateFormat = DateFormat('MMM d, y • h:mm a');

    return Scaffold(
      backgroundColor: LegoTheme.plateBg,
      appBar: AppBar(
        backgroundColor: LegoTheme.red,
        title: const Text(
          'My Order History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.invalidate(customerOrdersProvider),
          ),
        ],
      ),
      body: AsyncValueView(
        value: ordersAsync,
        emptyMessage: 'You haven\'t placed any orders yet.',
        isEmpty: (orders) => orders.isEmpty,
        onRetry: () => ref.invalidate(customerOrdersProvider),
        data: (orders) {
          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: orders.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDCD7CC), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: LegoTheme.yellow,
                    foregroundColor: LegoTheme.black,
                    child: const Icon(Icons.shopping_bag_outlined, size: 20),
                  ),
                  title: Row(
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: LegoTheme.red,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        dateFormat.format(order.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _statusColor(order.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _statusColor(order.status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: _statusColor(order.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Snapshot Items:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle,
                                      size: 5, color: LegoTheme.blue),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}x @ \$${item.unitPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${item.subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
