import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/theme/app_colors.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/features/auth/presentation/controllers/auth_form_controller.dart';

class AuthFormPage extends ConsumerStatefulWidget {
  const AuthFormPage({required this.mode, super.key});
  final AuthFormMode mode;
  static const loginKey = Key('login-page');
  static const registerKey = Key('register-page');
  @override
  ConsumerState<AuthFormPage> createState() => _AuthFormPageState();
}

class _AuthFormPageState extends ConsumerState<AuthFormPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = authFormControllerProvider(widget.mode);
    final state = ref.watch(provider);
    final register = widget.mode == AuthFormMode.register;
    return Scaffold(
      key: register ? AuthFormPage.registerKey : AuthFormPage.loginKey,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const SizedBox(height: AppSpacing.xxl),
            const Icon(
              Icons.satellite_alt_rounded,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'QO-100 TR',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              register
                  ? 'Topluluğa katılın'
                  : 'Operatör hesabınıza giriş yapın',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            TextField(
              key: const Key('auth-email'),
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-posta',
                errorText: state.errors['email'],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('auth-password'),
              controller: password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre',
                errorText: state.errors['password'],
              ),
            ),
            if (register) ...[
              const SizedBox(height: AppSpacing.md),
              TextField(
                key: const Key('auth-confirmation'),
                controller: confirmation,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Şifre Tekrar',
                  errorText: state.errors['confirmation'],
                ),
              ),
            ],
            if (state.message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                state.message!,
                key: const Key('auth-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              key: const Key('auth-submit'),
              onPressed: state.status == AuthFormStatus.submitting
                  ? null
                  : () => ref
                        .read(provider.notifier)
                        .submit(
                          email: email.text,
                          password: password.text,
                          confirmation: confirmation.text,
                        ),
              child: state.status == AuthFormStatus.submitting
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(),
                    )
                  : Text(register ? 'Hesap Oluştur' : 'Giriş Yap'),
            ),
            TextButton(
              key: const Key('auth-alternate'),
              onPressed: () =>
                  context.go(register ? '/auth/login' : '/auth/register'),
              child: Text(register ? 'Giriş Yap' : 'Hesap Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}
