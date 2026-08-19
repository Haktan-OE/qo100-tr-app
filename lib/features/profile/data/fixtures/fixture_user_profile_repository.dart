import 'dart:async';

import 'package:qo100_tr/features/profile/data/fixtures/profile_fixtures.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';
import 'package:qo100_tr/features/profile/domain/repositories/user_profile_repository.dart';

class FixtureUserProfileRepository implements UserProfileRepository {
  FixtureUserProfileRepository({UserProfile? currentUser})
    : _currentUser = currentUser ?? ProfileFixtures.currentUser;

  FixtureUserProfileRepository.empty() : _currentUser = null;

  UserProfile? _currentUser;
  final StreamController<UserProfile?> _controller =
      StreamController<UserProfile?>.broadcast();

  @override
  Future<UserProfile?> getCurrentUserProfile() async => _currentUser;

  @override
  Stream<UserProfile?> watchCurrentUserProfile() => Stream.multi((listener) {
    listener.add(_currentUser);
    final subscription = _controller.stream.listen(
      listener.add,
      onError: listener.addError,
      onDone: listener.close,
    );
    listener.onCancel = subscription.cancel;
  });

  @override
  Future<UserProfile> updateCurrentUserProfile(UserProfile profile) async {
    _currentUser = profile;
    _controller.add(profile);
    return profile;
  }

  Future<void> dispose() => _controller.close();
}
