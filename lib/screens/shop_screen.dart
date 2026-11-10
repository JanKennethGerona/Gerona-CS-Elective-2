import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/supabase_config.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
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
        title: const Row(
          children: [
            Icon(Icons.cloud_outlined, color: Colors.blue),
            SizedBox(width: 8),
            Text('Supabase Connection'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              SupabaseConfig.isConfigured
                  ? 'Connected to your Supabase project:'
                  : 'Currently in Offline / Demo Mode:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              SupabaseConfig.isConfigured
                  ? SupabaseConfig.supabaseUrl
                  : 'To link your live database, update "lib/config/supabase_config.dart" with your Supabase Project URL and anon key.\n\nRun the included "supabase_schema.sql" in your Supabase SQL Editor to set up the products table.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          TextButton(
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supabase Shop',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(
              'Price Filtering & Pagination',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          // Connection status chip
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
              onTap: _showConfigDialog,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: provider.isConnectedToSupabase
                      ? Colors.green.shade100
                      : Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: provider.isConnectedToSupabase
                        ? Colors.green.shade400
                        : Colors.amber.shade400,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      provider.isConnectedToSupabase
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                      size: 13,
                      color: provider.isConnectedToSupabase
                          ? Colors.green.shade800
                          : Colors.amber.shade900,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      provider.isConnectedToSupabase ? 'Live DB' : 'Demo Mode',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: provider.isConnectedToSupabase
                            ? Colors.green.shade800
                            : Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _showFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showFilter ? theme.colorScheme.primary : null,
            ),
            tooltip: 'Toggle Price Filter',
            onPressed: () {
              setState(() {
                _showFilter = !_showFilter;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Product',
            onPressed: _showAddDialog,
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.isAuthenticated) {
                final userEmail = auth.currentUser?.email ?? 'User';
                return PopupMenuButton<String>(
                  icon: CircleAvatar(
                    radius: 13,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
                          const Text(
                            'Signed in as',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
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
                          Icon(Icons.logout, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Sign Out', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.account_circle_outlined),
                  tooltip: 'Sign In',
                  onPressed: () {
                    auth.signOut();
                  },
                );
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products by name...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: (val) {
                provider.setSearchQuery(val);
              },
            ),
          ),

          // Collapsible Price Filter Range Slider
          AnimatedCrossFade(
            firstChild: const PriceFilterSlider(),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _showFilter
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),

          // Main Product Area
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchProducts(),
              child: provider.isLoading && provider.products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
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
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const PaginationControls(),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _showAddDialog,
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
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
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'No Products Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
            FilledButton.tonalIcon(
              onPressed: () {
                _searchController.clear();
                provider.resetFilters();
              },
              icon: const Icon(Icons.filter_alt_off, size: 18),
              label: const Text('Reset Filter & Search'),
            ),
          ],
        ),
      ),
    );
  }
}
