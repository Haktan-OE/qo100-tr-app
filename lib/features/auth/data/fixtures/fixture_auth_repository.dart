import 'dart:async';

import 'package:qo100_tr/features/auth/domain/entities/auth_user.dart';
import 'package:qo100_tr/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:qo100_tr/features/auth/domain/repositories/auth_repository.dart';

/// Development credentials: operator@qo100.tr / fixture-password.
class FixtureAuthRepository implements AuthRepository {
  FixtureAuthRepository({AuthUser? initialUser}) : _currentUser = initialUser;

  static const existingEmail = 'operator@qo100.tr';
  static const existingPassword = 'fixture-password';
  static const existingUser = AuthUser(
    id: 'fixture-user-current',
    email: existingEmail,
  );

  AuthUser? _currentUser;
  final Set<String> _registeredEmails = {existingEmail};
  final StreamController<AuthUser?> _changes = StreamController.broadcast();
  int _nextUser = 1;

  @override
  Future<AuthUser?> getCurrentUser() async => _currentUser;

  @override
  Stream<AuthUser?> watchAuthUser() => Stream.multi((listener) {
    listener.add(_currentUser);
    final subscription = _changes.stream.listen(
      listener.add,
      onError: listener.addError,
      onDone: listener.close,
    );
    listener.onCancel = subscription.cancel;
  });

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    if (email.trim().toLowerCase() != existingEmail ||
        password != existingPassword) {
      throw InvalidCredentialsException();
    }
    _currentUser = existingUser;
    _changes.add(_currentUser);
    return existingUser;
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_registeredEmails.contains(normalizedEmail)) {
      throw DuplicateAccountException();
    }
    _registeredEmails.add(normalizedEmail);
    final user = AuthUser(
      id: 'fixture-user-new-${_nextUser++}',
      email: normalizedEmail,
    );
    _currentUser = user;
    _changes.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _changes.add(null);
  }

  Future<void> dispose() => _changes.close();
}
