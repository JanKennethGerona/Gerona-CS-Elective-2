import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import 'auth_providers.dart';

class ProductFilterState {
  final String searchQuery;
  final int? categoryId;
  final RangeValues priceRange;
  final int currentPage;
  final int pageSize;

  static const double minPrice = 0.0;
  static const double maxPrice = 1000.0;

  const ProductFilterState({
    this.searchQuery = '',
    this.categoryId,
    this.priceRange = const RangeValues(minPrice, maxPrice),
    this.currentPage = 1,
    this.pageSize = 8,
  });

  bool get isFiltered =>
      searchQuery.isNotEmpty ||
      categoryId != null ||
      priceRange.start != minPrice ||
      priceRange.end != maxPrice;

  ProductFilterState copyWith({
    String? searchQuery,
    int? categoryId,
    bool clearCategory = false,
    RangeValues? priceRange,
    int? currentPage,
    int? pageSize,
  }) {
    return ProductFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      priceRange: priceRange ?? this.priceRange,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class ProductFilterNotifier extends Notifier<ProductFilterState> {
  @override
  ProductFilterState build() => const ProductFilterState();

  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q, currentPage: 1);
  }

  void setCategory(int? catId) {
    state = state.copyWith(
      categoryId: catId,
      clearCategory: catId == null,
      currentPage: 1,
    );
  }

  void setPriceRange(RangeValues range) {
    state = state.copyWith(priceRange: range, currentPage: 1);
  }

  void setPage(int p) {
    state = state.copyWith(currentPage: p);
  }

  void setPageSize(int s) {
    state = state.copyWith(pageSize: s, currentPage: 1);
  }

  void resetFilters() {
    state = const ProductFilterState();
  }
}

final productFilterProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilterState>(() {
  return ProductFilterNotifier();
});

class ProductsPaginationResult {
  final List<Product> products;
  final int totalCount;
  final int currentPage;
  final int pageSize;

  const ProductsPaginationResult({
    required this.products,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
  });

  int get totalPages => (totalCount / pageSize).ceil().clamp(1, 9999);
  bool get hasNextPage => currentPage < totalPages;
  bool get hasPrevPage => currentPage > 1;
}

final productsProvider = FutureProvider<ProductsPaginationResult>((ref) async {
  final filter = ref.watch(productFilterProvider);
  final service = ref.watch(supabaseServiceProvider);

  final res = await service.fetchProducts(
    searchQuery: filter.searchQuery,
    categoryId: filter.categoryId,
    minPrice: filter.priceRange.start,
    maxPrice: filter.priceRange.end,
    page: filter.currentPage,
    pageSize: filter.pageSize,
  );

  final items = res.items.map((m) => Product.fromJson(m)).toList();
  return ProductsPaginationResult(
    products: items,
    totalCount: res.totalCount,
    currentPage: filter.currentPage,
    pageSize: filter.pageSize,
  );
});
