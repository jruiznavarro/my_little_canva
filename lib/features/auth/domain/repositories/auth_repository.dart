import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:my_little_canva/features/auth/domain/entities/user.dart' as app_user;
import '../failures/auth_failure.dart';

abstract class AuthRepository {
  Stream<firebase_auth.User?> get authStateChanges;
  Future<void> signInWithGoogle();
  Future<void> signOut();
} 