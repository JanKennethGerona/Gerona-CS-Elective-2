import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/category_providers.dart';
import '../../providers/product_providers.dart';
import '../../utils/lego_theme.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/pagination_controls.dart';
import '../../widgets/price_filter_slider.dart';
import '../../widgets/product_card.dart';
import 'admin_categories_page.dart';
import 'admin_orders_page.dart';
import 'product_form_page.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _AdminProductsTab(),
      const AdminCategoriesPage(),
      const AdminOrdersPage(),
      const _AdminAccountTab(),
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Products',
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined),
              selectedIcon: Icon(Icons.category),
              label: 'Categories',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: 'Admin',
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminProductsTab extends ConsumerStatefulWidget {
  const _AdminProductsTab();

  @override
  ConsumerState<_AdminProductsTab> createState() => _AdminProductsTabState();
}

class _AdminProductsTabState extends ConsumerState<_AdminProductsTab> {
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: LegoTheme.yellow,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: LegoTheme.black,
                ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: LegoTheme.yellow,
        foregroundColor: LegoTheme.black,
        tooltip: 'Add Product Form',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormPage()),
          );
        },
        child: const Icon(Icons.add),
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
                    hintText: 'Search products by name...',
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

              // Collapsible Price filter slider
              if (_showFilter) const PriceFilterSlider(),

              // Product Grid
              Expanded(
                child: AsyncValueView(
                  value: productsAsync,
                  emptyMessage: 'No products found. Tap + to assemble one!',
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
                            return ProductCard(
                              product: prod,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductFormPage(productToEdit: prod),
                                  ),
                                );
                              },
                              onDelete: () async {
                                final ok = await showConfirmDeleteDialog(
                                  context: context,
                                  itemName: prod.name,
                                  itemType: 'product',
                                );
                                if (ok == true) {
                                  try {
                                    final service =
                                        ref.read(supabaseServiceProvider);
                                    await service.deleteProduct(prod.id);
                                    ref.invalidate(productsProvider);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Dismantled "${prod.name}"'),
                                          backgroundColor: LegoTheme.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Delete failed: $e'),
                                          backgroundColor: LegoTheme.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            );
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

class _AdminAccountTab extends ConsumerWidget {
  const _AdminAccountTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: LegoTheme.red,
        title: const Text(
          'Admin Account',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: AsyncValueView(
        value: profileAsync,
        data: (profile) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: LegoTheme.yellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: LegoTheme.red, width: 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (profile?.firstname.isNotEmpty == true)
                          ? profile!.firstname[0].toUpperCase()
                          : (user?.email?.isNotEmpty == true
                              ? user!.email![0].toUpperCase()
                              : 'A'),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: LegoTheme.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    profile?.displayName ?? 'Admin User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    user?.email ?? '',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: LegoTheme.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ROLE: ADMIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Spacer(),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: LegoTheme.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => ref.read(supabaseServiceProvider).signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
