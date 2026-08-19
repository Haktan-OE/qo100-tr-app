import 'package:qo100_tr/features/auth/domain/entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthUser?> getCurrentUser();
  Stream<AuthUser?> watchAuthUser();
  Future<AuthUser> signIn({required String email, required String password});
  Future<AuthUser> register({required String email, required String password});
  Future<void> signOut();
}
