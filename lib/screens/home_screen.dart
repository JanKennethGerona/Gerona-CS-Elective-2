import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/pokemon_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const pokedexRed = Color(0xFFCE3A47);
    final provider = context.watch<PokemonProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF242426),
      appBar: AppBar(
        backgroundColor: pokedexRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Pokedex',
          style: GoogleFonts.pixelifySans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Pokémon',
            onPressed: provider.isRefreshing
                ? null
                : () => provider.fetchPokemon(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(PokemonProvider provider) {
    if (provider.status == PokemonStatus.initial ||
        (provider.status == PokemonStatus.loading && !provider.hasData)) {
      return const LoadingView();
    }

    if (provider.status == PokemonStatus.error) {
      return ErrorView(
        message: provider.errorMessage ?? 'Unable to load Pokémon.',
        onRetry: provider.fetchPokemon,
      );
    }

    if (provider.isEmpty) return const EmptyView();

    return RefreshIndicator(
      onRefresh: provider.fetchPokemon,
      child: const PokemonGrid(),
    );
  }
}
