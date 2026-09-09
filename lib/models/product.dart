class Product {
  final String id;
  final String name;
  final String imageUrl;
  final String setNumber;
  final String pieceCount;
  final double price;
  final String description;
  final String ageRange;
  final double rating;

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.setNumber,
    required this.pieceCount,
    required this.price,
    required this.description,
    this.ageRange = '18+',
    this.rating = 4.8,
  });
}
