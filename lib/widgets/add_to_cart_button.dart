import 'package:flutter/material.dart';

/// StatefulWidget: Add to Cart button with interactive state.
/// Justification: Manages local animated confirmation feedback ('Added!' with checkmark)
/// immediately after the user taps, demonstrating clear user interaction state change.
class AddToCartButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const AddToCartButton({
    super.key,
    required this.onPressed,
    this.text = 'Add to Cart',
  });

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  bool _isAdded = false;

  void _handlePress() {
    if (_isAdded) return;

    widget.onPressed();

    setState(() {
      _isAdded = true;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _isAdded = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        key: const Key('add_to_cart_elevated_button'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isAdded
              ? theme.colorScheme.tertiary
              : theme.colorScheme.secondary,
          foregroundColor: _isAdded ? Colors.white : theme.colorScheme.onSecondary,
          elevation: _isAdded ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _handlePress,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isAdded
              ? const Row(
                  key: ValueKey('added_state'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Added to Cart!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('idle_state'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_shopping_cart_rounded, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      widget.text,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
