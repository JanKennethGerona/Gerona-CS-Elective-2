import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

/// Provider for PokemonService (can be overridden in tests)
final pokemonServiceProvider = Provider<PokemonService>((ref) {
  return PokemonService();
});

/// Currently selected Pokémon for viewing details
final selectedPokemonProvider = StateProvider<Pokemon?>((ref) => null);

/// Main AsyncNotifier provider for fetching and holding the Pokémon list
final pokemonListProvider =
    AsyncNotifierProvider<PokemonListNotifier, List<Pokemon>>(
  PokemonListNotifier.new,
);

class PokemonListNotifier extends AsyncNotifier<List<Pokemon>> {
  @override
  Future<List<Pokemon>> build() async {
    final service = ref.read(pokemonServiceProvider);
    return service.fetchPokemonsWithTypes();
  }

  /// Refreshes by re-executing build(), which invokes the existing fetch method
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
