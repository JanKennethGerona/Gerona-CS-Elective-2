import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class PaginationControls extends StatelessWidget {
  const PaginationControls({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final theme = Theme.of(context);

    if (provider.totalCount == 0) {
      return const SizedBox.shrink();
    }

    final startItem = ((provider.currentPage - 1) * provider.pageSize) + 1;
    final endItem = (provider.currentPage * provider.pageSize) > provider.totalCount
        ? provider.totalCount
        : (provider.currentPage * provider.pageSize);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Showing items info & Page Size Switcher (6 or 8)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing $startItem–$endItem of ${provider.totalCount} products',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Page Size Switcher (Show 6 or 8 products per page)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Per page: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _PageSizeChoice(
                      size: 6,
                      isSelected: provider.pageSize == 6,
                      onTap: () => provider.setPageSize(6),
                    ),
                    const SizedBox(width: 4),
                    _PageSizeChoice(
                      size: 8,
                      isSelected: provider.pageSize == 8,
                      onTap: () => provider.setPageSize(8),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Bottom Row: Navigation buttons (Prev, Page 1..N, Next)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous button
                IconButton.filledTonal(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  tooltip: 'Previous Page',
                  onPressed: provider.hasPrevPage && !provider.isLoading
                      ? () => provider.previousPage()
                      : null,
                ),
                const SizedBox(width: 8),

                // Page Number Buttons
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(provider.totalPages, (index) {
                        final page = index + 1;
                        final isCurrent = page == provider.currentPage;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            onTap: provider.isLoading || isCurrent
                                ? null
                                : () => provider.goToPage(page),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isCurrent
                                      ? theme.colorScheme.primary
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                '$page',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isCurrent
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                // Next button
                IconButton.filledTonal(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  tooltip: 'Next Page',
                  onPressed: provider.hasNextPage && !provider.isLoading
                      ? () => provider.nextPage()
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PageSizeChoice extends StatelessWidget {
  final int size;
  final bool isSelected;
  final VoidCallback onTap;

  const _PageSizeChoice({
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$size',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
