import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';
import 'package:qo100_tr/features/participation/domain/entities/community_session.dart';

/// Local-only sample data.
///
/// Session frequency and time values intentionally demonstrate both discovery
/// sources. They are not canonical production defaults or business rules.
abstract final class ParticipationFixtures {
  static final activeSession = CommunitySession(
    id: 'fixture-session-active',
    title: 'TA-NET 777 Örnek Haftalık Buluşma',
    startAt: DateTime.utc(2026, 8, 23, 18),
    frequencyMHz: 10489.777,
    scenarioNote: 'Fixture oturumu — saat ve frekans yapılandırılabilir.',
    isActive: true,
  );

  static final sessions = List<CommunitySession>.unmodifiable([
    activeSession,
    CommunitySession(
      id: 'fixture-session-previous-1',
      title: 'TA-NET 777 Örnek Buluşma',
      startAt: DateTime.utc(2026, 8, 16, 20),
      frequencyMHz: 10489.500,
      scenarioNote: 'Alternatif konsept değerlerini gösteren fixture.',
      isActive: false,
    ),
    CommunitySession(
      id: 'fixture-session-previous-2',
      title: 'TA-NET 777 Örnek Buluşma',
      startAt: DateTime.utc(2026, 8, 9, 18),
      frequencyMHz: 10489.777,
      isActive: false,
    ),
  ]);

  static final checkIns = List<CheckIn>.unmodifiable([
    CheckIn(
      id: 'fixture-check-in-direct',
      sessionId: activeSession.id,
      userId: 'fixture-user-current',
      callsign: 'TA0AAA',
      participationType: ParticipationType.direct,
      timestamp: DateTime.utc(2026, 8, 23, 18, 3),
    ),
    CheckIn(
      id: 'fixture-check-in-swl',
      sessionId: activeSession.id,
      userId: 'fixture-user-swl',
      callsign: 'TA0SWL',
      participationType: ParticipationType.swl,
      timestamp: DateTime.utc(2026, 8, 23, 18, 5),
    ),
  ]);
}
