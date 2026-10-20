import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<int>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<Set<int>> {
  FavoritesNotifier() : super({});

  void toggleFavorite(int pokemonId) {
    if (state.contains(pokemonId)) {
      state = {...state}..remove(pokemonId);
    } else {
      state = {...state, pokemonId};
    }
  }

  bool isFavorite(int pokemonId) => state.contains(pokemonId);
}
