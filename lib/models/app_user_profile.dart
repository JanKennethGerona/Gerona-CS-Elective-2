class AppUserProfile {
  final String id;
  final DateTime createdAt;
  final String email;
  final String firstname;
  final String lastname;
  final int roleId;
  final String roleName;

  const AppUserProfile({
    required this.id,
    required this.createdAt,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.roleId,
    this.roleName = 'customer',
  });

  bool get isAdmin => roleName.toLowerCase() == 'admin';

  String get displayName {
    final full = '$firstname $lastname'.trim();
    if (full.isNotEmpty) return full;
    if (email.isNotEmpty) return email.split('@').first;
    return 'Builder';
  }

  factory AppUserProfile.fromJson(Map<String, dynamic> json) {
    String rName = 'customer';
    if (json['roles'] != null && json['roles'] is Map) {
      rName = (json['roles']['role'] as String?) ?? 'customer';
    } else if (json['role_name'] != null) {
      rName = json['role_name'] as String;
    }

    return AppUserProfile(
      id: json['id'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      email: json['email'] as String? ?? '',
      firstname: json['firstname'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
      roleId: json['role_id'] is int
          ? json['role_id'] as int
          : int.tryParse(json['role_id']?.toString() ?? '1') ?? 1,
      roleName: rName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'role_id': roleId,
    };
  }

  AppUserProfile copyWith({
    String? firstname,
    String? lastname,
    String? email,
    int? roleId,
    String? roleName,
  }) {
    return AppUserProfile(
      id: id,
      createdAt: createdAt,
      email: email ?? this.email,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
    );
  }
}
