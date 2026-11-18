import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_providers.dart';
import '../../providers/order_providers.dart';
import '../../utils/lego_theme.dart';
import '../../widgets/async_value_view.dart';

class AdminOrdersPage extends ConsumerWidget {
  const AdminOrdersPage({super.key});

  static const List<String> availableStatuses = [
    'pending',
    'processing',
    'done',
    'shipped',
    'delivered',
    'cancelled',
    'returned',
    'refunded',
  ];

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
        return const Color(0xFFD97706); // Amber / orange
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: LegoTheme.red,
        title: const Text(
          'Customer Orders (Admin)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.invalidate(adminOrdersProvider),
          ),
        ],
      ),
      body: AsyncValueView(
        value: ordersAsync,
        emptyMessage: 'No customer orders have been placed yet.',
        isEmpty: (orders) => orders.isEmpty,
        onRetry: () => ref.invalidate(adminOrdersProvider),
        data: (orders) {
          final dateFormat = DateFormat('MMM d, y • h:mm a');

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
                  border: Border.all(color: const Color(0xFFDCD7CC), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      offset: Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (order.userEmail != null)
                        Text(
                          'Customer: ${order.userEmail}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      Text(
                        dateFormat.format(order.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Status dropdown for Admin to update order status
                      Row(
                        children: [
                          const Text(
                            'Status: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: _statusColor(order.status).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _statusColor(order.status),
                                width: 1.5,
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: availableStatuses.contains(order.status.toLowerCase())
                                  ? order.status.toLowerCase()
                                  : 'done',
                              underline: const SizedBox.shrink(),
                              isDense: true,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: _statusColor(order.status),
                              ),
                              items: availableStatuses.map((s) {
                                return DropdownMenuItem<String>(
                                  value: s,
                                  child: Text(s.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (newStatus) async {
                                if (newStatus == null) return;
                                try {
                                  final service =
                                      ref.read(supabaseServiceProvider);
                                  await service.updateOrderStatus(
                                      order.id, newStatus);
                                  ref.invalidate(adminOrdersProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Order #${order.id} status set to ${newStatus.toUpperCase()}'),
                                        backgroundColor: LegoTheme.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to update status: $e'),
                                        backgroundColor: LegoTheme.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ],
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
                            'Snapshot Items at Checkout:',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle,
                                      size: 6, color: LegoTheme.blue),
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
