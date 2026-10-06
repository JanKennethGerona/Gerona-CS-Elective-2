import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_card.dart';

class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pokemon = context.watch<PokemonProvider>().selectedPokemon;
    const darkBackground = Color(0xFF242426);

    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon Details')),
      body: Container(
        decoration: BoxDecoration(
          color: darkBackground,
          gradient: pokemon == null
              ? null
              : RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    getPokemonCardColor(pokemon.id),
                    darkBackground,
                  ],
                ),
        ),
        child: pokemon == null
            ? const Center(child: Text('No Pokémon selected'))
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'pokemon-${pokemon.id}',
                        child: Image.network(
                          pokemon.imageUrl,
                          height: 260,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.catching_pokemon,
                            size: 180,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        pokemon.formattedName,
                        style: GoogleFonts.pixelifySans(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pokemon.formattedId,
                        style: GoogleFonts.pixelifySans(fontSize: 22),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
