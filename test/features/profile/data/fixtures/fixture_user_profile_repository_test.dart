import 'package:flutter_test/flutter_test.dart';
import 'package:qo100_tr/features/profile/data/fixtures/fixture_user_profile_repository.dart';
import 'package:qo100_tr/features/profile/data/fixtures/profile_fixtures.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';

void main() {
  test('returns and watches the fixture current user profile', () async {
    final repository = FixtureUserProfileRepository();
    addTearDown(repository.dispose);

    final profile = await repository.getCurrentUserProfile();

    expect(profile?.callsign, 'TA0AAA');
    expect(profile?.role, UserRole.member);
    await expectLater(
      repository.watchCurrentUserProfile(),
      emits(same(profile)),
    );
  });

  test('updates and emits the current profile', () async {
    final repository = FixtureUserProfileRepository();
    addTearDown(repository.dispose);
    final updated = ProfileFixtures.currentUser.copyWith(
      callsign: 'TA1NEW',
      city: 'İstanbul',
    );
    final emissions = repository.watchCurrentUserProfile().take(2).toList();

    expect(await repository.updateCurrentUserProfile(updated), same(updated));

    expect(await emissions, [ProfileFixtures.currentUser, updated]);
    expect(await repository.getCurrentUserProfile(), same(updated));
  });

  test('repository instances do not share mutable profile state', () async {
    final first = FixtureUserProfileRepository();
    final second = FixtureUserProfileRepository();
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    await first.updateCurrentUserProfile(
      ProfileFixtures.currentUser.copyWith(callsign: 'TA1ONLY'),
    );

    expect((await second.getCurrentUserProfile())?.callsign, 'TA0AAA');
  });
}
