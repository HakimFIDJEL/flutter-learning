import 'package:learning_dart/services/auth/firebase_auth_provider.dart';

import 'auth_provider.dart';
import 'auth_user.dart';

class AuthService implements AuthProvider {
  final AuthProvider _provider;
  const AuthService(this._provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<void> initialize() => _provider.initialize();

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) =>
      _provider.login(
        email: email,
        password: password,
      );

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) =>
      _provider.register(
        email: email,
        password: password,
      );
  @override
  AuthUser? get currentUser => _provider.currentUser;

  @override
  Future<void> logout() => _provider.logout();

  @override
  Future<void> sendEmailVerification() => _provider.sendEmailVerification();
}
