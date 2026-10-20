import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';
import '../providers/nickname_provider.dart';
import '../utils/type_colors.dart';
import 'nickname_dialog.dart';

class PokemonCard extends ConsumerWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).contains(pokemon.id);
    final nickname = ref.watch(nicknameProvider)[pokemon.id];
    final cardColor = getTypeColor(pokemon.primaryType);

    return Card(
      elevation: 2,
      color: cardColor,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!();
          } else {
            showNicknameDialog(context, ref, pokemon);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Favorite Heart (left) + ID Badge (right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkResponse(
                      radius: 20,
                      splashColor:
                          const Color(0xFFFF5252).withValues(alpha: 0.45),
                      highlightColor:
                          const Color(0xFFFF5252).withValues(alpha: 0.2),
                      onTap: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(pokemon.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: AnimatedScale(
                          scale: isFavorite ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOutBack,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? const Color(0xFFFF5252)
                                : Colors.white70,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    pokemon.formattedId,
                    style: GoogleFonts.pixelifySans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),

              // Sprite Image
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 86,
                    height: 86,
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
                          size: 44,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 2),

              // Original Name (Always visible)
              Text(
                pokemon.formattedName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.pixelifySans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),

              // Nickname (Visible if assigned)
              if (nickname != null && nickname.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Text(
                    '"$nickname"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pixelifySans(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFF3E0),
                    ),
                  ),
                ),

              const SizedBox(height: 4),

              // Type Badges / Pills
              if (pokemon.types.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 2,
                  children: pokemon.types.map((type) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: GoogleFonts.pixelifySans(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
