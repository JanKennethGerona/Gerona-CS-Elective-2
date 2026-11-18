import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/auth_providers.dart';
import '../providers/cart_provider.dart';
import '../utils/lego_theme.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
  });

  String _resolveImageUrl(String url) {
    if (kIsWeb && (url.startsWith('http://') || url.startsWith('https://'))) {
      if (!url.contains('images.weserv.nl')) {
        return 'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}&w=400';
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCD7CC), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Studs simulation on the card header
          Container(
            height: 6,
            decoration: const BoxDecoration(
              color: LegoTheme.red,
              borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
            ),
          ),

          // Product Image Banner
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: Colors.white,
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.network(
                          _resolveImageUrl(product.imageUrl!),
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: LegoTheme.red,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFF6F4EE),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.extension_rounded,
                                    size: 32,
                                    color: LegoTheme.red,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'LEGO',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFF6F4EE),
                          child: const Center(
                            child: Icon(
                              Icons.extension_rounded,
                              size: 36,
                              color: LegoTheme.red,
                            ),
                          ),
                        ),
                ),
                // Price Tag (LEGO Yellow Brick Badge)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: LegoTheme.yellow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black87, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: LegoTheme.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content info (compact & non-overflowing)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Name
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: LegoTheme.black,
                  ),
                ),
                const SizedBox(height: 2),

                // Category & Description
                Text(
                  product.categoryName != null && product.categoryName!.isNotEmpty
                      ? '[${product.categoryName}] ${product.description ?? ''}'
                      : (product.description ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // Controls row: Admin shows Edit/Delete; Customer shows Add to Cart
                if (isAdmin)
                  Row(
                    children: [
                      // Stock pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.stock > 0
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: product.stock > 0
                                ? LegoTheme.green
                                : LegoTheme.red,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          product.stock > 0 ? '${product.stock} bricks' : 'Out of stock',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: product.stock > 0
                                ? LegoTheme.green
                                : LegoTheme.red,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Edit button
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.edit, size: 16, color: LegoTheme.blue),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Delete button
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.delete, size: 16, color: LegoTheme.red),
                        ),
                      ),
                    ],
                  )
                else
                  // Customer: Stock + Add to Cart Button
                  Row(
                    children: [
                      // Stock status
                      Text(
                        product.stock > 0 ? '${product.stock} left' : 'Out of stock',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: product.stock > 0 ? LegoTheme.green : LegoTheme.red,
                        ),
                      ),
                      const Spacer(),
                      // Add to Cart Button
                      SizedBox(
                        height: 28,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: product.stock > 0
                                ? LegoTheme.blue
                                : Colors.grey.shade400,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: product.stock > 0
                              ? () {
                                  final ok = ref
                                      .read(cartProvider.notifier)
                                      .addToCart(product);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  if (ok) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Added "${product.name}" to cart!'),
                                        duration: const Duration(seconds: 1),
                                        backgroundColor: LegoTheme.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Cannot add more: stock limit reached!'),
                                        duration: Duration(seconds: 2),
                                        backgroundColor: LegoTheme.red,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.add_shopping_cart, size: 14),
                          label: const Text(
                            'Add',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
