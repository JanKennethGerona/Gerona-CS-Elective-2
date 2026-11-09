import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/product.dart';

class ProductsResult {
  final List<Product> products;
  final int totalCount;

  const ProductsResult({
    required this.products,
    required this.totalCount,
  });
}

class ProductService {
  final SupabaseClient? _client;

  ProductService({SupabaseClient? client})
      : _client = client ??
            (SupabaseConfig.isConfigured
                ? Supabase.instance.client
                : null);

  bool get isConnectedToSupabase =>
      _client != null && SupabaseConfig.isConfigured;

  // In-memory demo products for fallback / initial showcase before DB config
  final List<Product> _mockProducts = [
    const Product(
      id: 1,
      name: 'Wireless Noise-Canceling Headphones',
      description: 'Premium over-ear headphones with 30-hour battery life.',
      price: 120.00,
      stock: 15,
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500',
    ),
    const Product(
      id: 2,
      name: 'Mechanical Gaming Keyboard',
      description: 'RGB backlit mechanical keyboard with tactile blue switches.',
      price: 85.00,
      stock: 20,
      imageUrl:
          'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500',
    ),
    const Product(
      id: 3,
      name: 'Ergonomic Optical Gaming Mouse',
      description: '16,000 DPI adjustable optical gaming mouse with programmable keys.',
      price: 45.00,
      stock: 32,
      imageUrl:
          'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=500',
    ),
    const Product(
      id: 4,
      name: 'UltraWide Curved Monitor 34"',
      description: 'Immersive 144Hz WQHD curved gaming and productivity display.',
      price: 349.99,
      stock: 8,
      imageUrl:
          'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=500',
    ),
    const Product(
      id: 5,
      name: 'USB-C Dual 4K Docking Station',
      description: '11-in-1 multi-port docking station with 100W Power Delivery.',
      price: 64.99,
      stock: 25,
      imageUrl:
          'https://images.unsplash.com/photo-1544652478-6653e09f18a2?w=500',
    ),
    const Product(
      id: 6,
      name: 'Fitness Smartwatch Tracker',
      description: 'AMOLED display smartwatch with heart rate and SpO2 tracking.',
      price: 95.00,
      stock: 18,
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500',
    ),
    const Product(
      id: 7,
      name: 'Waterproof Bluetooth Speaker',
      description: 'Rugged 360-degree portable speaker with deep bass and IPX7 rating.',
      price: 55.00,
      stock: 22,
      imageUrl:
          'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500',
    ),
    const Product(
      id: 8,
      name: 'Ergonomic Mesh Office Chair',
      description: 'High-back desk chair with breathable mesh and lumbar support.',
      price: 189.00,
      stock: 10,
      imageUrl:
          'https://images.unsplash.com/photo-1580481077195-c228c3b74b35?w=500',
    ),
    const Product(
      id: 9,
      name: '4K Ultra HD Streaming Webcam',
      description: 'Auto-focus webcam with dual noise-canceling microphones.',
      price: 74.50,
      stock: 14,
      imageUrl:
          'https://images.unsplash.com/photo-1587826080692-f439cd0b70da?w=500',
    ),
    const Product(
      id: 10,
      name: 'Extended Leather Desk Pad',
      description: 'Waterproof PU leather large mousepad and blotter for desks.',
      price: 24.99,
      stock: 50,
      imageUrl:
          'https://images.unsplash.com/photo-1616440347437-b1c73416efc2?w=500',
    ),
    const Product(
      id: 11,
      name: 'Adjustable Aluminum Phone Stand',
      description: 'Multi-angle foldable cradle compatible with smartphones and tablets.',
      price: 18.00,
      stock: 40,
      imageUrl:
          'https://images.unsplash.com/photo-1586105251261-72a756497a11?w=500',
    ),
    const Product(
      id: 12,
      name: 'Portable High-Speed SSD 1TB',
      description: 'Ultra-fast NVMe solid state drive with up to 1050MB/s speeds.',
      price: 109.99,
      stock: 12,
      imageUrl:
          'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=500',
    ),
    const Product(
      id: 13,
      name: 'Studio Condenser USB Microphone',
      description: 'Cardioid studio mic with zero-latency headphone monitoring.',
      price: 89.00,
      stock: 16,
      imageUrl:
          'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=500',
    ),
    const Product(
      id: 14,
      name: 'Shockproof Laptop Sleeve 15.6"',
      description: 'Water-resistant protective notebook case with accessory pocket.',
      price: 28.50,
      stock: 35,
      imageUrl:
          'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=500',
    ),
    const Product(
      id: 15,
      name: '3-in-1 Fast Wireless Charging Station',
      description: 'Simultaneous Qi charger for phone, watch, and wireless earbuds.',
      price: 39.99,
      stock: 28,
      imageUrl:
          'https://images.unsplash.com/photo-1622445262464-84b1456045b6?w=500',
    ),
    const Product(
      id: 16,
      name: 'Dimmable LED Desk Lamp',
      description: 'Touch-control architect lamp with 5 color modes and USB port.',
      price: 32.00,
      stock: 24,
      imageUrl:
          'https://images.unsplash.com/photo-1534073828943-f801091bb18c?w=500',
    ),
  ];

  /// Fetch products with price range filtering and pagination using Supabase queries.
  /// Matches lecture slides:
  /// - Filtering: gte('price', minPrice).lte('price', maxPrice).ilike(...)
  /// - Ordering: order('price', ascending: true)
  /// - Pagination: range(from, to)
  Future<ProductsResult> fetchProducts({
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
    int page = 1,
    int pageSize = 8,
  }) async {
    if (isConnectedToSupabase && _client != null) {
      try {
        var query = _client.from('products').select();

        // 1. Text Search Filter (.ilike)
        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          query = query.ilike('name', '%${searchQuery.trim()}%');
        }

        // 2. Range Filtering (.gte & .lte)
        if (minPrice != null) {
          query = query.gte('price', minPrice);
        }
        if (maxPrice != null) {
          query = query.lte('price', maxPrice);
        }

        // 3. Count matching items for pagination
        final countRes = await query.count(CountOption.exact);
        final totalCount = countRes.count;

        // 4. Calculate range bounds for pagination
        final from = (page - 1) * pageSize;
        final to = from + pageSize - 1;

        // 5. Apply Ordering (.order) and Pagination (.range)
        final data = await query
            .order('price', ascending: true)
            .range(from, to);

        final products = (data as List<dynamic>)
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();

        return ProductsResult(products: products, totalCount: totalCount);
      } catch (e) {
        // If Supabase table isn't ready or network issue, fallback to mock data
        return _fetchFromMock(
          minPrice: minPrice,
          maxPrice: maxPrice,
          searchQuery: searchQuery,
          page: page,
          pageSize: pageSize,
        );
      }
    }

    return _fetchFromMock(
      minPrice: minPrice,
      maxPrice: maxPrice,
      searchQuery: searchQuery,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Insert product matching slide 41:
  /// await supabase.from('products').insert(...)
  Future<Product> addProduct(Product product) async {
    if (isConnectedToSupabase && _client != null) {
      final response = await _client
          .from('products')
          .insert(product.toJson())
          .select()
          .single();
      return Product.fromJson(response);
    } else {
      final newId = (_mockProducts.map((p) => p.id as int).fold(0, (a, b) => a > b ? a : b)) + 1;
      final created = product.copyWith(id: newId, createdAt: DateTime.now());
      _mockProducts.insert(0, created);
      return created;
    }
  }

  /// Update product matching slide 43:
  /// await supabase.from('products').update(...).eq('id', product.id).select().single()
  Future<Product> updateProduct(Product product) async {
    if (isConnectedToSupabase && _client != null) {
      final response = await _client
          .from('products')
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();
      return Product.fromJson(response);
    } else {
      final index = _mockProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _mockProducts[index] = product;
      }
      return product;
    }
  }

  /// Delete product matching slide 43:
  /// await supabase.from('products').delete().eq('id', id).select()
  Future<void> deleteProduct(dynamic id) async {
    if (isConnectedToSupabase && _client != null) {
      await _client.from('products').delete().eq('id', id).select();
    } else {
      _mockProducts.removeWhere((p) => p.id == id);
    }
  }

  ProductsResult _fetchFromMock({
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
    int page = 1,
    int pageSize = 8,
  }) {
    var filtered = _mockProducts.where((p) {
      if (minPrice != null && p.price < minPrice) return false;
      if (maxPrice != null && p.price > maxPrice) return false;
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchesName = p.name.toLowerCase().contains(query);
        final matchesDesc = p.description.toLowerCase().contains(query);
        if (!matchesName && !matchesDesc) return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) => a.price.compareTo(b.price));

    final totalCount = filtered.length;
    final from = (page - 1) * pageSize;
    final to = (from + pageSize) > totalCount ? totalCount : (from + pageSize);

    final paged = (from >= totalCount)
        ? <Product>[]
        : filtered.sublist(from, to);

    return ProductsResult(products: paged, totalCount: totalCount);
  }
}
