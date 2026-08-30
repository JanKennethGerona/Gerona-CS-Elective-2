import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/ui_style.dart';

/// A single adaptive switch widget.
///
/// Renders [Switch] on Material platforms and
/// [CupertinoSwitch] on Cupertino platforms.
class AdaptiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AdaptiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final style = resolveUiStyle();

    if (style == UiStyle.cupertino) {
      return CupertinoSwitch(value: value, onChanged: onChanged);
    }

    return Switch(value: value, onChanged: onChanged);
  }
}
