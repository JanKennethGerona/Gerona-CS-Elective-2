import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pokemon_providers.dart';
import '../providers/type_filter_provider.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/favorites_panel.dart';
import '../widgets/loading_view.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/type_filter_bar.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  bool _isFavoritesOpen = false;

  void _toggleFavorites() {
    setState(() {
      _isFavoritesOpen = !_isFavoritesOpen;
    });
  }

  void _closeFavorites() {
    if (_isFavoritesOpen) {
      setState(() {
        _isFavoritesOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const pokedexRed = Color(0xFFCE3A47);
    final filteredAsync = ref.watch(filteredPokemonProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = (screenWidth * 0.85).clamp(300.0, 420.0);

    return Scaffold(
      backgroundColor: const Color(0xFF242426),
      appBar: AppBar(
        backgroundColor: pokedexRed,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Pokedex',
          style: GoogleFonts.pixelifySans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Main Page Content ──
          Column(
            children: [
              // Type Filter Bar
              const TypeFilterBar(),

              // Pokémon Grid / Content
              Expanded(
                child: filteredAsync.when(
                  loading: () => const LoadingView(),
                  error: (err, _) => ErrorView(
                    message: err.toString().replaceFirst('Exception: ', ''),
                    onRetry: () =>
                        ref.read(pokemonListProvider.notifier).refresh(),
                  ),
                  data: (pokemons) {
                    if (pokemons.isEmpty) {
                      return const EmptyView(
                        message: 'No Pokémon match the selected type.',
                      );
                    }

                    return RefreshIndicator(
                      color: pokedexRed,
                      onRefresh: () =>
                          ref.read(pokemonListProvider.notifier).refresh(),
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.73,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: pokemons.length,
                        itemBuilder: (context, index) {
                          return PokemonCard(pokemon: pokemons[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // ── Dimmed Backdrop with Fade Transition ──
          IgnorePointer(
            ignoring: !_isFavoritesOpen,
            child: AnimatedOpacity(
              opacity: _isFavoritesOpen ? 0.6 : 0.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeFavorites,
                child: Container(color: Colors.black),
              ),
            ),
          ),

          // ── Sliding Favorites Panel with White Right Outline ──
          AnimatedPositioned(
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            left: _isFavoritesOpen ? 0 : -panelWidth,
            top: 0,
            bottom: 0,
            width: panelWidth,
            child: FavoritesSidePanel(onClose: _closeFavorites),
          ),

          // ── Sliding Bell Button on Edge (Guaranteed Clickable & Perfectly Aligned) ──
          AnimatedPositioned(
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            left: _isFavoritesOpen ? panelWidth - 2 : 0,
            top: 85,
            child: FavoritesSideTab(onTap: _toggleFavorites),
          ),
        ],
      ),
    );
  }
}
