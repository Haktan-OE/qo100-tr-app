import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qo100_tr/features/auth/data/firebase/firebase_auth_exception_mapper.dart';
import 'package:qo100_tr/features/auth/data/firebase/firebase_auth_user_mapper.dart';
import 'package:qo100_tr/features/auth/domain/exceptions/auth_exceptions.dart';

void main() {
  test('maps Firebase user identity to backend-agnostic AuthUser', () {
    final user = FirebaseAuthUserMapper.fromIdentity(
      id: 'firebase-uid',
      email: 'operator@example.com',
    );

    expect(user.id, 'firebase-uid');
    expect(user.email, 'operator@example.com');
  });

  test('maps a missing Firebase email without exposing SDK types', () {
    final user = FirebaseAuthUserMapper.fromIdentity(
      id: 'firebase-uid',
      email: null,
    );

    expect(user.email, isEmpty);
  });

  test('maps Firebase auth codes to domain exceptions', () {
    Exception map(String code) =>
        FirebaseAuthExceptionMapper.map(FirebaseAuthException(code: code));

    expect(map('invalid-credential'), isA<InvalidCredentialsException>());
    expect(map('wrong-password'), isA<InvalidCredentialsException>());
    expect(map('email-already-in-use'), isA<DuplicateAccountException>());
    expect(map('weak-password'), isA<WeakPasswordException>());
    expect(map('network-request-failed'), isA<AuthInfrastructureException>());
    expect(map('unexpected-code'), isA<AuthInfrastructureException>());
  });
}
