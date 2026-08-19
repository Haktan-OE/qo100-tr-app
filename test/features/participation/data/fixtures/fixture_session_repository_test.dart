import 'package:flutter_test/flutter_test.dart';
import 'package:qo100_tr/features/participation/data/fixtures/fixture_session_repository.dart';
import 'package:qo100_tr/features/participation/domain/entities/community_session.dart';

void main() {
  test('watches the active fixture session', () async {
    final repository = FixtureSessionRepository();

    await expectLater(
      repository.watchCurrentSession(),
      emits(
        isA<CommunitySession>()
            .having((session) => session.isActive, 'isActive', isTrue)
            .having(
              (session) => session.scenarioNote,
              'fixture marker',
              contains('Fixture'),
            ),
      ),
    );
  });

  test('returns recent sessions newest first', () async {
    final repository = FixtureSessionRepository();

    final sessions = await repository.getRecentSessions();

    expect(sessions, hasLength(3));
    expect(sessions.first.isActive, isTrue);
    for (var index = 1; index < sessions.length; index++) {
      expect(
        sessions[index - 1].startAt.isAfter(sessions[index].startAt),
        isTrue,
      );
    }
  });
}
