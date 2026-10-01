import 'package:flutter/material.dart';
import 'screens/pokedex_screen.dart';

void main() {
  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokédex',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF242426),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCE3A47),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const PokedexScreen(),
    );
  }
}