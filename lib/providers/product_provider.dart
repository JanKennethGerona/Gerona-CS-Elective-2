import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service;

  ProductProvider({ProductService? service})
      : _service = service ?? ProductService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Pagination state (requirement: show 6-8 max number of products per page)
  int _currentPage = 1;
  int _pageSize = 8;
  int _totalCount = 0;

  // Price filter state (requirement: price slider range)
  static const double minAllowedPrice = 0.0;
  static const double maxAllowedPrice = 400.0;
  RangeValues _priceRange = const RangeValues(minAllowedPrice, maxAllowedPrice);

  // Search filter
  String _searchQuery = '';

  // Getters
  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalCount => _totalCount;
  int get totalPages {
    if (_totalCount <= 0) return 1;
    return (_totalCount / _pageSize).ceil();
  }
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPrevPage => _currentPage > 1;
  RangeValues get priceRange => _priceRange;
  String get searchQuery => _searchQuery;
  bool get isConnectedToSupabase => _service.isConnectedToSupabase;
  bool get isFiltered =>
      _priceRange.start > minAllowedPrice ||
      _priceRange.end < maxAllowedPrice ||
      _searchQuery.isNotEmpty;

  /// Fetch products applying the Supabase query filters and pagination
  Future<void> fetchProducts({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchProducts(
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        page: _currentPage,
        pageSize: _pageSize,
      );

      _products = result.products;
      _totalCount = result.totalCount;

      // Adjust current page if current page exceeds total pages
      if (_currentPage > totalPages && totalPages > 0) {
        _currentPage = totalPages;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update price range filter and reload page 1
  void setPriceRange(RangeValues values) {
    _priceRange = values;
    _currentPage = 1;
    fetchProducts();
  }

  /// Update search query and reload page 1
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _currentPage = 1;
    fetchProducts();
  }

  /// Change page size (e.g. 6 or 8)
  void setPageSize(int size) {
    if (size == _pageSize) return;
    _pageSize = size;
    _currentPage = 1;
    fetchProducts();
  }

  /// Go to next page
  void nextPage() {
    if (hasNextPage && !_isLoading) {
      _currentPage++;
      fetchProducts();
    }
  }

  /// Go to previous page
  void previousPage() {
    if (hasPrevPage && !_isLoading) {
      _currentPage--;
      fetchProducts();
    }
  }

  /// Go to specific page
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages && page != _currentPage && !_isLoading) {
      _currentPage = page;
      fetchProducts();
    }
  }

  /// Reset all filters to default
  void resetFilters() {
    _priceRange = const RangeValues(minAllowedPrice, maxAllowedPrice);
    _searchQuery = '';
    _currentPage = 1;
    fetchProducts();
  }

  /// Add product
  Future<bool> addProduct(Product product) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _service.addProduct(product);
      await fetchProducts();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update product
  Future<bool> updateProduct(Product product) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _service.updateProduct(product);
      await fetchProducts();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete product
  Future<bool> deleteProduct(dynamic id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _service.deleteProduct(id);
      await fetchProducts();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
