import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../screens/pokemon_detail_screen.dart';

Color getPokemonCardColor(int id) {
  switch (id) {
    // Bulbasaur family (Grass/Poison) -> Teal Mint
    case 1:
    case 2:
    case 3:
      return const Color(0xFF5ABCB9);
    // Charmander family (Fire) -> Amber / Terracotta
    case 4:
      return const Color(0xFFF19E53);
    case 5:
      return const Color(0xFFD65C4F);
    case 6:
      return const Color(0xFFEA8E48);
    // Squirtle family (Water) -> Sky Blue / Periwinkle
    case 7:
      return const Color(0xFF7DB9D5);
    case 8:
    case 9:
      return const Color(0xFF8BA6EC);
    // Caterpie family (Bug) -> Soft Lime
    case 10:
    case 11:
    case 12:
      return const Color(0xFF8EB758);
    // Weedle family (Bug/Poison) -> Warm Gold / Ochre
    case 13:
    case 14:
    case 15:
      return const Color(0xFFDEB543);
    // Pidgey family (Normal/Flying) -> Warm Sand
    case 16:
    case 17:
    case 18:
      return const Color(0xFFBCA289);
    // Rattata family (Normal) -> Lavender
    case 19:
    case 20:
      return const Color(0xFFA28CB7);
    // Spearow family -> Muted Tan
    case 21:
    case 22:
      return const Color(0xFFB9977E);
    // Ekans family (Poison) -> Purple
    case 23:
    case 24:
      return const Color(0xFFA56FB5);
    // Pikachu family (Electric) -> Bright Golden
    case 25:
    case 26:
      return const Color(0xFFF1C748);
    // Sandshrew family (Ground) -> Desert Sand
    case 27:
    case 28:
      return const Color(0xFFDEC16B);
    // Nidoran family -> Periwinkle / Rose
    case 29:
      return const Color(0xFF83AEE2);
    case 30:
      return const Color(0xFF7FA8D6);
    default:
      const palette = [
        Color(0xFF5ABCB9),
        Color(0xFFF19E53),
        Color(0xFF7DB9D5),
        Color(0xFF8EB758),
        Color(0xFFDEB543),
        Color(0xFFA56FB5),
        Color(0xFFD65C4F),
        Color(0xFF8BA6EC),
      ];
      return palette[id % palette.length];
  }
}

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = getPokemonCardColor(pokemon.id);

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.read<PokemonProvider>().selectPokemon(pokemon);
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const PokemonDetailScreen(),
            ),
          );
        },
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text(
                pokemon.formattedId,
                style: GoogleFonts.pixelifySans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: Image.network(
                    pokemon.imageUrl,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white70),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.catching_pokemon,
                        size: 48,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pokemon.formattedName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.pixelifySans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
        ),
      ),
    );
  }
}
