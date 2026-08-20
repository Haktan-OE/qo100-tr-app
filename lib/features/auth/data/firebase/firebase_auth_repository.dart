import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:qo100_tr/features/auth/data/firebase/firebase_auth_exception_mapper.dart';
import 'package:qo100_tr/features/auth/data/firebase/firebase_auth_user_mapper.dart';
import 'package:qo100_tr/features/auth/domain/entities/auth_user.dart';
import 'package:qo100_tr/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:qo100_tr/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final firebase.FirebaseAuth _auth;

  @override
  Future<AuthUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    return user == null ? null : FirebaseAuthUserMapper.fromFirebaseUser(user);
  }

  @override
  Stream<AuthUser?> watchAuthUser() => _auth.authStateChanges().map(
    (user) =>
        user == null ? null : FirebaseAuthUserMapper.fromFirebaseUser(user),
  );

  @override
  Future<AuthUser> signIn({required String email, required String password}) =>
      _authenticate(
        () =>
            _auth.signInWithEmailAndPassword(email: email, password: password),
      );

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) => _authenticate(
    () =>
        _auth.createUserWithEmailAndPassword(email: email, password: password),
  );

  Future<AuthUser> _authenticate(
    Future<firebase.UserCredential> Function() operation,
  ) async {
    try {
      final credential = await operation();
      final user = credential.user;
      if (user == null) throw AuthInfrastructureException();
      return FirebaseAuthUserMapper.fromFirebaseUser(user);
    } on firebase.FirebaseAuthException catch (error) {
      throw FirebaseAuthExceptionMapper.map(error);
    } on AuthInfrastructureException {
      rethrow;
    } on Object {
      throw AuthInfrastructureException();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on Object {
      throw AuthInfrastructureException();
    }
  }
}
