import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../utils/lego_theme.dart';

class PaginationControls extends StatelessWidget {
  const PaginationControls({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    if (provider.totalCount == 0) {
      return const SizedBox.shrink();
    }

    final startItem = ((provider.currentPage - 1) * provider.pageSize) + 1;
    final endItem = (provider.currentPage * provider.pageSize) > provider.totalCount
        ? provider.totalCount
        : (provider.currentPage * provider.pageSize);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDCD7CC), width: 2.5)),
        boxShadow: [
          BoxShadow(
            color: Color(0x15000000),
            offset: Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Showing items info & Page Size Selector
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Showing $startItem–$endItem of ${provider.totalCount} items',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: LegoTheme.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Per plate: ',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _LegoPageSizeChoice(
                      size: 6,
                      isSelected: provider.pageSize == 6,
                      onTap: () => provider.setPageSize(6),
                    ),
                    const SizedBox(width: 4),
                    _LegoPageSizeChoice(
                      size: 8,
                      isSelected: provider.pageSize == 8,
                      onTap: () => provider.setPageSize(8),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Bottom Row: Navigation buttons (Previous, Page Numbers, Next)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous button
                SizedBox(
                  width: 32,
                  height: 32,
                  child: InkWell(
                    onTap: provider.hasPrevPage && !provider.isLoading
                        ? () => provider.previousPage()
                        : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: provider.hasPrevPage ? LegoTheme.red : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: provider.hasPrevPage ? Colors.black26 : Colors.transparent,
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        size: 20,
                        color: provider.hasPrevPage ? Colors.white : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Page Number Buttons (LEGO bricks style)
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(provider.totalPages, (index) {
                        final page = index + 1;
                        final isCurrent = page == provider.currentPage;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InkWell(
                            onTap: provider.isLoading || isCurrent
                                ? null
                                : () => provider.goToPage(page),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isCurrent ? LegoTheme.blue : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isCurrent ? Colors.black38 : const Color(0xFFDCD7CC),
                                  width: 2,
                                ),
                                boxShadow: isCurrent
                                    ? const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Text(
                                '$page',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: isCurrent ? Colors.white : LegoTheme.black,
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
                SizedBox(
                  width: 32,
                  height: 32,
                  child: InkWell(
                    onTap: provider.hasNextPage && !provider.isLoading
                        ? () => provider.nextPage()
                        : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: provider.hasNextPage ? LegoTheme.red : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: provider.hasNextPage ? Colors.black26 : Colors.transparent,
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: provider.hasNextPage ? Colors.white : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegoPageSizeChoice extends StatelessWidget {
  final int size;
  final bool isSelected;
  final VoidCallback onTap;

  const _LegoPageSizeChoice({
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? LegoTheme.red : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected ? Colors.black26 : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          '$size',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
