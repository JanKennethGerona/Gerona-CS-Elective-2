import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_providers.dart';
import '../utils/lego_theme.dart';

class PaginationControls extends ConsumerWidget {
  const PaginationControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagAsync = ref.watch(productsProvider);
    final filter = ref.watch(productFilterProvider);

    return pagAsync.maybeWhen(
      data: (pag) {
        if (pag.totalCount == 0) return const SizedBox.shrink();

        final startItem = ((pag.currentPage - 1) * pag.pageSize) + 1;
        final endItem = (pag.currentPage * pag.pageSize) > pag.totalCount
            ? pag.totalCount
            : (pag.currentPage * pag.pageSize);

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
                        'Showing $startItem–$endItem of ${pag.totalCount} items',
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
                          isSelected: filter.pageSize == 6,
                          onTap: () => ref
                              .read(productFilterProvider.notifier)
                              .setPageSize(6),
                        ),
                        const SizedBox(width: 4),
                        _LegoPageSizeChoice(
                          size: 8,
                          isSelected: filter.pageSize == 8,
                          onTap: () => ref
                              .read(productFilterProvider.notifier)
                              .setPageSize(8),
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
                        onTap: pag.hasPrevPage
                            ? () => ref
                                .read(productFilterProvider.notifier)
                                .setPage(pag.currentPage - 1)
                            : null,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: pag.hasPrevPage ? LegoTheme.red : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: pag.hasPrevPage ? Colors.black26 : Colors.transparent,
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            size: 20,
                            color: pag.hasPrevPage ? Colors.white : Colors.grey.shade400,
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
                          children: List.generate(pag.totalPages, (index) {
                            final page = index + 1;
                            final isCurrent = page == pag.currentPage;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: InkWell(
                                onTap: isCurrent
                                    ? null
                                    : () => ref
                                        .read(productFilterProvider.notifier)
                                        .setPage(page),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isCurrent ? LegoTheme.blue : Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isCurrent
                                          ? Colors.black38
                                          : const Color(0xFFDCD7CC),
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
                                      color: isCurrent
                                          ? Colors.white
                                          : LegoTheme.black,
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
                        onTap: pag.hasNextPage
                            ? () => ref
                                .read(productFilterProvider.notifier)
                                .setPage(pag.currentPage + 1)
                            : null,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: pag.hasNextPage ? LegoTheme.red : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: pag.hasNextPage ? Colors.black26 : Colors.transparent,
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: pag.hasNextPage ? Colors.white : Colors.grey.shade400,
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
      },
      orElse: () => const SizedBox.shrink(),
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
