enum ProfileEditStatus { idle, saving, success, validationFailure, error }

class ProfileEditState {
  const ProfileEditState(
    this.status, {
    this.message,
    this.fieldErrors = const {},
  });

  const ProfileEditState.idle() : this(ProfileEditStatus.idle);
  const ProfileEditState.saving() : this(ProfileEditStatus.saving);
  const ProfileEditState.success() : this(ProfileEditStatus.success);
  const ProfileEditState.error(String message)
    : this(ProfileEditStatus.error, message: message);
  const ProfileEditState.validationFailure(Map<String, String> errors)
    : this(ProfileEditStatus.validationFailure, fieldErrors: errors);

  final ProfileEditStatus status;
  final String? message;
  final Map<String, String> fieldErrors;
}
