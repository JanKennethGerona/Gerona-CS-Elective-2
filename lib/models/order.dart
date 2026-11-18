class OrderItem {
  final int id;
  final DateTime createdAt;
  final int orderId;
  final int? productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  const OrderItem({
    required this.id,
    required this.createdAt,
    required this.orderId,
    this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get subtotal => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      orderId: json['order_id'] is int
          ? json['order_id'] as int
          : int.parse(json['order_id'].toString()),
      productId: json['product_id'] != null
          ? (json['product_id'] is int
              ? json['product_id'] as int
              : int.tryParse(json['product_id'].toString()))
          : null,
      productName: json['product_name'] as String? ?? 'Product',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'unit_price': unitPrice,
      'quantity': quantity,
    };
  }
}

class OrderModel {
  final int id;
  final DateTime createdAt;
  final String? userId;
  final String status;
  final double total;
  final List<OrderItem> items;
  final String? userEmail;

  const OrderModel({
    required this.id,
    required this.createdAt,
    this.userId,
    required this.status,
    required this.total,
    this.items = const [],
    this.userEmail,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItem> itemsList = [];
    if (json['order_items'] != null && json['order_items'] is List) {
      itemsList = (json['order_items'] as List)
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    String? email;
    if (json['profiles'] != null && json['profiles'] is Map) {
      email = json['profiles']['email'] as String?;
    }

    return OrderModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      userId: json['user_id'] as String?,
      status: json['status'] as String? ?? 'done',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      items: itemsList,
      userEmail: email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'status': status,
      'total': total,
      'order_items': items.map((i) => i.toJson()).toList(),
    };
  }
}
