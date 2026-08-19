import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/features/auth/presentation/controllers/onboarding_controller.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});
  static const pageKey = Key('onboarding-page');
  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final fields = {
    for (final name in [
      'callsign',
      'name',
      'city',
      'locator',
      'antenna',
      'gear',
    ])
      name: TextEditingController(),
  };
  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    return Scaffold(
      key: OnboardingPage.pageKey,
      appBar: AppBar(title: const Text('Operatör Profili')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Topluluk kimliğinizi tamamlayın',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final entry in const [
              ('callsign', 'Callsign'),
              ('name', 'Ad Soyad'),
              ('city', 'Şehir / QTH'),
              ('locator', 'Maidenhead Locator'),
              ('antenna', 'Anten'),
              ('gear', 'İstasyon / Cihaz'),
            ]) ...[
              TextField(
                key: Key('onboarding-${entry.$1}'),
                controller: fields[entry.$1],
                decoration: InputDecoration(
                  labelText: entry.$2,
                  errorText: state.errors[entry.$1],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (state.message != null)
              Text(state.message!, key: const Key('onboarding-error')),
            FilledButton(
              key: const Key('onboarding-submit'),
              onPressed: state.status == OnboardingStatus.saving
                  ? null
                  : () => ref
                        .read(onboardingControllerProvider.notifier)
                        .save(
                          callsign: fields['callsign']!.text,
                          name: fields['name']!.text,
                          city: fields['city']!.text,
                          locator: fields['locator']!.text,
                          antenna: fields['antenna']!.text,
                          gear: fields['gear']!.text,
                        ),
              child: state.status == OnboardingStatus.saving
                  ? const CircularProgressIndicator()
                  : const Text('Profili Tamamla'),
            ),
          ],
        ),
      ),
    );
  }
}
