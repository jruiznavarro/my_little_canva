import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dartz/dartz.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../entities/user.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

part 'sign_in_with_google.g.dart';

@riverpod
SignInWithGoogle signInWithGoogle(SignInWithGoogleRef ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithGoogle(repository);
}

class SignInWithGoogle {
  final AuthRepository _repository;

  SignInWithGoogle(this._repository);

  Future<Either<AuthFailure, User>> call() async {
    return _repository.signInWithGoogle();
  }
} 