class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String? ?? '';
    final segments =
        Uri.parse(url).pathSegments.where((s) => s.isNotEmpty).toList();
    final id = segments.isEmpty ? null : int.tryParse(segments.last);

    if (id == null) {
      throw FormatException('Invalid Pokémon URL: "$url"');
    }

    return Pokemon(
      id: id,
      name: json['name'] as String,
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      types: const [],
    );
  }

  factory Pokemon.fromListJson(Map<String, dynamic> json) =>
      Pokemon.fromJson(json);

  /// Enrich an existing Pokemon with type data
  Pokemon copyWithTypes(List<String> types) {
    return Pokemon(
      id: id,
      name: name,
      imageUrl: imageUrl,
      types: types,
    );
  }

  /// "pikachu" -> "Pikachu"
  String get formattedName =>
      name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);

  /// 25 -> "#025"
  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  /// Primary type (fallback to 'normal' if types is empty)
  String get primaryType =>
      types.isNotEmpty ? types.first.toLowerCase() : 'normal';
}
