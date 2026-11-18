class Category {
  final int id;
  final DateTime createdAt;
  final String name;

  const Category({
    required this.id,
    required this.createdAt,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'name': name,
    };
  }

  Category copyWith({String? name}) {
    return Category(
      id: id,
      createdAt: createdAt,
      name: name ?? this.name,
    );
  }
}
