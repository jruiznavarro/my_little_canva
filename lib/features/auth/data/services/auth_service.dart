import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_role.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  Future<UserRole?> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final idTokenResult = await user.getIdTokenResult();
      final role = idTokenResult.claims?['role'] as String?;
      
      if (role == null) return null;
      return UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.$role',
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> setUserRole(String uid, UserRole role) async {
    try {
      await _functions.httpsCallable('setUserRole').call({
        'uid': uid,
        'role': role.toString().split('.').last,
      });
    } catch (e) {
      rethrow;
    }
  }
} 