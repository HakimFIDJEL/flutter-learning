import 'package:learning_dart/services/auth/auth_exceptions.dart';
import 'package:learning_dart/services/auth/auth_provider.dart';
import 'package:learning_dart/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', () {
      expect(provider.logout(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('Should be able to initialize', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('Create user should delegate to login', () async {
      expect(
        () async => await provider.register(
          email: 'foo@bar.com',
          password: 'password',
        ),
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      expect(
        () async => await provider.register(
          email: 'someone@bar.com',
          password: 'foobar',
        ),
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );

      final user = await provider.register(
        email: 'foo',
        password: 'bar',
      );

      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Login user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to logout and login again', () async {
      await provider.logout();
      await provider.login(email: 'email', password: 'password');

      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _currentUser;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Get current User
  @override
  AuthUser? get currentUser => _currentUser;

  // Initialize
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  // Login
  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    if (!_isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _currentUser = user;
    return Future.value(user);
  }

  // Logout
  @override
  Future<void> logout() async {
    if (!_isInitialized) throw NotInitializedException();
    if (_currentUser == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = null;
  }

  // Register
  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return login(email: email, password: password);
  }

  // Send Email Verification
  @override
  Future<void> sendEmailVerification() async {
    if (!_isInitialized) throw NotInitializedException();
    final user = _currentUser;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _currentUser = newUser;
  }
}
