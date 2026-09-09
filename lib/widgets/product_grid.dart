import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_card.dart';

/// Stateless Widget: Responsive product grid.
/// Uses LayoutBuilder to determine column count based on available width:
/// - Phone (< 600 dp): 2 columns
/// - Tablet (600 - 950 dp): 3 columns
/// - Desktop / Large Tablet (>= 950 dp): 4 columns
class ProductGrid extends StatelessWidget {
  final List<Product> products;

  const ProductGrid({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount;

        if (width >= 950) {
          crossAxisCount = 4;
        } else if (width >= 600) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        // Adjust child aspect ratio based on column count and width
        final childAspectRatio = width < 400 ? 0.68 : 0.74;

        return GridView.builder(
          key: const Key('product_grid_view'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(product: products[index]);
          },
        );
      },
    );
  }
}
