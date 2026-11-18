import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('fromJson correctly parses valid map with category relation', () {
      final json = {
        'id': 101,
        'created_at': '2026-11-18T10:00:00.000Z',
        'name': 'LEGO Star Wars Millennium Falcon',
        'description': 'Iconic starship',
        'price': 849.99,
        'stock': 5,
        'image_url': 'https://images.brickset.com/sets/images/75192-1.jpg',
        'category_id': 1,
        'categories': {'name': 'Star Wars'},
      };

      final product = Product.fromJson(json);

      expect(product.id, 101);
      expect(product.name, 'LEGO Star Wars Millennium Falcon');
      expect(product.price, 849.99);
      expect(product.stock, 5);
      expect(product.categoryId, 1);
      expect(product.categoryName, 'Star Wars');
      expect(product.isOutOfStock, false);
    });

    test('toJson produces expected map matching required schema', () {
      final now = DateTime.now();
      final product = Product(
        id: 5,
        createdAt: now,
        name: 'LEGO Technic Porsche',
        description: 'Sports car',
        price: 299.99,
        stock: 0,
        imageUrl: 'https://example.com/porsche.jpg',
        categoryId: 2,
        categoryName: 'Technic',
      );

      final json = product.toJson();

      expect(json['id'], 5);
      expect(json['name'], 'LEGO Technic Porsche');
      expect(json['price'], 299.99);
      expect(json['stock'], 0);
      expect(json['category_id'], 2);
      expect(product.isOutOfStock, true);
    });

    test('copyWith updates properties properly', () {
      final original = Product(
        id: 1,
        createdAt: DateTime.now(),
        name: 'Original',
        price: 10.0,
        stock: 5,
        categoryId: 1,
      );

      final updated = original.copyWith(
        name: 'Updated Name',
        price: 19.99,
        stock: 2,
      );

      expect(updated.id, 1);
      expect(updated.name, 'Updated Name');
      expect(updated.price, 19.99);
      expect(updated.stock, 2);
      expect(updated.categoryId, 1);
    });
  });
}
