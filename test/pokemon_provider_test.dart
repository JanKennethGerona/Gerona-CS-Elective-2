import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/models/pokemon.dart';
import 'package:my_first_flutter_ui/providers/favorites_provider.dart';
import 'package:my_first_flutter_ui/providers/nickname_provider.dart';
import 'package:my_first_flutter_ui/providers/pokemon_providers.dart';
import 'package:my_first_flutter_ui/providers/type_filter_provider.dart';
import 'package:my_first_flutter_ui/services/pokemon_service.dart';

class FakePokemonService extends PokemonService {
  FakePokemonService(this.mockData);

  final List<Pokemon> mockData;
  int callCount = 0;

  @override
  Future<List<Pokemon>> fetchPokemonsWithTypes({int limit = 30}) async {
    callCount++;
    return mockData;
  }
}

Pokemon mockPokemon(int id, {List<String> types = const []}) => Pokemon(
      id: id,
      name: 'pokemon$id',
      imageUrl: 'https://example.com/$id.png',
      types: types,
    );

void main() {
  group('FavoritesNotifier', () {
    test('toggles favorites correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(favoritesProvider), isEmpty);
      expect(container.read(favoritesProvider.notifier).isFavorite(25), isFalse);

      // Add to favorites
      container.read(favoritesProvider.notifier).toggleFavorite(25);
      expect(container.read(favoritesProvider), contains(25));
      expect(container.read(favoritesProvider.notifier).isFavorite(25), isTrue);

      // Remove from favorites
      container.read(favoritesProvider.notifier).toggleFavorite(25);
      expect(container.read(favoritesProvider), isNot(contains(25)));
      expect(container.read(favoritesProvider.notifier).isFavorite(25), isFalse);
    });
  });

  group('NicknameNotifier', () {
    test('sets, gets, and removes nicknames', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(nicknameProvider.notifier).getNickname(25), isNull);

      // Set nickname
      container.read(nicknameProvider.notifier).setNickname(25, 'Sparky');
      expect(container.read(nicknameProvider)[25], 'Sparky');
      expect(container.read(nicknameProvider.notifier).getNickname(25), 'Sparky');

      // Edit nickname
      container.read(nicknameProvider.notifier).setNickname(25, 'Volt');
      expect(container.read(nicknameProvider)[25], 'Volt');

      // Remove nickname
      container.read(nicknameProvider.notifier).removeNickname(25);
      expect(container.read(nicknameProvider)[25], isNull);

      // Setting empty nickname also removes it
      container.read(nicknameProvider.notifier).setNickname(25, 'Thunder');
      container.read(nicknameProvider.notifier).setNickname(25, '   ');
      expect(container.read(nicknameProvider)[25], isNull);
    });
  });

  group('PokemonListNotifier & Filtering', () {
    test('fetches pokemon list and supports type filtering', () async {
      final testPokemons = [
        mockPokemon(1, types: ['grass', 'poison']),
        mockPokemon(4, types: ['fire']),
        mockPokemon(7, types: ['water']),
      ];

      final fakeService = FakePokemonService(testPokemons);

      final container = ProviderContainer(
        overrides: [
          pokemonServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      // Listen to initialize
      final asyncList = await container.read(pokemonListProvider.future);
      expect(asyncList.length, 3);
      expect(fakeService.callCount, 1);

      // Verify available types
      final availableTypes = container.read(availableTypesProvider);
      expect(availableTypes, containsAll(['fire', 'grass', 'poison', 'water']));

      // Filter by 'fire'
      container.read(selectedTypeProvider.notifier).state = 'fire';
      final filteredFire = container.read(filteredPokemonProvider).value;
      expect(filteredFire?.length, 1);
      expect(filteredFire?.first.name, 'pokemon4');

      // Clear filter
      container.read(selectedTypeProvider.notifier).state = null;
      final allFiltered = container.read(filteredPokemonProvider).value;
      expect(allFiltered?.length, 3);

      // Refresh re-invokes fetch
      await container.read(pokemonListProvider.notifier).refresh();
      expect(fakeService.callCount, 2);
    });
  });
}
