import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {
  static const _baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  /// Fetch list of Pokémon (names + URLs)
  Future<List<Pokemon>> fetchPokemon({int limit = 30}) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl?limit=$limit'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load Pokémon (HTTP ${response.statusCode}).');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results
          .map((e) => Pokemon.fromListJson(e as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on SocketException {
      throw Exception('No internet connection.');
    } on http.ClientException {
      throw Exception('No internet connection.');
    }
  }

  /// Alias for compatibility
  Future<List<Pokemon>> fetchPokemons({int limit = 30}) =>
      fetchPokemon(limit: limit);

  /// Fetch type names for a single Pokémon
  Future<List<String>> fetchPokemonTypes(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final typesJson = data['types'] as List<dynamic>? ?? [];
      return typesJson
          .map((t) => (t['type']['name'] as String).toLowerCase())
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetch Pokémon list and enrich with type information concurrently
  Future<List<Pokemon>> fetchPokemonsWithTypes({int limit = 30}) async {
    final pokemons = await fetchPokemon(limit: limit);

    final enriched = await Future.wait(
      pokemons.map((pokemon) async {
        if (pokemon.types.isNotEmpty) return pokemon;
        final types = await fetchPokemonTypes(pokemon.id);
        return pokemon.copyWithTypes(types);
      }),
    );

    return enriched;
  }
}
