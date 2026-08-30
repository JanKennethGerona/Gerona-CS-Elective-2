import 'package:flutter/material.dart';

/// A grid of placeholder "stat" cards.
///
/// [columnCount] controls the number of columns (2 on mobile, 4 on
/// tablet / desktop) so the layout adapts to the available width.
class StatGrid extends StatelessWidget {
  final int columnCount;

  const StatGrid({super.key, required this.columnCount});

  static const List<_StatData> _stats = [
    _StatData(title: 'Users', value: '1,248', icon: Icons.people),
    _StatData(title: 'Revenue', value: '\$8,420', icon: Icons.attach_money),
    _StatData(title: 'Orders', value: '356', icon: Icons.shopping_cart),
    _StatData(title: 'Growth', value: '+12 %', icon: Icons.trending_up),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: columnCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: _stats.map((s) => _StatCard(data: s)).toList(),
    );
  }
}

class _StatData {
  final String title;
  final String value;
  final IconData icon;
  const _StatData({
    required this.title,
    required this.value,
    required this.icon,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 20, color: Colors.blueGrey),
              const SizedBox(width: 6),
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
            ),
          ),
        ],
      ),
    );
  }
}
