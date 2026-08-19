import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';

typedef CheckInClock = DateTime Function();
typedef CheckInIdGenerator = String Function(DateTime timestamp);

class CheckInFactory {
  CheckInFactory({CheckInClock? clock, CheckInIdGenerator? idGenerator})
    : _clock = clock ?? DateTime.now,
      _idGenerator = idGenerator ?? _defaultIdGenerator;

  final CheckInClock _clock;
  final CheckInIdGenerator _idGenerator;

  CheckIn create({
    required String sessionId,
    required String userId,
    required String callsign,
    required ParticipationType participationType,
  }) {
    final timestamp = _clock().toUtc();
    return CheckIn(
      id: _idGenerator(timestamp),
      sessionId: sessionId,
      userId: userId,
      callsign: callsign,
      participationType: participationType,
      timestamp: timestamp,
    );
  }

  static String _defaultIdGenerator(DateTime timestamp) {
    return 'local-${timestamp.microsecondsSinceEpoch}';
  }
}
