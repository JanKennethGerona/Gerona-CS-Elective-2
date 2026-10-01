import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/pokemon_card.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final PokemonService _service = PokemonService();
  late Future<List<Pokemon>> _future;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchPokemons();
  }

  void _retry() {
    setState(() {
      _future = _service.fetchPokemons();
    });
  }

  @override
  Widget build(BuildContext context) {
    const pokedexRed = Color(0xFFCE3A47);
    const darkBackground = Color(0xFF242426);
    const bottomBarBackground = Color(0xFF1B1B1E);

    return Scaffold(
      backgroundColor: darkBackground,
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
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(
              message:
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
              onRetry: _retry,
            );
          }
          if (!snapshot.hasData) {
            return const EmptyView();
          }
          final pokemons = snapshot.data!;
          if (pokemons.isEmpty) {
            return const EmptyView();
          }
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.86,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: pokemons.length,
            itemBuilder: (context, i) => PokemonCard(pokemon: pokemons[i]),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 64,
        color: bottomBarBackground,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 0;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _selectedTabIndex == 0
                          ? pokedexRed
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pokedex',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _selectedTabIndex == 0
                          ? pokedexRed
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _selectedTabIndex == 1
                          ? Colors.grey[400]
                          : Colors.grey[700],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Items',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _selectedTabIndex == 1
                          ? Colors.white
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
