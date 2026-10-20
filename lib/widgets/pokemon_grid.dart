import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/type_filter_provider.dart';
import 'pokemon_card.dart';

class PokemonGrid extends ConsumerWidget {
  const PokemonGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredPokemonProvider);

    return filteredAsync.maybeWhen(
      data: (pokemons) => GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.73,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: pokemons.length,
        itemBuilder: (context, index) => PokemonCard(pokemon: pokemons[index]),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
