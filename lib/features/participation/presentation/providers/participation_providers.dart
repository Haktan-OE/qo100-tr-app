import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';
import 'package:qo100_tr/features/participation/domain/entities/community_session.dart';
import 'package:qo100_tr/features/participation/presentation/controllers/check_in_controller.dart';
import 'package:qo100_tr/features/participation/presentation/controllers/check_in_flow_state.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';

final participationSessionProvider = StreamProvider<CommunitySession?>((ref) {
  return ref.watch(sessionRepositoryProvider).watchCurrentSession();
});

final participationProfileProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(userProfileRepositoryProvider).watchCurrentUserProfile();
});

final participationCheckInsProvider =
    StreamProvider.family<List<CheckIn>, String>((ref, sessionId) {
      return ref.watch(checkInRepositoryProvider).watchCheckIns(sessionId);
    });

final checkInControllerProvider = AsyncNotifierProvider.autoDispose
    .family<CheckInController, CheckInFlowState, CheckInContext>(
      CheckInController.new,
    );
