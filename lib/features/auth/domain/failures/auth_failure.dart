import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failure.freezed.dart';

@freezed
class AuthFailure with _$AuthFailure {
  const factory AuthFailure({
    required String code,
    String? message,
  }) = _AuthFailure;

  factory AuthFailure.serverError([String? message]) => AuthFailure(
    code: 'SERVER_ERROR',
    message: message ?? 'Server error occurred',
  );

  factory AuthFailure.networkError([String? message]) => AuthFailure(
    code: 'NETWORK_ERROR',
    message: message ?? 'Network error occurred',
  );

  factory AuthFailure.invalidCredentials([String? message]) => AuthFailure(
    code: 'INVALID_CREDENTIALS',
    message: message ?? 'Invalid credentials',
  );

  factory AuthFailure.userNotFound([String? message]) => AuthFailure(
    code: 'USER_NOT_FOUND',
    message: message ?? 'User not found',
  );

  factory AuthFailure.userDisabled([String? message]) => AuthFailure(
    code: 'USER_DISABLED',
    message: message ?? 'User has been disabled',
  );

  factory AuthFailure.tooManyRequests([String? message]) => AuthFailure(
    code: 'TOO_MANY_REQUESTS',
    message: message ?? 'Too many requests',
  );

  factory AuthFailure.operationNotAllowed([String? message]) => AuthFailure(
    code: 'OPERATION_NOT_ALLOWED',
    message: message ?? 'Operation not allowed',
  );

  factory AuthFailure.emailAlreadyInUse([String? message]) => AuthFailure(
    code: 'EMAIL_ALREADY_IN_USE',
    message: message ?? 'Email already in use',
  );

  factory AuthFailure.weakPassword([String? message]) => AuthFailure(
    code: 'WEAK_PASSWORD',
    message: message ?? 'Password is too weak',
  );

  factory AuthFailure.invalidEmail([String? message]) => AuthFailure(
    code: 'INVALID_EMAIL',
    message: message ?? 'Invalid email',
  );

  factory AuthFailure.unknown([String? message]) => AuthFailure(
    code: 'UNKNOWN',
    message: message ?? 'An unknown error occurred',
  );
} 