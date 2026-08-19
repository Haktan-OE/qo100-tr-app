import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';
import 'package:qo100_tr/features/profile/domain/services/profile_input_validator.dart';
import 'package:qo100_tr/features/profile/presentation/models/profile_edit_state.dart';

class ProfileEditController extends Notifier<ProfileEditState> {
  ProfileEditController(this.profile);

  final UserProfile profile;

  @override
  ProfileEditState build() => const ProfileEditState.idle();

  Future<bool> save({
    required String callsign,
    required String name,
    required String city,
    required String locator,
    required String antenna,
    required String gear,
  }) async {
    final validation = ProfileInputValidator.validate(
      callsign: callsign,
      name: name,
      city: city,
      locator: locator,
    );
    if (!validation.isValid) {
      state = ProfileEditState.validationFailure(validation.errors);
      return false;
    }
    final values = validation.values;

    state = const ProfileEditState.saving();
    final updated = UserProfile(
      id: profile.id,
      callsign: values['callsign']!,
      name: values['name']!,
      city: values['city']!,
      locator: values['locator']!,
      antenna: _optional(antenna),
      gear: _optional(gear),
      role: profile.role,
    );
    try {
      await ref
          .read(userProfileRepositoryProvider)
          .updateCurrentUserProfile(updated);
      if (ref.mounted) state = const ProfileEditState.success();
      return true;
    } on Object {
      if (ref.mounted) {
        state = const ProfileEditState.error(
          'Profil kaydedilemedi. Lütfen yeniden deneyin.',
        );
      }
      return false;
    }
  }

  static String? _optional(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}

final profileEditControllerProvider = NotifierProvider.autoDispose
    .family<ProfileEditController, ProfileEditState, UserProfile>(
      ProfileEditController.new,
    );
