class DuplicateCheckInException implements Exception {
  const DuplicateCheckInException({
    required this.sessionId,
    required this.userId,
  });

  final String sessionId;
  final String userId;

  @override
  String toString() {
    return 'DuplicateCheckInException('
        'sessionId: $sessionId, userId: $userId)';
  }
}
