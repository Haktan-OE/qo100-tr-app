import 'package:qo100_tr/features/participation/data/fixtures/participation_fixtures.dart';
import 'package:qo100_tr/features/participation/domain/entities/community_session.dart';
import 'package:qo100_tr/features/participation/domain/repositories/session_repository.dart';

class FixtureSessionRepository implements SessionRepository {
  FixtureSessionRepository({Iterable<CommunitySession>? sessions})
    : _sessions = List.of(sessions ?? ParticipationFixtures.sessions);

  final List<CommunitySession> _sessions;

  @override
  Stream<CommunitySession?> watchCurrentSession() {
    return Stream.value(_currentSession);
  }

  @override
  Future<List<CommunitySession>> getRecentSessions() async {
    final sessions = [..._sessions]
      ..sort((left, right) => right.startAt.compareTo(left.startAt));
    return List.unmodifiable(sessions);
  }

  CommunitySession? get _currentSession {
    for (final session in _sessions) {
      if (session.isActive) {
        return session;
      }
    }
    return null;
  }
}
