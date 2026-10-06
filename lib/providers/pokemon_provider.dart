import 'package:flutter/foundation.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

enum PokemonStatus { initial, loading, success, error }

class PokemonProvider extends ChangeNotifier {
  PokemonProvider({PokemonService? service})
      : _service = service ?? PokemonService();

  final PokemonService _service;
  PokemonStatus _status = PokemonStatus.initial;
  List<Pokemon> _pokemonList = const [];
  String? _errorMessage;
  Pokemon? _selectedPokemon;

  PokemonStatus get status => _status;
  List<Pokemon> get pokemonList => List.unmodifiable(_pokemonList);
  String? get errorMessage => _errorMessage;
  Pokemon? get selectedPokemon => _selectedPokemon;
  bool get isEmpty => _status == PokemonStatus.success && _pokemonList.isEmpty;
  bool get hasData => _pokemonList.isNotEmpty;
  bool get isRefreshing => _status == PokemonStatus.loading && hasData;

  Future<void> fetchPokemon() async {
    if (_status == PokemonStatus.loading) return;

    _status = PokemonStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _pokemonList = await _service.fetchPokemon(limit: 30);
      _status = PokemonStatus.success;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      _status = PokemonStatus.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => fetchPokemon();

  void selectPokemon(Pokemon pokemon) {
    _selectedPokemon = pokemon;
    notifyListeners();
  }
}
