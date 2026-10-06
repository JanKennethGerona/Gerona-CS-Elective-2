import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import 'pokemon_card.dart';

class PokemonGrid extends StatelessWidget {
  const PokemonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final pokemonList = context.watch<PokemonProvider>().pokemonList;

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.86,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: pokemonList.length,
      itemBuilder: (context, index) => PokemonCard(pokemon: pokemonList[index]),
    );
  }
}
