import 'dart:async';

import 'package:qo100_tr/features/participation/data/fixtures/participation_fixtures.dart';
import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';
import 'package:qo100_tr/features/participation/domain/exceptions/duplicate_check_in_exception.dart';
import 'package:qo100_tr/features/participation/domain/repositories/check_in_repository.dart';

class FixtureCheckInRepository implements CheckInRepository {
  FixtureCheckInRepository({Iterable<CheckIn>? checkIns})
    : _checkIns = List.of(checkIns ?? ParticipationFixtures.checkIns);

  final List<CheckIn> _checkIns;
  final StreamController<String> _changedSessionIds =
      StreamController<String>.broadcast();

  @override
  Stream<List<CheckIn>> watchCheckIns(String sessionId) {
    return Stream<List<CheckIn>>.multi((controller) {
      controller.add(_snapshotFor(sessionId));
      final subscription = _changedSessionIds.stream
          .where((changedSessionId) => changedSessionId == sessionId)
          .listen(
            (_) => controller.add(_snapshotFor(sessionId)),
            onError: controller.addError,
            onDone: controller.close,
          );
      controller.onCancel = subscription.cancel;
    });
  }

  @override
  Future<CheckIn?> getCurrentUserCheckIn({
    required String sessionId,
    required String userId,
  }) async => _findCheckIn(sessionId: sessionId, userId: userId);

  @override
  Future<CheckIn> submitCheckIn(CheckIn checkIn) async {
    final existing = _findCheckIn(
      sessionId: checkIn.sessionId,
      userId: checkIn.userId,
    );
    if (existing != null) {
      throw DuplicateCheckInException(
        sessionId: checkIn.sessionId,
        userId: checkIn.userId,
      );
    }

    _checkIns.add(checkIn);
    _changedSessionIds.add(checkIn.sessionId);
    return checkIn;
  }

  Future<void> dispose() => _changedSessionIds.close();

  CheckIn? _findCheckIn({required String sessionId, required String userId}) {
    for (final checkIn in _checkIns) {
      if (checkIn.sessionId == sessionId && checkIn.userId == userId) {
        return checkIn;
      }
    }
    return null;
  }

  List<CheckIn> _snapshotFor(String sessionId) {
    final snapshot =
        _checkIns.where((checkIn) => checkIn.sessionId == sessionId).toList()
          ..sort((left, right) => left.timestamp.compareTo(right.timestamp));
    return List.unmodifiable(snapshot);
  }
}
