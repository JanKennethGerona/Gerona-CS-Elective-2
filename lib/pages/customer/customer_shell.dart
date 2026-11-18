import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../../providers/category_providers.dart';
import '../../providers/product_providers.dart';
import '../../utils/lego_theme.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/pagination_controls.dart';
import '../../widgets/price_filter_slider.dart';
import '../../widgets/product_card.dart';
import 'cart_page.dart';
import 'customer_account_page.dart';
import 'order_history_page.dart';

class CustomerShell extends ConsumerStatefulWidget {
  const CustomerShell({super.key});

  @override
  ConsumerState<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends ConsumerState<CustomerShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartProvider.notifier).itemCount;

    final pages = [
      const _CustomerProductsTab(),
      CartPage(
        onContinueShopping: () => setState(() => _currentIndex = 0),
        onViewOrders: () => setState(() => _currentIndex = 2),
      ),
      OrderHistoryPage(
        onContinueShopping: () => setState(() => _currentIndex = 0),
      ),
      const CustomerAccountPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFDCD7CC), width: 2)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          indicatorColor: LegoTheme.yellow,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'Shop',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                backgroundColor: LegoTheme.red,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                backgroundColor: LegoTheme.red,
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerProductsTab extends ConsumerStatefulWidget {
  const _CustomerProductsTab();

  @override
  ConsumerState<_CustomerProductsTab> createState() =>
      _CustomerProductsTabState();
}

class _CustomerProductsTabState extends ConsumerState<_CustomerProductsTab> {
  final _searchController = TextEditingController();
  bool _showFilter = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final filter = ref.watch(productFilterProvider);

    return Scaffold(
      backgroundColor: LegoTheme.plateBg,
      appBar: AppBar(
        backgroundColor: LegoTheme.red,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: LegoTheme.red,
                border: Border.all(color: LegoTheme.yellow, width: 2),
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, offset: Offset(1, 1)),
                ],
              ),
              child: const Text(
                'BRICKED',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Catalog',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: LegoTheme.yellow,
            ),
            tooltip: 'Toggle Filter',
            onPressed: () => setState(() => _showFilter = !_showFilter),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Reload',
            onPressed: () => ref.invalidate(productsProvider),
          ),
        ],
      ),
      bottomNavigationBar: const PaginationControls(),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: LegoStudPainter()),
          ),
          Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(productFilterProvider.notifier).setSearchQuery(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search bricks by name...',
                    prefixIcon: const Icon(Icons.search, color: LegoTheme.blue),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(productFilterProvider.notifier)
                                  .setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFDCD7CC)),
                    ),
                  ),
                ),
              ),

              // Category chips selector
              categoriesAsync.maybeWhen(
                data: (cats) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All Categories'),
                          selected: filter.categoryId == null,
                          onSelected: (_) => ref
                              .read(productFilterProvider.notifier)
                              .setCategory(null),
                        ),
                        const SizedBox(width: 6),
                        ...cats.map((c) {
                          final isSel = filter.categoryId == c.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(c.name),
                              selected: isSel,
                              selectedColor: LegoTheme.yellow,
                              onSelected: (_) {
                                ref
                                    .read(productFilterProvider.notifier)
                                    .setCategory(isSel ? null : c.id);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),

              // Collapsible Price filter slider (preserves previous activity requirement)
              if (_showFilter) const PriceFilterSlider(),

              // Product Grid (Customer view: Add to Cart button on cards, no add/edit/delete)
              Expanded(
                child: AsyncValueView(
                  value: productsAsync,
                  emptyMessage: 'No LEGO bricks match your filters.',
                  isEmpty: (p) => p.products.isEmpty,
                  onRetry: () => ref.invalidate(productsProvider),
                  data: (p) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2;
                        if (constraints.maxWidth > 900) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth > 600) {
                          crossAxisCount = 3;
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: p.products.length,
                          itemBuilder: (context, index) {
                            final prod = p.products[index];
                            return ProductCard(product: prod);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
