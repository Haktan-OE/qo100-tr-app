import 'package:flutter_test/flutter_test.dart';
import 'package:qo100_tr/features/profile/data/fixtures/fixture_user_profile_repository.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';

void main() {
  test('returns and watches the fixture current user profile', () async {
    final repository = FixtureUserProfileRepository();

    final profile = await repository.getCurrentUserProfile();

    expect(profile?.callsign, 'TA0AAA');
    expect(profile?.role, UserRole.member);
    await expectLater(
      repository.watchCurrentUserProfile(),
      emits(same(profile)),
    );
  });
}
