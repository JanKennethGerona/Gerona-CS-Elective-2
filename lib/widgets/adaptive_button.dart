import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/ui_style.dart';

/// A single adaptive button widget.
///
/// Renders [ElevatedButton] on Material platforms and
/// [CupertinoButton.filled] on Cupertino platforms.
class AdaptiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AdaptiveButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final style = resolveUiStyle();

    if (style == UiStyle.cupertino) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        child: Text(label),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
