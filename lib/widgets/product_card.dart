import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../utils/lego_theme.dart';
import 'product_form_dialog.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(productToEdit: product),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: LegoTheme.red, width: 3),
        ),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: LegoTheme.red),
            SizedBox(width: 8),
            Text('Disassemble Brick?', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text('Are you sure you want to remove "${product.name}" from your catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: LegoTheme.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final success = await context.read<ProductProvider>().deleteProduct(product.id);
              if (success) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Removed "${product.name}"'),
                    backgroundColor: LegoTheme.green,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  color: const Color(0xFFF6F4EE),
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(
                              Icons.widgets_outlined,
                              size: 38,
                              color: Color(0xFFC7C2B6),
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.widgets_outlined,
                            size: 38,
                            color: Color(0xFFC7C2B6),
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
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: LegoTheme.black,
                  ),
                ),
                const SizedBox(height: 2),

                // Description
                Text(
                  product.description.isEmpty
                      ? 'Custom LEGO brick item'
                      : product.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),

                // Stock Badge & Actions Row
                Row(
                  children: [
                    // Stock badge
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.stock > 0
                              ? LegoTheme.green.withValues(alpha: 0.12)
                              : LegoTheme.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: product.stock > 0 ? LegoTheme.green : LegoTheme.red,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          product.stock > 0
                              ? '${product.stock} bricks'
                              : 'Out of stock',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: product.stock > 0 ? LegoTheme.green : LegoTheme.red,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Edit Button
                    InkWell(
                      onTap: () => _showEditDialog(context),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: LegoTheme.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 15,
                          color: LegoTheme.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),

                    // Delete Button
                    InkWell(
                      onTap: () => _confirmDelete(context),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: LegoTheme.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 15,
                          color: LegoTheme.red,
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
