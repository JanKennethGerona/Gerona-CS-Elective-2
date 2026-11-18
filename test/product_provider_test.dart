import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/providers/product_providers.dart';

void main() {
  group('ProductFilterNotifier Riverpod Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial filter state has default 8 page size and full price range', () {
      final state = container.read(productFilterProvider);
      expect(state.searchQuery, '');
      expect(state.categoryId, isNull);
      expect(state.pageSize, 8);
      expect(state.currentPage, 1);
      expect(state.isFiltered, isFalse);
    });

    test('setPriceRange and setPageSize update filter state and reset page to 1', () {
      final notifier = container.read(productFilterProvider.notifier);
      notifier.setPage(3);
      expect(container.read(productFilterProvider).currentPage, 3);

      notifier.setPriceRange(const RangeValues(50, 150));
      expect(container.read(productFilterProvider).priceRange.start, 50);
      expect(container.read(productFilterProvider).priceRange.end, 150);
      expect(container.read(productFilterProvider).currentPage, 1); // Reset to 1

      notifier.setPageSize(6); // Switch between 6 and 8
      expect(container.read(productFilterProvider).pageSize, 6);
      expect(container.read(productFilterProvider).isFiltered, isTrue);

      notifier.resetFilters();
      expect(container.read(productFilterProvider).isFiltered, isFalse);
    });

    test('setSearchQuery and setCategory filter correctly', () {
      final notifier = container.read(productFilterProvider.notifier);
      notifier.setSearchQuery('Falcon');
      expect(container.read(productFilterProvider).searchQuery, 'Falcon');

      notifier.setCategory(3);
      expect(container.read(productFilterProvider).categoryId, 3);

      notifier.setCategory(null);
      expect(container.read(productFilterProvider).categoryId, isNull);
    });
  });
}
