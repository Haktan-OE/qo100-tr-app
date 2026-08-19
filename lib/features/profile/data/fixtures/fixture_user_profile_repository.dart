import 'package:qo100_tr/features/profile/data/fixtures/profile_fixtures.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';
import 'package:qo100_tr/features/profile/domain/repositories/user_profile_repository.dart';

class FixtureUserProfileRepository implements UserProfileRepository {
  FixtureUserProfileRepository({UserProfile? currentUser})
    : _currentUser = currentUser ?? ProfileFixtures.currentUser;

  final UserProfile? _currentUser;

  @override
  Future<UserProfile?> getCurrentUserProfile() async => _currentUser;

  @override
  Stream<UserProfile?> watchCurrentUserProfile() => Stream.value(_currentUser);
}
