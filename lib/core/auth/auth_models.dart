import 'package:flutter/foundation.dart';

enum UserRole {
  none,
  viewer,
  editor,
  admin;

  static UserRole parse(Object? value) => values.firstWhere(
    (role) => role.name == value,
    orElse: () => UserRole.none,
  );

  bool get canRead => this != UserRole.none;
  bool get canWrite => this == UserRole.editor || this == UserRole.admin;
  bool get canDelete => this == UserRole.admin;
}

@immutable
class SessionUser {
  const SessionUser({
    required this.name,
    required this.email,
    this.id = '',
    this.role = UserRole.none,
    this.needsPasswordReset = false,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool needsPasswordReset;

  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
      .join();
}

enum AuthFailureCode {
  invalidCredentials,
  unconfirmed,
  weakPassword,
  rateLimited,
  connection,
  unavailable,
}

class AuthFailure implements Exception {
  const AuthFailure(this.code);
  final AuthFailureCode code;
}
