import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:qo100_tr/features/auth/domain/entities/auth_user.dart';

abstract final class FirebaseAuthUserMapper {
  static AuthUser fromFirebaseUser(firebase.User user) =>
      fromIdentity(id: user.uid, email: user.email);

  static AuthUser fromIdentity({required String id, required String? email}) {
    return AuthUser(id: id, email: email ?? '');
  }
}
