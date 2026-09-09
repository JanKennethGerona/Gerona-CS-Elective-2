import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../state/cart_model.dart';
import 'product_image.dart';
import 'quantity_selector.dart';

/// Stateless Widget: Displays a single item row in the shopping cart.
/// Renders product info, uses QuantitySelector for interactive adjustments,
/// and reflects subtotal.
class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartModel = context.read<CartModel>();

    return Card(
      key: Key('cart_item_${item.product.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      elevation: 1.5,
      shape: theme.cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 76,
                height: 76,
                child: ProductImage(
                  imageUrl: item.product.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#${item.product.setNumber} • \$${item.product.price.toStringAsFixed(2)} each',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withAlpha(160),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Stateful Quantity Control
                      QuantitySelector(
                        initialQuantity: item.quantity,
                        onQuantityChanged: (newQty) {
                          if (newQty <= 0) {
                            cartModel.removeItem(item.product.id);
                          } else {
                            cartModel.setQuantity(item.product.id, newQty);
                          }
                        },
                      ),
                      // Subtotal for this item
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Subtotal',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withAlpha(140),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$${item.subtotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
