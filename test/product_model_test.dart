import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('fromJson correctly parses valid map', () {
      final json = {
        'id': 10,
        'name': 'Wireless Mouse',
        'description': 'Ergonomic mouse',
        'price': 29.99,
        'stock': 15,
        'image_url': 'https://example.com/mouse.png',
        'created_at': '2026-11-10T00:00:00.000Z',
      };

      final product = Product.fromJson(json);

      expect(product.id, 10);
      expect(product.name, 'Wireless Mouse');
      expect(product.description, 'Ergonomic mouse');
      expect(product.price, 29.99);
      expect(product.stock, 15);
      expect(product.imageUrl, 'https://example.com/mouse.png');
      expect(product.createdAt, isNotNull);
    });

    test('toJson produces expected map', () {
      const product = Product(
        id: 5,
        name: 'Keyboard',
        description: 'Mechanical',
        price: 99.0,
        stock: 8,
        imageUrl: 'https://example.com/kb.png',
      );

      final json = product.toJson(includeId: true);

      expect(json['id'], 5);
      expect(json['name'], 'Keyboard');
      expect(json['price'], 99.0);
      expect(json['stock'], 8);
      expect(json['image_url'], 'https://example.com/kb.png');
    });

    test('copyWith updates properties properly', () {
      const original = Product(
        id: 1,
        name: 'Monitor',
        price: 200.0,
        stock: 5,
      );

      final updated = original.copyWith(price: 250.0, stock: 4);

      expect(updated.id, original.id);
      expect(updated.name, 'Monitor');
      expect(updated.price, 250.0);
      expect(updated.stock, 4);
    });
  });
}
