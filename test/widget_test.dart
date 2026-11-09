import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/main.dart';
import 'package:my_first_flutter_ui/widgets/pagination_controls.dart';
import 'package:my_first_flutter_ui/widgets/price_filter_slider.dart';

void main() {
  testWidgets('ShopScreen smoke test renders UI components', (WidgetTester tester) async {
    // Set a surface size large enough to display both widgets
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify AppBar
    expect(find.text('Supabase Shop'), findsOneWidget);
    expect(find.text('Price Filtering & Pagination'), findsOneWidget);

    // Verify Price Filter Slider
    expect(find.byType(PriceFilterSlider), findsOneWidget);
    expect(find.text('Price Range Filter'), findsOneWidget);

    // Verify Search input
    expect(find.byType(TextField), findsOneWidget);

    // Verify Pagination Controls
    expect(find.byType(PaginationControls), findsOneWidget);
    expect(find.text('Previous Page'), findsNothing); // It's in tooltip
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    // Verify FAB to Add Product
    expect(find.text('Add Product'), findsOneWidget);
  });
}
