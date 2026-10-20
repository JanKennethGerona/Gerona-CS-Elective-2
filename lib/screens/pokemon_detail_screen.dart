import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/favorites_provider.dart';
import '../providers/nickname_provider.dart';
import '../providers/pokemon_providers.dart';
import '../utils/type_colors.dart';
import '../widgets/nickname_dialog.dart';

class PokemonDetailScreen extends ConsumerWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(selectedPokemonProvider);
    const darkBackground = Color(0xFF242426);

    if (pokemon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pokémon Details')),
        body: const Center(child: Text('No Pokémon selected')),
      );
    }

    final isFavorite = ref.watch(favoritesProvider).contains(pokemon.id);
    final nickname = ref.watch(nicknameProvider)[pokemon.id];
    final primaryColor = getTypeColor(pokemon.primaryType);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pokemon.formattedName,
          style: GoogleFonts.pixelifySans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFCE3A47),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? const Color(0xFFFF5252) : Colors.white,
            ),
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(pokemon.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => showNicknameDialog(context, ref, pokemon),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: darkBackground,
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.85,
            colors: [
              primaryColor.withValues(alpha: 0.5),
              darkBackground,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'pokemon-${pokemon.id}',
                  child: Image.network(
                    pokemon.imageUrl,
                    height: 240,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.catching_pokemon,
                      size: 160,
                      color: Colors.white60,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  pokemon.formattedName,
                  style: GoogleFonts.pixelifySans(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (nickname != null && nickname.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Nickname: "$nickname"',
                      style: GoogleFonts.pixelifySans(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFFFFF3E0),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  pokemon.formattedId,
                  style: GoogleFonts.pixelifySans(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: pokemon.types.map((type) {
                    final color = getTypeColor(type);
                    return Chip(
                      label: Text(
                        type.toUpperCase(),
                        style: GoogleFonts.pixelifySans(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: color,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCE3A47),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(
                    nickname == null ? 'Set Nickname' : 'Edit Nickname',
                    style: GoogleFonts.pixelifySans(fontSize: 16),
                  ),
                  onPressed: () => showNicknameDialog(context, ref, pokemon),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
