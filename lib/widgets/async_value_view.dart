import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/lego_theme.dart';

class AsyncValueView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final String? emptyMessage;
  final bool Function(T data)? isEmpty;

  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.emptyMessage,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (d) {
        if (isEmpty != null && isEmpty!(d)) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.widgets_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    emptyMessage ?? 'No bricks found.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return data(d);
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: LegoTheme.red,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Snapping bricks together...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (e, st) {
        final errText = e.toString();
        final isPermissionDenied = errText.contains('42501') ||
            errText.toLowerCase().contains('permission denied');

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPermissionDenied
                      ? Icons.lock_outline
                      : Icons.error_outline,
                  size: 48,
                  color: LegoTheme.red,
                ),
                const SizedBox(height: 12),
                Text(
                  isPermissionDenied
                      ? 'Access Restricted by Row-Level Security'
                      : 'Brick Assembly Error',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: LegoTheme.red,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  errText,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: LegoTheme.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
