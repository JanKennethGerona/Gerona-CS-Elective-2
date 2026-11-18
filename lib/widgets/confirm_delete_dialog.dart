import 'package:flutter/material.dart';
import '../utils/lego_theme.dart';

Future<bool?> showConfirmDeleteDialog({
  required BuildContext context,
  required String itemName,
  String itemType = 'product',
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: LegoTheme.red, width: 2.5),
      ),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: LegoTheme.red, size: 26),
          SizedBox(width: 8),
          Text(
            'Confirm Dismantle',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to delete the $itemType "$itemName"? This operation cannot be undone.',
        style: const TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: LegoTheme.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
