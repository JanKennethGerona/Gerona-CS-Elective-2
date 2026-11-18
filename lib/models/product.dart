class Product {
  final int id;
  final DateTime createdAt;
  final String name;
  final String? description;
  final int stock;
  final String? imageUrl;
  final int categoryId;
  final double price;
  final String? categoryName;

  const Product({
    required this.id,
    required this.createdAt,
    required this.name,
    this.description,
    required this.stock,
    this.imageUrl,
    required this.categoryId,
    required this.price,
    this.categoryName,
  });

  bool get isOutOfStock => stock <= 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    String? catName;
    if (json['categories'] != null && json['categories'] is Map) {
      catName = json['categories']['name'] as String?;
    } else if (json['category_name'] != null) {
      catName = json['category_name'] as String?;
    }

    return Product(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      stock: json['stock'] is int ? json['stock'] as int : int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url'] as String?,
      categoryId: json['category_id'] is int
          ? json['category_id'] as int
          : int.tryParse(json['category_id']?.toString() ?? '1') ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      categoryName: catName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      if (description != null) 'description': description,
      'stock': stock,
      if (imageUrl != null) 'image_url': imageUrl,
      'category_id': categoryId,
      'price': price,
    };
  }

  Product copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    String? description,
    int? stock,
    String? imageUrl,
    int? categoryId,
    double? price,
    String? categoryName,
  }) {
    return Product(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
