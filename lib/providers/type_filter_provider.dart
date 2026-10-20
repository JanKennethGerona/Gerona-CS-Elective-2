import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import 'pokemon_providers.dart';

/// Currently selected type filter (null = show all)
final selectedTypeProvider = StateProvider<String?>((ref) => null);

/// All available types extracted from loaded Pokémon list
final availableTypesProvider = Provider<List<String>>((ref) {
  final pokemonAsync = ref.watch(pokemonListProvider);
  return pokemonAsync.whenOrNull(data: (pokemons) {
    final types = <String>{};
    for (final p in pokemons) {
      types.addAll(p.types.map((t) => t.toLowerCase()));
    }
    final sorted = types.toList()..sort();
    return sorted;
  }) ?? [];
});

/// Filtered Pokémon list reacting to data and selectedType
final filteredPokemonProvider = Provider<AsyncValue<List<Pokemon>>>((ref) {
  final pokemonAsync = ref.watch(pokemonListProvider);
  final selectedType = ref.watch(selectedTypeProvider);

  return pokemonAsync.whenData((pokemons) {
    if (selectedType == null || selectedType.isEmpty) return pokemons;
    return pokemons
        .where((p) => p.types
            .map((t) => t.toLowerCase())
            .contains(selectedType.toLowerCase()))
        .toList();
  });
});
