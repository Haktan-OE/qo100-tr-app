import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/features/auth/domain/exceptions/auth_exceptions.dart';

enum AuthFormStatus {
  idle,
  submitting,
  success,
  validationFailure,
  invalidCredentials,
  error,
}

enum AuthFormMode { login, register }

class AuthFormState {
  const AuthFormState(this.status, {this.message, this.errors = const {}});
  const AuthFormState.idle() : this(AuthFormStatus.idle);
  final AuthFormStatus status;
  final String? message;
  final Map<String, String> errors;
}

class AuthFormController extends Notifier<AuthFormState> {
  AuthFormController(this.mode);
  final AuthFormMode mode;
  @override
  AuthFormState build() => const AuthFormState.idle();

  Future<void> submit({
    required String email,
    required String password,
    String? confirmation,
  }) async {
    if (state.status == AuthFormStatus.submitting) {
      return;
    }
    final normalized = email.trim().toLowerCase();
    final errors = <String, String>{};
    if (normalized.isEmpty || !normalized.contains('@')) {
      errors['email'] = 'Geçerli bir e-posta girin.';
    }
    if (password.isEmpty) {
      errors['password'] = 'Şifre zorunludur.';
    }
    if (mode == AuthFormMode.register && password != confirmation) {
      errors['confirmation'] = 'Şifreler eşleşmiyor.';
    }
    if (errors.isNotEmpty) {
      state = AuthFormState(AuthFormStatus.validationFailure, errors: errors);
      return;
    }
    state = const AuthFormState(AuthFormStatus.submitting);
    try {
      final repository = ref.read(authRepositoryProvider);
      if (mode == AuthFormMode.login) {
        await repository.signIn(email: normalized, password: password);
      } else {
        await repository.register(email: normalized, password: password);
      }
      if (ref.mounted) state = const AuthFormState(AuthFormStatus.success);
    } on InvalidCredentialsException {
      if (ref.mounted) {
        state = const AuthFormState(
          AuthFormStatus.invalidCredentials,
          message: 'E-posta veya şifre hatalı.',
        );
      }
    } on DuplicateAccountException {
      if (ref.mounted) {
        state = const AuthFormState(
          AuthFormStatus.error,
          message: 'Bu e-posta ile bir hesap zaten var.',
        );
      }
    } on WeakPasswordException {
      if (ref.mounted) {
        state = const AuthFormState(
          AuthFormStatus.error,
          message: 'Şifre çok zayıf.',
        );
      }
    } on Object {
      if (ref.mounted) {
        state = const AuthFormState(
          AuthFormStatus.error,
          message: 'İşlem tamamlanamadı. Yeniden deneyin.',
        );
      }
    }
  }
}

final authFormControllerProvider = NotifierProvider.autoDispose
    .family<AuthFormController, AuthFormState, AuthFormMode>(
      AuthFormController.new,
    );
