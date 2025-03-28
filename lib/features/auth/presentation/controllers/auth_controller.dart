import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_little_canva/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:my_little_canva/features/auth/data/services/auth_service.dart';
import 'package:my_little_canva/features/auth/domain/entities/user_role.dart';
import 'package:my_little_canva/features/auth/domain/repositories/auth_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  return AuthController(authRepository, authService);
});

final authStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  final AuthService _authService;

  AuthController(this._authRepository, this._authService) : super(const AsyncValue.data(null));

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signInWithGoogle();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setUserRole(String uid, UserRole role) async {
    state = const AsyncValue.loading();
    try {
      await _authService.setUserRole(uid, role);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<UserRole?> getUserRole() async {
    try {
      return await _authService.getUserRole();
    } catch (error) {
      return null;
    }
  }
} 