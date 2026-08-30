// Basic smoke test for the Responsive & Adaptive Dashboard.

import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_ui/main.dart';

void main() {
  testWidgets('Dashboard renders the overview title', (WidgetTester tester) async {
    await tester.pumpWidget(const DashboardApp());

    // The main content header should be visible.
    expect(find.text('Dashboard Overview'), findsOneWidget);
  });
}
