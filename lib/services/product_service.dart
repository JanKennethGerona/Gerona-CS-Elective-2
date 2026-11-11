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
      : _client = client ?? _getSupabaseClient();

  static SupabaseClient? _getSupabaseClient() {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get isConnectedToSupabase =>
      _client != null && SupabaseConfig.isConfigured;

  // Authentic LEGO Sets & Bricks fallback / demo data (using official Brickset set photo CDN)
  final List<Product> _mockProducts = [
    const Product(
      id: 1,
      name: 'LEGO Star Wars Millennium Falcon',
      description: '7,541 pieces. Features quad laser cannons, landing legs, and lowering ramp.',
      price: 849.99,
      stock: 5,
      imageUrl: 'https://images.brickset.com/sets/images/75192-1.jpg',
    ),
    const Product(
      id: 2,
      name: 'LEGO Icons Bonsai Tree',
      description: '878 pieces. Interchangeable green leaves and vibrant pink cherry blossom blooms.',
      price: 49.99,
      stock: 28,
      imageUrl: 'https://images.brickset.com/sets/images/10281-1.jpg',
    ),
    const Product(
      id: 3,
      name: 'LEGO Technic Porsche 911 GT3 RS',
      description: '2,704 pieces. Authentic orange bodywork, red suspension springs, and working gearbox.',
      price: 299.99,
      stock: 8,
      imageUrl: 'https://images.brickset.com/sets/images/42056-1.jpg',
    ),
    const Product(
      id: 4,
      name: 'LEGO NASA Apollo Saturn V',
      description: '1,969 pieces. Meter-high rocket model with 3 removable stages and lunar lander.',
      price: 119.99,
      stock: 14,
      imageUrl: 'https://images.brickset.com/sets/images/92176-1.jpg',
    ),
    const Product(
      id: 5,
      name: 'LEGO Creator Medieval Castle',
      description: '1,426 pieces. 3-in-1 set builds a Castle, Tower with catapult, or Medieval market.',
      price: 99.99,
      stock: 20,
      imageUrl: 'https://images.brickset.com/sets/images/31120-1.jpg',
    ),
    const Product(
      id: 6,
      name: 'LEGO Ideas Fender Stratocaster',
      description: '1,074 pieces. Build your own 1970s Stratocaster guitar with 65 Princeton Reverb amp.',
      price: 119.00,
      stock: 15,
      imageUrl: 'https://images.brickset.com/sets/images/21329-1.jpg',
    ),
    const Product(
      id: 7,
      name: 'LEGO Classic Creative Brick Box',
      description: '790 pieces in 33 different colors, including windows, doors, and wheels.',
      price: 59.99,
      stock: 35,
      imageUrl: 'https://images.brickset.com/sets/images/10698-1.jpg',
    ),
    const Product(
      id: 8,
      name: 'LEGO Harry Potter Hogwarts Castle',
      description: '6,020 pieces. Detailed microscale model featuring towers, turrets, and classrooms.',
      price: 469.99,
      stock: 6,
      imageUrl: 'https://images.brickset.com/sets/images/71043-1.jpg',
    ),
    const Product(
      id: 9,
      name: 'LEGO Speed Champions Ferrari F8 Tributo',
      description: '275 pieces. Authentic supercar replica with driver minifigure in racing suit.',
      price: 26.99,
      stock: 45,
      imageUrl: 'https://images.brickset.com/sets/images/76895-1.jpg',
    ),
    const Product(
      id: 10,
      name: 'LEGO City Space Mars Shuttle',
      description: '273 pieces. Research shuttle with opening cockpit, 2 cargo doors, and rover.',
      price: 39.99,
      stock: 30,
      imageUrl: 'https://images.brickset.com/sets/images/60226-1.jpg',
    ),
    const Product(
      id: 11,
      name: 'LEGO Botanical Wildflower Bouquet',
      description: '939 pieces. 16 individual stems crafted from plant-based plastic elements.',
      price: 59.99,
      stock: 22,
      imageUrl: 'https://images.brickset.com/sets/images/10313-1.jpg',
    ),
    const Product(
      id: 12,
      name: 'LEGO Architecture London Skyline',
      description: '468 pieces. Features National Gallery, Nelson Column, London Eye, and Big Ben.',
      price: 39.99,
      stock: 25,
      imageUrl: 'https://images.brickset.com/sets/images/21034-1.jpg',
    ),
    const Product(
      id: 13,
      name: 'LEGO Marvel Infinity Gauntlet',
      description: '590 pieces. Golden gauntlet with vibrant Infinity Stones and sturdy display stand.',
      price: 79.99,
      stock: 18,
      imageUrl: 'https://images.brickset.com/sets/images/76191-1.jpg',
    ),
    const Product(
      id: 14,
      name: 'LEGO Minifigures Series 24',
      description: '1 mystery collectible minifigure with accessories and collector leaflet.',
      price: 4.99,
      stock: 120,
      imageUrl: 'https://images.brickset.com/sets/images/71037-0.jpg',
    ),
    const Product(
      id: 15,
      name: 'LEGO Super Mario Starter Course',
      description: '231 pieces. Interactive Mario figure with LCD screens and speaker.',
      price: 59.99,
      stock: 20,
      imageUrl: 'https://images.brickset.com/sets/images/71360-1.jpg',
    ),
    const Product(
      id: 16,
      name: 'LEGO Disney Ariel Underwater Palace',
      description: '498 pieces. Underwater palace with slide, furniture, and Ariel dolphin chariot.',
      price: 39.99,
      stock: 24,
      imageUrl: 'https://images.brickset.com/sets/images/43207-1.jpg',
    ),
  ];

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
