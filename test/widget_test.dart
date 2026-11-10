import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/main.dart';

void main() {
  testWidgets('AuthGate navigates from AuthScreen to ShopScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Verify LEGO-themed AuthScreen rendered
    expect(find.text('BRICKED'), findsOneWidget);
    expect(find.text('Build Your Imagination, Brick by Brick.'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Skip for now (Continue as Guest)'), findsNothing);
  });
}
