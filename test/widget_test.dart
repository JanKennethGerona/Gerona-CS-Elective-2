import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/main.dart';
import 'package:my_first_flutter_ui/widgets/loading_view.dart';

void main() {
  testWidgets('PokedexApp loads and displays AppBar and LoadingView', (WidgetTester tester) async {
    await tester.pumpWidget(const PokedexApp());

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Pokedex'),
      ),
      findsOneWidget,
    );
    expect(find.byType(LoadingView), findsOneWidget);
  });
}
