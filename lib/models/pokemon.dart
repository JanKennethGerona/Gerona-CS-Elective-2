class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
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
    );
  }

  /// "pikachu" -> "Pikachu"
  String get formattedName =>
      name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);

  /// 25 -> "#025"
  String get formattedId => '#${id.toString().padLeft(3, '0')}';
}
