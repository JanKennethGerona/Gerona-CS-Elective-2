import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/models/product.dart';
import 'package:my_first_flutter_ui/providers/product_provider.dart';

void main() {
  group('ProductProvider Tests', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
    });

    test('Initial fetch populates products with default page size of 8', () async {
      await provider.fetchProducts();

      expect(provider.currentPage, 1);
      expect(provider.pageSize, 8);
      expect(provider.products.length, lessThanOrEqualTo(8));
      expect(provider.totalCount, greaterThan(8));
      expect(provider.totalPages, greaterThan(1));
      expect(provider.hasNextPage, isTrue);
      expect(provider.hasPrevPage, isFalse);
    });

    test('Pagination navigation works (nextPage, previousPage, goToPage)', () async {
      await provider.fetchProducts();

      final firstPageFirstItem = provider.products.first;

      // Navigate to Next Page
      provider.nextPage();
      await Future<void>.delayed(Duration.zero);

      expect(provider.currentPage, 2);
      expect(provider.hasPrevPage, isTrue);
      final secondPageFirstItem = provider.products.first;
      expect(secondPageFirstItem.id, isNot(firstPageFirstItem.id));

      // Navigate back to Previous Page
      provider.previousPage();
      await Future<void>.delayed(Duration.zero);

      expect(provider.currentPage, 1);
      expect(provider.products.first.id, firstPageFirstItem.id);

      // Go to direct page
      provider.goToPage(2);
      await Future<void>.delayed(Duration.zero);
      expect(provider.currentPage, 2);
    });

    test('Page size switcher changes items per page to 6 (Requirement: 6-8 items)', () async {
      await provider.fetchProducts();
      expect(provider.pageSize, 8);

      provider.setPageSize(6);
      await Future<void>.delayed(Duration.zero);

      expect(provider.pageSize, 6);
      expect(provider.products.length, lessThanOrEqualTo(6));
      expect(provider.currentPage, 1);
    });

    test('Price Range Filtering filters products within specified bounds', () async {
      await provider.fetchProducts();

      // Filter between $30 and $70
      provider.setPriceRange(const RangeValues(30.0, 70.0));
      await Future<void>.delayed(Duration.zero);

      expect(provider.products.isNotEmpty, isTrue);
      for (final product in provider.products) {
        expect(product.price, greaterThanOrEqualTo(30.0));
        expect(product.price, lessThanOrEqualTo(70.0));
      }
    });

    test('Search filter filters by product name', () async {
      await provider.fetchProducts();

      provider.setSearchQuery('Castle');
      await Future<void>.delayed(Duration.zero);

      expect(provider.products.isNotEmpty, isTrue);
      for (final product in provider.products) {
        expect(
          product.name.toLowerCase().contains('castle') ||
              product.description.toLowerCase().contains('castle'),
          isTrue,
        );
      }
    });

    test('CRUD operations work (Add, Update, Delete)', () async {
      await provider.fetchProducts();
      final initialCount = provider.totalCount;

      // 1. Add (use a low price so it appears on page 1 sorted by price)
      const newProduct = Product(
        name: 'Test Gaming Headset',
        description: 'RGB wireless headset',
        price: 5.00,
        stock: 5,
      );
      final addSuccess = await provider.addProduct(newProduct);
      expect(addSuccess, isTrue);
      expect(provider.totalCount, initialCount + 1);

      final added = provider.products.firstWhere((p) => p.name == 'Test Gaming Headset');

      // 2. Update
      final updatedProduct = added.copyWith(price: 6.00);
      final updateSuccess = await provider.updateProduct(updatedProduct);
      expect(updateSuccess, isTrue);

      final updated = provider.products.firstWhere((p) => p.id == added.id);
      expect(updated.price, 6.00);

      // 3. Delete
      final deleteSuccess = await provider.deleteProduct(added.id);
      expect(deleteSuccess, isTrue);
      expect(provider.totalCount, initialCount);
    });
  });
}
