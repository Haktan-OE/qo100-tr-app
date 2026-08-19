import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';

enum CheckInStatus { idle, submitting, success, alreadyCheckedIn, error }

class CheckInFlowState {
  const CheckInFlowState._({
    required this.status,
    required this.selectedType,
    this.checkIn,
    this.errorMessage,
  });

  /// Direkt is the documented default for a new fixture check-in.
  const CheckInFlowState.idle({
    ParticipationType selectedType = ParticipationType.direct,
  }) : this._(status: CheckInStatus.idle, selectedType: selectedType);

  const CheckInFlowState.submitting(ParticipationType selectedType)
    : this._(status: CheckInStatus.submitting, selectedType: selectedType);

  CheckInFlowState.success(CheckIn checkIn)
    : this._(
        status: CheckInStatus.success,
        selectedType: checkIn.participationType,
        checkIn: checkIn,
      );

  CheckInFlowState.alreadyCheckedIn(CheckIn checkIn)
    : this._(
        status: CheckInStatus.alreadyCheckedIn,
        selectedType: checkIn.participationType,
        checkIn: checkIn,
      );

  const CheckInFlowState.error({
    required ParticipationType selectedType,
    required String message,
  }) : this._(
         status: CheckInStatus.error,
         selectedType: selectedType,
         errorMessage: message,
       );

  final CheckInStatus status;
  final ParticipationType selectedType;
  final CheckIn? checkIn;
  final String? errorMessage;

  bool get canSubmit =>
      status == CheckInStatus.idle || status == CheckInStatus.error;

  bool get canSelectType => canSubmit;
}
