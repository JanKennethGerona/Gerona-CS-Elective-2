import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/models/pokemon.dart';

void main() {
  group('Pokemon Model', () {
    test('parses JSON correctly with id and image url', () {
      final json = {
        'name': 'pikachu',
        'url': 'https://pokeapi.co/api/v2/pokemon/25/',
      };

      final pokemon = Pokemon.fromJson(json);

      expect(pokemon.id, 25);
      expect(pokemon.name, 'pikachu');
      expect(
        pokemon.imageUrl,
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
      );
      expect(pokemon.formattedName, 'Pikachu');
      expect(pokemon.formattedId, '#025');
      expect(pokemon.types, isEmpty);
      expect(pokemon.primaryType, 'normal');
    });

    test('supports copyWithTypes and primaryType', () {
      final json = {
        'name': 'bulbasaur',
        'url': 'https://pokeapi.co/api/v2/pokemon/1/',
      };

      final pokemon = Pokemon.fromListJson(json);
      final enriched = pokemon.copyWithTypes(['grass', 'poison']);

      expect(enriched.id, 1);
      expect(enriched.name, 'bulbasaur');
      expect(enriched.types, ['grass', 'poison']);
      expect(enriched.primaryType, 'grass');
    });

    test('formats id with 3 padded digits', () {
      final json1 = {
        'name': 'bulbasaur',
        'url': 'https://pokeapi.co/api/v2/pokemon/1/',
      };
      final pokemon1 = Pokemon.fromJson(json1);
      expect(pokemon1.formattedId, '#001');

      final json150 = {
        'name': 'mewtwo',
        'url': 'https://pokeapi.co/api/v2/pokemon/150/',
      };
      final pokemon150 = Pokemon.fromJson(json150);
      expect(pokemon150.formattedId, '#150');
    });

    test('throws FormatException on invalid URL', () {
      final invalidJson = {
        'name': 'unknown',
        'url': 'https://pokeapi.co/api/v2/pokemon/notanumber/',
      };

      expect(() => Pokemon.fromJson(invalidJson), throwsFormatException);
    });

    test('throws FormatException on empty URL', () {
      final emptyUrlJson = {
        'name': 'unknown',
        'url': '',
      };

      expect(() => Pokemon.fromJson(emptyUrlJson), throwsFormatException);
    });
  });
}
