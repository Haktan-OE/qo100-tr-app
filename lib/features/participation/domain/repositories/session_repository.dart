import 'package:qo100_tr/features/participation/domain/entities/community_session.dart';

abstract interface class SessionRepository {
  Stream<CommunitySession?> watchCurrentSession();

  /// Returns sessions ordered by start time, newest first.
  Future<List<CommunitySession>> getRecentSessions();
}
