import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/supabase_config.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../utils/lego_theme.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/price_filter_slider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilter = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => const ProductFormDialog(),
    );
  }

  void _showConfigDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: LegoTheme.red, width: 3),
        ),
        title: const Row(
          children: [
            Icon(Icons.widgets, color: LegoTheme.red),
            SizedBox(width: 8),
            Text('BRICKED Database', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              SupabaseConfig.isConfigured
                  ? 'Connected to Live Supabase Project:'
                  : 'Currently in Demo Mode:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              SupabaseConfig.isConfigured
                  ? SupabaseConfig.supabaseUrl
                  : 'Configure lib/config/supabase_config.dart to connect.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: LegoTheme.red),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: LegoTheme.plateBg,
      appBar: AppBar(
        backgroundColor: LegoTheme.red,
        elevation: 3,
        title: Row(
          children: [
            // BRICKED Badge Logo in AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: LegoTheme.red,
                border: Border.all(color: LegoTheme.yellow, width: 2),
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: const Text(
                'BRICKED',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(color: Colors.black, offset: Offset(1, 1)),
                    Shadow(color: LegoTheme.yellow, offset: Offset(-0.5, -0.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Shop Catalog',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          // Database status indicator (Green/Yellow brick pill)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: InkWell(
              onTap: _showConfigDialog,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: provider.isConnectedToSupabase
                      ? LegoTheme.green
                      : LegoTheme.yellow,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      provider.isConnectedToSupabase ? Icons.cloud_done : Icons.cloud_off,
                      size: 13,
                      color: provider.isConnectedToSupabase ? Colors.white : LegoTheme.black,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      provider.isConnectedToSupabase ? 'LIVE' : 'DEMO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: provider.isConnectedToSupabase ? Colors.white : LegoTheme.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Filter toggle button
          IconButton(
            icon: Icon(
              _showFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: LegoTheme.yellow,
            ),
            tooltip: 'Toggle Filter',
            onPressed: () => setState(() => _showFilter = !_showFilter),
          ),
          // Add product button
          IconButton(
            icon: const Icon(Icons.add_circle, color: LegoTheme.yellow),
            tooltip: 'Add Brick',
            onPressed: _showAddDialog,
          ),
          // User / Logout Avatar
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final userEmail = auth.currentUser?.email ?? 'Builder';
              return PopupMenuButton<String>(
                icon: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: LegoTheme.yellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'B',
                    style: const TextStyle(
                      color: LegoTheme.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                tooltip: 'Account',
                onSelected: (val) {
                  if (val == 'logout') {
                    auth.signOut();
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Signed in as', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18, color: LegoTheme.red),
                        SizedBox(width: 8),
                        Text('Sign Out', style: TextStyle(color: LegoTheme.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // Subtle LEGO studs baseplate background
          Positioned.fill(
            child: CustomPaint(
              painter: LegoStudPainter(spacing: 34, radius: 4.5),
            ),
          ),

          Column(
            children: [
              // LEGO Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDCD7CC), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search bricks by name...',
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, size: 20, color: LegoTheme.blue),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                provider.setSearchQuery('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                    onChanged: (val) => provider.setSearchQuery(val),
                  ),
                ),
              ),

              // Collapsible LEGO Price Range Filter Slider
              AnimatedCrossFade(
                firstChild: const PriceFilterSlider(),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _showFilter
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 200),
              ),

              // Main Products Grid
              Expanded(
                child: RefreshIndicator(
                  color: LegoTheme.red,
                  onRefresh: () => provider.fetchProducts(),
                  child: provider.isLoading && provider.products.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: LegoTheme.red))
                      : provider.products.isEmpty
                          ? _buildEmptyState(provider)
                          : Stack(
                              children: [
                                GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.70,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemCount: provider.products.length,
                                  itemBuilder: (context, index) {
                                    final product = provider.products[index];
                                    return ProductCard(product: product);
                                  },
                                ),
                                if (provider.isLoading)
                                  Positioned(
                                    top: 8,
                                    right: 16,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                          )
                                        ],
                                      ),
                                      child: const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: LegoTheme.red,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const PaginationControls(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: LegoTheme.red,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: _showAddDialog,
        tooltip: 'Add Brick',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildEmptyState(ProductProvider provider) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.view_in_ar_rounded,
              size: 56,
              color: Color(0xFFC7C2B6),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Bricks Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: LegoTheme.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No products match your current price filter or search query.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: LegoTheme.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                _searchController.clear();
                provider.resetFilters();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset Filter & Search', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
