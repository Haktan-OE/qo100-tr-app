import 'package:firebase_auth/firebase_auth.dart';
import 'package:qo100_tr/features/auth/domain/exceptions/auth_exceptions.dart';

abstract final class FirebaseAuthExceptionMapper {
  static Exception map(FirebaseAuthException exception) =>
      switch (exception.code) {
        'invalid-credential' ||
        'user-not-found' ||
        'wrong-password' ||
        'invalid-email' => InvalidCredentialsException(),
        'email-already-in-use' => DuplicateAccountException(),
        'weak-password' => WeakPasswordException(),
        _ => AuthInfrastructureException(),
      };
}
