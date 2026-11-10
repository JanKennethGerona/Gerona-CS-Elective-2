import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/main.dart';
import 'package:my_first_flutter_ui/widgets/pagination_controls.dart';
import 'package:my_first_flutter_ui/widgets/price_filter_slider.dart';

void main() {
  testWidgets('AuthGate navigates from AuthScreen to ShopScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Verify LEGO-themed AuthScreen rendered
    expect(find.text('LEGO'), findsOneWidget);
    expect(find.text('BRICK SHOP AUTH'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Skip for now (Continue as Guest)'), findsOneWidget);

    // 2. Tap Continue as Guest to enter the ShopScreen
    await tester.tap(find.text('Skip for now (Continue as Guest)'));
    await tester.pumpAndSettle();

    // 3. Verify ShopScreen rendered
    expect(find.text('Price Filtering & Pagination'), findsOneWidget);
    expect(find.byType(PriceFilterSlider), findsOneWidget);
    expect(find.byType(PaginationControls), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
