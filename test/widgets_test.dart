import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/models/pokemon.dart';
import 'package:my_first_flutter_ui/widgets/empty_view.dart';
import 'package:my_first_flutter_ui/widgets/error_view.dart';
import 'package:my_first_flutter_ui/widgets/loading_view.dart';
import 'package:my_first_flutter_ui/widgets/pokemon_card.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('LoadingView displays CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingView()),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ErrorView displays message and triggers onRetry', (tester) async {
      var retryClicked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Failed to load data',
              onRetry: () {
                retryClicked = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Failed to load data'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retryClicked, isTrue);
    });

    testWidgets('EmptyView displays custom and default messages', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmptyView()),
        ),
      );
      expect(find.text('No Pokémon found'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmptyView(message: 'Custom empty text')),
        ),
      );
      expect(find.text('Custom empty text'), findsOneWidget);
    });

    testWidgets('PokemonCard renders formatted name and ID', (tester) async {
      const pokemon = Pokemon(
        id: 7,
        name: 'squirtle',
        imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/7.png',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PokemonCard(pokemon: pokemon),
          ),
        ),
      );

      expect(find.text('#7'), findsOneWidget);
      expect(find.text('Squirtle'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
