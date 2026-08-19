import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';
import 'package:qo100_tr/features/profile/domain/services/profile_input_validator.dart';

enum OnboardingStatus { idle, saving, success, validationFailure, error }

class OnboardingState {
  const OnboardingState(this.status, {this.errors = const {}, this.message});
  const OnboardingState.idle() : this(OnboardingStatus.idle);
  final OnboardingStatus status;
  final Map<String, String> errors;
  final String? message;
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState.idle();
  Future<void> save({
    required String callsign,
    required String name,
    required String city,
    required String locator,
    required String antenna,
    required String gear,
  }) async {
    if (state.status == OnboardingStatus.saving) return;
    final validation = ProfileInputValidator.validate(
      callsign: callsign,
      name: name,
      city: city,
      locator: locator,
    );
    if (!validation.isValid) {
      state = OnboardingState(
        OnboardingStatus.validationFailure,
        errors: validation.errors,
      );
      return;
    }
    state = const OnboardingState(OnboardingStatus.saving);
    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      if (user == null) throw StateError('No authenticated user');
      String? optional(String value) =>
          value.trim().isEmpty ? null : value.trim();
      await ref
          .read(userProfileRepositoryProvider)
          .updateCurrentUserProfile(
            UserProfile(
              id: user.id,
              callsign: validation.values['callsign']!,
              name: validation.values['name']!,
              city: validation.values['city']!,
              locator: validation.values['locator']!,
              antenna: optional(antenna),
              gear: optional(gear),
              role: UserRole.member,
            ),
          );
      if (ref.mounted) {
        state = const OnboardingState(OnboardingStatus.success);
      }
    } on Object {
      if (ref.mounted) {
        state = const OnboardingState(
          OnboardingStatus.error,
          message: 'Profil kaydedilemedi. Yeniden deneyin.',
        );
      }
    }
  }
}

final onboardingControllerProvider =
    NotifierProvider.autoDispose<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
