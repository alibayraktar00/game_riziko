import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_role.dart';

class UserNotifier extends Notifier<User?> {
  @override
  User? build() {
    return null; // Başlangıçta kullanıcı yok
  }

  void setUserRole(UserRole role) {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: role,
      displayName: role == UserRole.admin ? 'Yönetici' : 'Oyuncu',
      createdAt: DateTime.now(),
    );
    state = user;
  }

  void logout() {
    state = null;
  }
}

final userProvider = NotifierProvider<UserNotifier, User?>(() {
  return UserNotifier();
});
