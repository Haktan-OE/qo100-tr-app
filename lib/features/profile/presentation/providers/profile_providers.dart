import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';

final currentProfileProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(userProfileRepositoryProvider).watchCurrentUserProfile();
});

class ProfileParticipationSummary {
  const ProfileParticipationSummary({
    required this.total,
    required this.direct,
    required this.swl,
  });
  final int total;
  final int direct;
  final int swl;
}

final profileParticipationSummaryProvider =
    FutureProvider.family<ProfileParticipationSummary, String>((
      ref,
      userId,
    ) async {
      final sessionRepository = ref.watch(sessionRepositoryProvider);
      final checkInRepository = ref.watch(checkInRepositoryProvider);
      final sessions = await sessionRepository.getRecentSessions();
      final checkIns = <CheckIn>[];
      for (final session in sessions) {
        final checkIn = await checkInRepository.getCurrentUserCheckIn(
          sessionId: session.id,
          userId: userId,
        );
        if (checkIn != null) {
          checkIns.add(checkIn);
        }
      }
      final direct = checkIns
          .where((item) => item.participationType == ParticipationType.direct)
          .length;
      final swl = checkIns.length - direct;
      return ProfileParticipationSummary(
        total: checkIns.length,
        direct: direct,
        swl: swl,
      );
    });
