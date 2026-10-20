import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/favorites_provider.dart';
import '../providers/nickname_provider.dart';
import '../providers/pokemon_providers.dart';
import '../utils/type_colors.dart';
import 'nickname_dialog.dart';

/// Custom painter to draw the smooth bell-shaped tab protruding from the screen edge
class _BellTabPainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;

  _BellTabPainter({required this.borderColor, required this.fillColor});

  Path _getBellPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    path.moveTo(0, 0);

    // Smooth concave flare out from wall
    path.cubicTo(0, h * 0.10, w * 0.10, h * 0.17, w * 0.32, h * 0.18);

    // Upper half of circular round dome
    path.cubicTo(w * 0.85, h * 0.18, w, h * 0.32, w, h * 0.50);

    // Lower half of circular round dome
    path.cubicTo(w, h * 0.68, w * 0.85, h * 0.82, w * 0.32, h * 0.82);

    // Smooth concave flare back in to wall
    path.cubicTo(w * 0.10, h * 0.83, 0, h * 0.90, 0, h);

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Clip to x >= 0 to eliminate any shadow bleeding to the left
    canvas.clipRect(Rect.fromLTWH(0, -20, size.width + 30, size.height + 40));

    final path = _getBellPath(size);

    // Draw drop shadow (only visible to the right and above/below x >= 0)
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.55), 7.0, true);

    // Draw background fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw white outline along the outer curved bell edge
    final w = size.width;
    final h = size.height;
    final borderPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(0, h * 0.10, w * 0.10, h * 0.17, w * 0.32, h * 0.18)
      ..cubicTo(w * 0.85, h * 0.18, w, h * 0.32, w, h * 0.50)
      ..cubicTo(w, h * 0.68, w * 0.85, h * 0.82, w * 0.32, h * 0.82)
      ..cubicTo(w * 0.10, h * 0.83, 0, h * 0.90, 0, h);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(borderPath, borderPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BellTabPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor ||
      oldDelegate.fillColor != fillColor;
}

/// Clipper matching the bell-shaped curves to constrain the splash effect
class _BellTabClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(0, 0);
    path.cubicTo(0, h * 0.10, w * 0.10, h * 0.17, w * 0.32, h * 0.18);
    path.cubicTo(w * 0.85, h * 0.18, w, h * 0.32, w, h * 0.50);
    path.cubicTo(w, h * 0.68, w * 0.85, h * 0.82, w * 0.32, h * 0.82);
    path.cubicTo(w * 0.10, h * 0.83, 0, h * 0.90, 0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Bell-shaped floating tab handle pinned to the side with ink ripple splash
class FavoritesSideTab extends ConsumerWidget {
  const FavoritesSideTab({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(favoritesProvider).length;

    const width = 40.0;
    const height = 66.0;

    return SizedBox(
      width: width + 4,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Base Bell Button
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: CustomPaint(
              size: const Size(width, height),
              painter: _BellTabPainter(
                borderColor: Colors.white,
                fillColor: const Color(0xFFCE3A47),
              ),
              child: ClipPath(
                clipper: _BellTabClipper(),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    splashColor: Colors.white.withValues(alpha: 0.3),
                    highlightColor: Colors.white.withValues(alpha: 0.15),
                    child: const SizedBox(
                      width: width,
                      height: height,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(left: 3.0, right: 5.0),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Count Badge Overlay on Lower-Right Part (Higher z-index layer)
          if (count > 0)
            Positioned(
              bottom: 10,
              right: 4,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCE3A47),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 4,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Slide-out side drawer that displays all favorite Pokémon
class FavoritesDrawer extends StatelessWidget {
  const FavoritesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = (screenWidth * 0.85).clamp(300.0, 420.0);

    return Drawer(
      backgroundColor: const Color(0xFFCE3A47),
      elevation: 16,
      width: drawerWidth,
      child: FavoritesSidePanel(onClose: () => Navigator.of(context).pop()),
    );
  }
}

/// Content panel for favorites list (used in both Drawer and animated sliding panel)
class FavoritesSidePanel extends ConsumerWidget {
  const FavoritesSidePanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final pokemonAsync = ref.watch(pokemonListProvider);
    final nicknames = ref.watch(nicknameProvider);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFCE3A47),
        border: const Border(
          right: BorderSide(color: Colors.white, width: 2.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF8B1A24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Favorites (${favoriteIds.length})',
                      style: GoogleFonts.pixelifySans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),

            // Favorites List Content
            Expanded(
              child: pokemonAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Could not load favorites',
                    style: GoogleFonts.pixelifySans(color: Colors.white70),
                  ),
                ),
                data: (allPokemons) {
                  final favorites = allPokemons
                      .where((p) => favoriteIds.contains(p.id))
                      .toList();

                  if (favorites.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 60,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No favorites yet!',
                              style: GoogleFonts.pixelifySans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the ❤️ icon on any Pokémon card to add them to your team.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.pixelifySans(
                                fontSize: 13,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    itemCount: favorites.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final pokemon = favorites[index];
                      final nickname = nicknames[pokemon.id];
                      final cardColor = getTypeColor(pokemon.primaryType);

                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () =>
                              showNicknameDialog(context, ref, pokemon),
                          child: Row(
                            children: [
                              // Sprite image
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: Image.network(
                                  pokemon.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.catching_pokemon,
                                        size: 36,
                                        color: Colors.white70,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Name, Nickname & Types
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            pokemon.formattedName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.pixelifySans(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          pokemon.formattedId,
                                          style: GoogleFonts.pixelifySans(
                                            fontSize: 11,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (nickname != null && nickname.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 2.0,
                                        ),
                                        child: Text(
                                          '"$nickname"',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.pixelifySans(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: const Color(0xFFFFF3E0),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 2,
                                      children: pokemon.types.map((type) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.25,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            type.toUpperCase(),
                                            style: GoogleFonts.pixelifySans(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),

                              // Compact Action Buttons
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    iconSize: 20,
                                    icon: const Icon(
                                      Icons.edit_note,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      showNicknameDialog(context, ref, pokemon);
                                    },
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    iconSize: 18,
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(favoritesProvider.notifier)
                                          .toggleFavorite(pokemon.id);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
