import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

abstract class AuthRepository {
  Stream<firebase_auth.User?> get authStateChanges;
  Future<void> signInWithGoogle();
  Future<void> signOut();
} 