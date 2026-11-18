import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/models/product.dart';
import 'package:my_first_flutter_ui/providers/auth_providers.dart';
import 'package:my_first_flutter_ui/widgets/product_card.dart';

void main() {
  final testProduct = Product(
    id: 1,
    createdAt: DateTime.now(),
    name: 'LEGO Millennium Falcon',
    description: 'Starship',
    price: 849.99,
    stock: 5,
    categoryId: 1,
    categoryName: 'Star Wars',
  );

  testWidgets(
    'Customer view: ProductCard displays Add to Cart button and no Edit/Delete',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [isAdminProvider.overrideWithValue(false)],
          child: MaterialApp(
            home: Scaffold(body: ProductCard(product: testProduct)),
          ),
        ),
      );

      expect(find.text('LEGO Millennium Falcon'), findsOneWidget);
      expect(find.text('\$849.99'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget); // Customer Add button
      expect(find.byIcon(Icons.edit), findsNothing); // Admin only
      expect(find.byIcon(Icons.delete), findsNothing); // Admin only
    },
  );

  testWidgets(
    'Admin view: ProductCard displays Edit and Delete buttons and no Add to Cart',
    (tester) async {
      bool editTapped = false;
      bool deleteTapped = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [isAdminProvider.overrideWithValue(true)],
          child: MaterialApp(
            home: Scaffold(
              body: ProductCard(
                product: testProduct,
                onEdit: () => editTapped = true,
                onDelete: () => deleteTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Add'), findsNothing); // Customers only
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);

      await tester.tap(find.byIcon(Icons.edit));
      expect(editTapped, isTrue);

      await tester.tap(find.byIcon(Icons.delete));
      expect(deleteTapped, isTrue);
    },
  );
}
