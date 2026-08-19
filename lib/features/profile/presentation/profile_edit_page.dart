import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/router/app_router.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';
import 'package:qo100_tr/features/profile/presentation/controllers/profile_edit_controller.dart';
import 'package:qo100_tr/features/profile/presentation/models/profile_edit_state.dart';
import 'package:qo100_tr/features/profile/presentation/providers/profile_providers.dart';

class ProfileEditPage extends ConsumerWidget {
  const ProfileEditPage({super.key});
  static const pageKey = Key('profile-edit-page');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    return Scaffold(
      key: pageKey,
      appBar: AppBar(title: const Text('Profili Düzenle')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Profil yüklenemedi.')),
        data: (value) => value == null
            ? const Center(child: Text('Profil bulunamadı.'))
            : _ProfileForm(profile: value),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.profile});
  final UserProfile profile;
  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final Map<String, TextEditingController> fields = {
    'callsign': TextEditingController(text: widget.profile.callsign),
    'name': TextEditingController(text: widget.profile.name),
    'city': TextEditingController(text: widget.profile.city),
    'locator': TextEditingController(text: widget.profile.locator),
    'antenna': TextEditingController(text: widget.profile.antenna ?? ''),
    'gear': TextEditingController(text: widget.profile.gear ?? ''),
  };

  @override
  void dispose() {
    for (final controller in fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = profileEditControllerProvider(widget.profile);
    final state = ref.watch(provider);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        for (final entry in const [
          ('callsign', 'Çağrı İşareti'),
          ('name', 'Ad Soyad'),
          ('city', 'Şehir'),
          ('locator', 'Maidenhead Locator'),
          ('antenna', 'Anten'),
          ('gear', 'İstasyon / Cihaz'),
        ]) ...[
          TextField(
            key: Key('profile-field-${entry.$1}'),
            controller: fields[entry.$1],
            decoration: InputDecoration(
              labelText: entry.$2,
              errorText: state.fieldErrors[entry.$1],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (state.status == ProfileEditStatus.error)
          Text(
            state.message!,
            key: const Key('profile-save-error'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton(
          key: const Key('profile-save-button'),
          onPressed: state.status == ProfileEditStatus.saving
              ? null
              : () async {
                  final saved = await ref
                      .read(provider.notifier)
                      .save(
                        callsign: fields['callsign']!.text,
                        name: fields['name']!.text,
                        city: fields['city']!.text,
                        locator: fields['locator']!.text,
                        antenna: fields['antenna']!.text,
                        gear: fields['gear']!.text,
                      );
                  if (!mounted) return;
                  if (saved) this.context.go(AppRoutes.profile);
                },
          child: state.status == ProfileEditStatus.saving
              ? const CircularProgressIndicator()
              : const Text('Kaydet'),
        ),
        TextButton(
          key: const Key('profile-cancel-button'),
          onPressed: () => context.go(AppRoutes.profile),
          child: const Text('İptal'),
        ),
      ],
    );
  }
}
