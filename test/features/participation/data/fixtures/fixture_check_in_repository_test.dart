import 'package:flutter_test/flutter_test.dart';
import 'package:qo100_tr/features/participation/data/fixtures/fixture_check_in_repository.dart';
import 'package:qo100_tr/features/participation/data/fixtures/participation_fixtures.dart';
import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';
import 'package:qo100_tr/features/participation/domain/exceptions/duplicate_check_in_exception.dart';

void main() {
  late FixtureCheckInRepository repository;

  setUp(() {
    repository = FixtureCheckInRepository(checkIns: const []);
  });

  tearDown(() async {
    await repository.dispose();
  });

  test('check-in stream emits the initial and submitted snapshots', () async {
    final checkIn = _checkIn(userId: 'user-1');
    final expectation = expectLater(
      repository.watchCheckIns(checkIn.sessionId),
      emitsInOrder([
        isEmpty,
        predicate<List<CheckIn>>(
          (checkIns) => checkIns.length == 1 && checkIns.single == checkIn,
        ),
      ]),
    );

    await repository.submitCheckIn(checkIn);

    await expectation;
  });

  test('successful check-in can be retrieved for the current user', () async {
    final checkIn = _checkIn(userId: 'user-1');

    final submitted = await repository.submitCheckIn(checkIn);
    final stored = await repository.getCurrentUserCheckIn(
      sessionId: checkIn.sessionId,
      userId: checkIn.userId,
    );

    expect(submitted, same(checkIn));
    expect(stored, same(checkIn));
  });

  test(
    'duplicate user and session check-in throws a domain exception',
    () async {
      final direct = _checkIn(userId: 'user-1');
      final swlDuplicate = _checkIn(
        id: 'check-in-2',
        userId: 'user-1',
        participationType: ParticipationType.swl,
      );
      await repository.submitCheckIn(direct);

      await expectLater(
        repository.submitCheckIn(swlDuplicate),
        throwsA(
          isA<DuplicateCheckInException>()
              .having((error) => error.sessionId, 'sessionId', direct.sessionId)
              .having((error) => error.userId, 'userId', direct.userId),
        ),
      );

      final checkIns = await repository.watchCheckIns(direct.sessionId).first;
      expect(checkIns, contains(same(direct)));
      expect(checkIns, hasLength(1));
    },
  );

  test('fixture data contains direct and SWL participation types', () async {
    final fixtureRepository = FixtureCheckInRepository();
    addTearDown(fixtureRepository.dispose);

    final checkIns = await fixtureRepository
        .watchCheckIns(ParticipationFixtures.activeSession.id)
        .first;

    expect(
      checkIns.map((checkIn) => checkIn.participationType),
      containsAll([ParticipationType.direct, ParticipationType.swl]),
    );
  });

  test('repository instances do not share mutable check-in state', () async {
    final otherRepository = FixtureCheckInRepository(checkIns: const []);
    addTearDown(otherRepository.dispose);
    final checkIn = _checkIn(userId: 'user-1');

    await repository.submitCheckIn(checkIn);

    expect(
      await repository.watchCheckIns(checkIn.sessionId).first,
      hasLength(1),
    );
    expect(
      await otherRepository.watchCheckIns(checkIn.sessionId).first,
      isEmpty,
    );
  });
}

CheckIn _checkIn({
  String id = 'check-in-1',
  required String userId,
  ParticipationType participationType = ParticipationType.direct,
}) {
  return CheckIn(
    id: id,
    sessionId: 'session-1',
    userId: userId,
    callsign: 'TA0TEST',
    participationType: participationType,
    timestamp: DateTime.utc(2026, 8, 23, 18, 10),
  );
}
