enum ParticipationType { direct, swl }

class CheckIn {
  const CheckIn({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.callsign,
    required this.participationType,
    required this.timestamp,
  });

  final String id;
  final String sessionId;
  final String userId;
  final String callsign;
  final ParticipationType participationType;
  final DateTime timestamp;
}
