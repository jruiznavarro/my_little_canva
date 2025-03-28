enum UserRole {
  user,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'Usuario';
      case UserRole.admin:
        return 'Administrador';
    }
  }
} 