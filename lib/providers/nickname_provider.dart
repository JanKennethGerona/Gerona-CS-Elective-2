import 'package:flutter_riverpod/flutter_riverpod.dart';

final nicknameProvider =
    StateNotifierProvider<NicknameNotifier, Map<int, String>>(
  (ref) => NicknameNotifier(),
);

class NicknameNotifier extends StateNotifier<Map<int, String>> {
  NicknameNotifier() : super({});

  void setNickname(int pokemonId, String nickname) {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      removeNickname(pokemonId);
      return;
    }
    state = {...state, pokemonId: trimmed};
  }

  void removeNickname(int pokemonId) {
    if (!state.containsKey(pokemonId)) return;
    final updated = Map<int, String>.from(state)..remove(pokemonId);
    state = updated;
  }

  String? getNickname(int pokemonId) => state[pokemonId];
}
