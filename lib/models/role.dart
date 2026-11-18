class Role {
  final int id;
  final String role;
  final DateTime createdAt;
  final String? encodedBy;

  const Role({
    required this.id,
    required this.role,
    required this.createdAt,
    this.encodedBy,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      role: json['role'] as String? ?? 'customer',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      encodedBy: json['encoded_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      if (encodedBy != null) 'encoded_by': encodedBy,
    };
  }
}
