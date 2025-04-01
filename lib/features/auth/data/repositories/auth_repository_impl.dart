import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepositoryImpl(authService: authService);
});

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final AuthService _authService;

  AuthRepositoryImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    required AuthService authService,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _authService = authService;

  @override
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<void> signInWithGoogle() async {
    try {
      debugPrint('Iniciando proceso de Google Sign In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Usuario canceló el inicio de sesión con Google');
        throw Exception('Inicio de sesión cancelado por el usuario');
      }

      debugPrint('Usuario seleccionado: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final firebase_auth.OAuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('Obteniendo credenciales de Firebase...');
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      debugPrint('Usuario autenticado en Firebase: ${userCredential.user?.uid}');
      // Crear o actualizar el documento del usuario en Firestore
      if (userCredential.user != null) {
        debugPrint('Creando/actualizando documento en Firestore...');
        await _authService.createOrUpdateUser(userCredential.user!);
        debugPrint('Documento creado/actualizado exitosamente');
      }
    } catch (e) {
      debugPrint('Error en signInWithGoogle: ${e.toString()}');
      throw Exception('Error al iniciar sesión con Google: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }

  AuthFailure _handleFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-disabled':
        return AuthFailure.userDisabled(e.message);
      case 'user-not-found':
        return AuthFailure.userNotFound(e.message);
      case 'operation-not-allowed':
        return AuthFailure.operationNotAllowed(e.message);
      case 'invalid-credential':
        return AuthFailure.invalidCredentials(e.message);
      default:
        return AuthFailure.unknown(e.message);
    }
  }
} 