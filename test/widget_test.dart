import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/data/lego_catalog.dart';
import 'package:my_first_flutter_ui/main.dart';
import 'package:my_first_flutter_ui/state/cart_model.dart';
import 'package:my_first_flutter_ui/state/theme_model.dart';
import 'package:my_first_flutter_ui/widgets/product_card.dart';
import 'package:my_first_flutter_ui/widgets/product_grid.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App renders Bricked title and product grid', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeModel()),
          ChangeNotifierProvider(create: (_) => CartModel()),
        ],
        child: const BrickedApp(),
      ),
    );

    // Initial pump
    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.text('Bricked'), findsOneWidget);

    // Verify catalog header
    expect(find.text('Master Builder Catalog'), findsOneWidget);

    // Verify product cards are displayed
    expect(find.byType(ProductCard), findsWidgets);
    expect(find.text('Millennium Falcon'), findsOneWidget);
  });

  testWidgets('Theme toggle button changes ThemeMode', (WidgetTester tester) async {
    final themeModel = ThemeModel();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeModel),
          ChangeNotifierProvider(create: (_) => CartModel()),
        ],
        child: const BrickedApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(themeModel.themeMode, ThemeMode.light);

    // Find and tap theme toggle button in AppBar
    final toggleButton = find.byKey(const Key('theme_toggle_button'));
    expect(toggleButton, findsOneWidget);
    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    expect(themeModel.themeMode, ThemeMode.dark);
  });

  test('CartModel adds items and computes subtotal correctly', () {
    final cart = CartModel();
    final product = LegoCatalog.products.first; // Millennium Falcon, 849.99

    expect(cart.isEmpty, isTrue);
    expect(cart.totalItemCount, 0);

    cart.addItem(product);
    expect(cart.isNotEmpty, isTrue);
    expect(cart.totalItemCount, 1);
    expect(cart.total, product.price);

    // Increase quantity
    cart.updateQuantity(product.id, 1);
    expect(cart.totalItemCount, 2);
    expect(cart.total, product.price * 2);

    // Decrease quantity
    cart.updateQuantity(product.id, -1);
    expect(cart.totalItemCount, 1);
    expect(cart.total, product.price);

    // Remove
    cart.removeItem(product.id);
    expect(cart.isEmpty, isTrue);
  });
  testWidgets('Full flow: Home -> Product Detail -> Add to Cart -> View Cart', (WidgetTester tester) async {
    final cartModel = CartModel();
    final themeModel = ThemeModel();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeModel),
          ChangeNotifierProvider.value(value: cartModel),
        ],
        child: const BrickedApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Tap on the first product card (Millennium Falcon)
    final productCard = find.byKey(const Key('product_card_75192'));
    expect(productCard, findsOneWidget);
    await tester.tap(productCard);
    await tester.pumpAndSettle();

    // Verify we are on Product Detail screen
    expect(find.text('Product Details'), findsOneWidget);
    expect(find.text('Set #75192'), findsOneWidget);
    expect(find.text('Set Overview'), findsOneWidget);

    // Scroll to and tap Add to Cart button
    final addToCartBtn = find.byKey(const Key('add_to_cart_elevated_button'));
    expect(addToCartBtn, findsOneWidget);
    await tester.ensureVisible(addToCartBtn);
    await tester.pumpAndSettle();

    await tester.tap(addToCartBtn);
    await tester.pump(); // Start animation
    expect(find.text('Added to Cart!'), findsOneWidget);
    expect(cartModel.totalItemCount, 1);

    // Settle button timeout and SnackBar
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Tap Cart button in AppBar
    final cartButton = find.byKey(const Key('appbar_cart_button'));
    expect(cartButton, findsOneWidget);
    await tester.tap(cartButton);
    await tester.pumpAndSettle();

    // Clear any active snackbar overlays so checkout button can be tapped cleanly
    final scaffoldContext = tester.element(find.text('Your Cart'));
    ScaffoldMessenger.of(scaffoldContext).clearSnackBars();
    await tester.pumpAndSettle();

    // Verify Cart screen
    expect(find.text('Your Cart'), findsOneWidget);
    expect(find.byKey(const Key('cart_item_75192')), findsOneWidget);
    expect(find.byKey(const Key('checkout_button')), findsOneWidget);

    // Proceed to Checkout Confirmation
    await tester.tap(find.byKey(const Key('checkout_button')));
    await tester.pumpAndSettle();

    // Verify Confirmation screen
    expect(find.text('Order Confirmed'), findsOneWidget);
    expect(find.text('Thank You for Your Order!'), findsOneWidget);
    expect(find.text('Order Summary'), findsOneWidget);

    // Tap Continue Shopping (clears cart and returns to home)
    final continueShoppingBtn = find.byKey(const Key('continue_shopping_button'));
    expect(continueShoppingBtn, findsOneWidget);
    await tester.ensureVisible(continueShoppingBtn);
    await tester.pumpAndSettle();
    await tester.tap(continueShoppingBtn);
    await tester.pumpAndSettle();

    // Should be back at Home screen and cart should be empty
    expect(find.text('Master Builder Catalog'), findsOneWidget);
    expect(cartModel.isEmpty, isTrue);
  });

  testWidgets('Checkout route guard redirects to cart if cart is empty', (WidgetTester tester) async {
    final cartModel = CartModel();
    final themeModel = ThemeModel();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeModel),
          ChangeNotifierProvider.value(value: cartModel),
        ],
        child: const BrickedApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Cart is empty, navigate to cart
    final cartButton = find.byKey(const Key('appbar_cart_button'));
    await tester.tap(cartButton);
    await tester.pumpAndSettle();

    // Should show empty cart state
    expect(find.text('Your Cart is Empty'), findsOneWidget);
  });

  testWidgets('ProductGrid adapts columns responsively (2 on phone, 3 on tablet, 4 on desktop)', (WidgetTester tester) async {
    // 1. Phone width (< 600) -> 2 columns
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 450,
            height: 800,
            child: ProductGrid(products: LegoCatalog.products),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    var gridView = tester.widget<GridView>(find.byKey(const Key('product_grid_view')));
    var delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 2);

    // 2. Tablet width (600 - 950) -> 3 columns
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 768,
            height: 1024,
            child: ProductGrid(products: LegoCatalog.products),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    gridView = tester.widget<GridView>(find.byKey(const Key('product_grid_view')));
    delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 3);

    // 3. Desktop / wide width (>= 950) -> 4 columns
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 900,
            child: ProductGrid(products: LegoCatalog.products),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    gridView = tester.widget<GridView>(find.byKey(const Key('product_grid_view')));
    delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 4);
  });
}
