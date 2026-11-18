import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  final SupabaseClient? _client;

  SupabaseService({SupabaseClient? client})
      : _client = client ?? _resolveClient();

  static SupabaseClient? _resolveClient() {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient? get client => _client;
  bool get isConnected => _client != null && SupabaseConfig.isConfigured;
  User? get currentUser => _client?.auth.currentUser;
  Stream<AuthState>? get authStateChanges => _client?.auth.onAuthStateChange;

  // -------------------------------------------------------------
  // AUTH
  // -------------------------------------------------------------
  Future<AuthResponse?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_client == null) return null;
    return await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse?> signUpWithEmail({
    required String email,
    required String password,
    String? firstname,
    String? lastname,
  }) async {
    if (_client == null) return null;
    return await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        if (firstname != null && firstname.trim().isNotEmpty)
          'firstname': firstname.trim(),
        if (lastname != null && lastname.trim().isNotEmpty)
          'lastname': lastname.trim(),
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    if (_client == null) return false;
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb
          ? Uri.base.origin
          : 'io.supabase.flutter://login-callback/',
    );
  }

  Future<void> signOut() async {
    if (_client != null) {
      await _client.auth.signOut();
    }
  }

  // -------------------------------------------------------------
  // PROFILES
  // -------------------------------------------------------------
  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    if (_client == null) return null;
    final res = await _client
        .from('profiles')
        .select('*, roles(role)')
        .eq('id', userId)
        .maybeSingle();
    return res;
  }

  Future<void> updateProfileName({
    required String userId,
    required String firstname,
    required String lastname,
  }) async {
    if (_client == null) return;
    await _client.from('profiles').update({
      'firstname': firstname.trim(),
      'lastname': lastname.trim(),
    }).eq('id', userId);
  }

  // -------------------------------------------------------------
  // CATEGORIES
  // -------------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    if (_client == null) return [];
    final res = await _client
        .from('categories')
        .select('*')
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<Map<String, dynamic>> createCategory(String name) async {
    if (_client == null) throw Exception('Not connected');
    final res = await _client
        .from('categories')
        .insert({'name': name.trim()})
        .select()
        .single();
    return res;
  }

  Future<void> updateCategory(int id, String name) async {
    if (_client == null) throw Exception('Not connected');
    await _client
        .from('categories')
        .update({'name': name.trim()})
        .eq('id', id);
  }

  Future<void> deleteCategory(int id) async {
    if (_client == null) throw Exception('Not connected');
    await _client.from('categories').delete().eq('id', id);
  }

  // -------------------------------------------------------------
  // PRODUCTS (Filtering, searching, pagination, CRUD)
  // -------------------------------------------------------------
  Future<({List<Map<String, dynamic>> items, int totalCount})> fetchProducts({
    String? searchQuery,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int pageSize = 8,
  }) async {
    if (_client == null) return (items: <Map<String, dynamic>>[], totalCount: 0);

    var query = _client.from('products').select('*, categories(name)');

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = query.ilike('name', '%${searchQuery.trim()}%');
    }

    if (categoryId != null && categoryId > 0) {
      query = query.eq('category_id', categoryId);
    }

    if (minPrice != null) {
      query = query.gte('price', minPrice);
    }

    if (maxPrice != null) {
      query = query.lte('price', maxPrice);
    }

    final fromIndex = (page - 1) * pageSize;
    final toIndex = fromIndex + pageSize - 1;

    final response = await query
        .order('id', ascending: true)
        .range(fromIndex, toIndex)
        .count(CountOption.exact);

    final data = List<Map<String, dynamic>>.from(response.data);
    final count = response.count;

    return (items: data, totalCount: count);
  }

  Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
    String? imageUrl,
  }) async {
    if (_client == null) throw Exception('Not connected');
    final res = await _client
        .from('products')
        .insert({
          'name': name.trim(),
          'description': description.trim(),
          'price': price,
          'stock': stock,
          'category_id': categoryId,
          if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
        })
        .select('*, categories(name)')
        .single();
    return res;
  }

  Future<Map<String, dynamic>> updateProduct({
    required int id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
    String? imageUrl,
  }) async {
    if (_client == null) throw Exception('Not connected');
    final res = await _client
        .from('products')
        .update({
          'name': name.trim(),
          'description': description.trim(),
          'price': price,
          'stock': stock,
          'category_id': categoryId,
          if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
        })
        .eq('id', id)
        .select('*, categories(name)')
        .single();
    return res;
  }

  Future<void> deleteProduct(int id) async {
    if (_client == null) throw Exception('Not connected');
    await _client.from('products').delete().eq('id', id);
  }

  // -------------------------------------------------------------
  // STORAGE (Upload product image to 'product-images' bucket)
  // -------------------------------------------------------------
  Future<String?> uploadProductImage({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    if (_client == null) throw Exception('Not connected');
    final ext = fileName.split('.').last;
    final path = 'prod_${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _client.storage.from('product-images').uploadBinary(
          path,
          fileBytes,
          fileOptions: FileOptions(
            contentType: 'image/$ext',
            upsert: true,
          ),
        );

    final publicUrl =
        _client.storage.from('product-images').getPublicUrl(path);
    return publicUrl;
  }

  // -------------------------------------------------------------
  // ORDERS (Customer place order via place_order RPC, fetch orders)
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> placeOrder(
      List<Map<String, dynamic>> items) async {
    if (_client == null) throw Exception('Not connected');
    final res = await _client.rpc('place_order', params: {'items': items});
    return Map<String, dynamic>.from(res as Map);
  }

  Future<List<Map<String, dynamic>>> fetchCustomerOrders() async {
    if (_client == null) return [];
    final res = await _client
        .from('orders')
        .select('*, order_items(*)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchAdminOrders() async {
    if (_client == null) return [];
    final res = await _client
        .from('orders')
        .select('*, order_items(*), profiles!orders_user_id_fkey(email)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    if (_client == null) throw Exception('Not connected');
    await _client
        .from('orders')
        .update({'status': newStatus})
        .eq('id', orderId);
  }
}
