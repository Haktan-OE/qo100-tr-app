import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';
import 'package:qo100_tr/features/participation/domain/entities/community_session.dart';
import 'package:qo100_tr/features/participation/domain/exceptions/duplicate_check_in_exception.dart';
import 'package:qo100_tr/features/participation/presentation/controllers/check_in_flow_state.dart';
import 'package:qo100_tr/features/participation/presentation/providers/check_in_dependencies.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';

class CheckInContext {
  const CheckInContext({required this.session, required this.profile});

  final CommunitySession session;
  final UserProfile profile;

  @override
  bool operator ==(Object other) {
    return other is CheckInContext &&
        other.session.id == session.id &&
        other.profile.id == profile.id;
  }

  @override
  int get hashCode => Object.hash(session.id, profile.id);
}

class CheckInController extends AsyncNotifier<CheckInFlowState> {
  CheckInController(this.context);

  final CheckInContext context;

  @override
  Future<CheckInFlowState> build() async {
    final existing = await ref
        .watch(checkInRepositoryProvider)
        .getCurrentUserCheckIn(
          sessionId: context.session.id,
          userId: context.profile.id,
        );
    if (existing != null) {
      return CheckInFlowState.alreadyCheckedIn(existing);
    }
    return const CheckInFlowState.idle();
  }

  void selectType(ParticipationType type) {
    final current = state.value;
    if (current == null || !current.canSelectType) {
      return;
    }
    state = AsyncData(CheckInFlowState.idle(selectedType: type));
  }

  Future<void> submit() async {
    final current = state.value;
    if (current == null || !current.canSubmit) {
      return;
    }

    final selectedType = current.selectedType;
    if (!context.session.isActive) {
      state = AsyncData(
        CheckInFlowState.error(
          selectedType: selectedType,
          message: 'Katılım için aktif bir oturum bulunmuyor.',
        ),
      );
      return;
    }
    state = AsyncData(CheckInFlowState.submitting(selectedType));

    final checkIn = ref
        .read(checkInFactoryProvider)
        .create(
          sessionId: context.session.id,
          userId: context.profile.id,
          callsign: context.profile.callsign,
          participationType: selectedType,
        );
    final repository = ref.read(checkInRepositoryProvider);

    try {
      final submitted = await repository.submitCheckIn(checkIn);
      if (ref.mounted) {
        state = AsyncData(CheckInFlowState.success(submitted));
      }
    } on DuplicateCheckInException {
      final existing = await repository.getCurrentUserCheckIn(
        sessionId: context.session.id,
        userId: context.profile.id,
      );
      if (ref.mounted) {
        state = AsyncData(
          CheckInFlowState.alreadyCheckedIn(existing ?? checkIn),
        );
      }
    } on Object {
      if (ref.mounted) {
        state = AsyncData(
          CheckInFlowState.error(
            selectedType: selectedType,
            message: 'Katılım kaydedilemedi. Lütfen yeniden deneyin.',
          ),
        );
      }
    }
  }
}
