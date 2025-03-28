import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dartz/dartz.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

part 'sign_out.g.dart';

@riverpod
SignOut signOut(SignOutRef ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOut(repository);
}

class SignOut {
  final AuthRepository _repository;

  SignOut(this._repository);

  Future<Either<AuthFailure, void>> call() async {
    return _repository.signOut();
  }
} 