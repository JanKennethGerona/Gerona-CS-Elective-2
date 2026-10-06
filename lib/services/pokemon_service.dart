import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {
  static const _baseUrl = 'https://pokeapi.co/api/v2/pokemon';

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
          .map((e) => Pokemon.fromJson(e as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on SocketException {
      throw Exception('No internet connection.');
    } on http.ClientException {
      throw Exception('No internet connection.');
    }
  }
}
