import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_flutter_ui/models/pokemon.dart';
import 'package:my_first_flutter_ui/providers/pokemon_provider.dart';
import 'package:my_first_flutter_ui/services/pokemon_service.dart';

class FakePokemonService extends PokemonService {
  FakePokemonService(this.responses);

  final List<Object> responses;
  int calls = 0;

  @override
  Future<List<Pokemon>> fetchPokemon({int limit = 30}) async {
    final response = responses[calls++];
    if (response is Object Function()) return response();
    if (response is Exception) throw response;
    return response as List<Pokemon>;
  }
}

Pokemon pokemon(int id) => Pokemon(
      id: id,
      name: 'pokemon$id',
      imageUrl: 'https://example.com/$id.png',
    );

void main() {
  test('fetches data and exposes success state', () async {
    final service = FakePokemonService([
      [pokemon(1), pokemon(2)],
    ]);
    final provider = PokemonProvider(service: service);

    await provider.fetchPokemon();

    expect(provider.status, PokemonStatus.success);
    expect(provider.pokemonList.length, 2);
    expect(service.calls, 1);
  });

  test('keeps old data visible while refreshing', () async {
    final service = FakePokemonService([
      [pokemon(1)],
      [pokemon(2)],
    ]);
    final provider = PokemonProvider(service: service);

    await provider.fetchPokemon();
    final refresh = provider.fetchPokemon();

    expect(provider.isRefreshing, isTrue);
    expect(provider.pokemonList.single.id, 1);

    await refresh;

    expect(provider.status, PokemonStatus.success);
    expect(provider.pokemonList.single.id, 2);
  });

  test('preserves data when a refresh fails', () async {
    final service = FakePokemonService([
      [pokemon(1)],
      Exception('offline'),
    ]);
    final provider = PokemonProvider(service: service);

    await provider.fetchPokemon();
    await provider.fetchPokemon();

    expect(provider.status, PokemonStatus.error);
    expect(provider.pokemonList.single.id, 1);
    expect(provider.errorMessage, 'offline');
  });
}
