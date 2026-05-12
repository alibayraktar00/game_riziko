enum UserRole {
  admin,
  player,
}

class User {
  final String id;
  final UserRole role;
  final String? displayName;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.role,
    this.displayName,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    UserRole? role,
    String? displayName,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role.name,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      role: UserRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => UserRole.player,
      ),
      displayName: map['displayName'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
