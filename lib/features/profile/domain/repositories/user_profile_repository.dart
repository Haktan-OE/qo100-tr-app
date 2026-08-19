import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';

abstract interface class UserProfileRepository {
  Future<UserProfile?> getCurrentUserProfile();

  Stream<UserProfile?> watchCurrentUserProfile();
}
