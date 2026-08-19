import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/router/app_router.dart';
import 'package:qo100_tr/app/theme/app_colors.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/core/widgets/participation_stats_card.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';
import 'package:qo100_tr/features/profile/presentation/providers/profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const pageKey = Key('profile-page');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    return Scaffold(
      key: pageKey,
      body: SafeArea(
        child: profile.when(
          loading: () => const _ProfileState(
            key: Key('profile-loading'),
            title: 'Profil yükleniyor',
            loading: true,
          ),
          error: (_, _) => _ProfileState(
            key: const Key('profile-error'),
            title: 'Profil alınamadı',
            action: () => ref.invalidate(currentProfileProvider),
          ),
          data: (value) => value == null
              ? const _ProfileState(
                  key: Key('profile-unavailable'),
                  title: 'Profil bulunamadı',
                )
              : _ProfileContent(profile: value),
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.xxl,
    ),
    children: [
      Text('Profil', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: AppSpacing.lg),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.surfaceElevated,
                child: Text(
                  profile.callsign.isEmpty
                      ? '?'
                      : profile.callsign.characters.first,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                profile.callsign,
                key: const Key('profile-callsign'),
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: AppColors.primary),
              ),
              Text(profile.name, key: const Key('profile-name')),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${profile.city} • ${profile.locator}',
                key: const Key('profile-location'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      Text('İstasyon Bilgileri', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppSpacing.sm),
      Card(
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.settings_input_antenna_rounded,
              label: 'Anten',
              value: profile.antenna ?? 'Belirtilmedi',
              valueKey: const Key('profile-antenna'),
            ),
            _InfoRow(
              icon: Icons.radio_rounded,
              label: 'İstasyon / Cihaz',
              value: profile.gear ?? 'Belirtilmedi',
              valueKey: const Key('profile-gear'),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      Text('Katılım Özeti', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppSpacing.sm),
      ref
          .watch(profileParticipationSummaryProvider(profile.id))
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Text('Katılım özeti alınamadı.'),
            data: (summary) => ParticipationStatsCard(
              directCount: summary.direct,
              swlCount: summary.swl,
              directValueKey: const Key('profile-direct-count'),
              swlValueKey: const Key('profile-swl-count'),
              totalValueKey: const Key('profile-total-count'),
            ),
          ),
      const SizedBox(height: AppSpacing.lg),
      FilledButton.icon(
        key: const Key('profile-edit-button'),
        onPressed: () => context.go(AppRoutes.profileEdit),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Profili Düzenle'),
      ),
      const SizedBox(height: AppSpacing.md),
      const Card(
        child: ListTile(
          leading: Icon(Icons.notifications_none_rounded),
          title: Text('Bildirimler'),
          subtitle: Text('Bildirim tercihleri yakında kullanıma açılacak.'),
          enabled: false,
        ),
      ),
    ],
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueKey,
  });
  final IconData icon;
  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.primary),
    title: Text(label),
    subtitle: Text(value, key: valueKey),
  );
}

class _ProfileState extends StatelessWidget {
  const _ProfileState({
    required this.title,
    this.loading = false,
    this.action,
    super.key,
  });
  final String title;
  final bool loading;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading) const CircularProgressIndicator(),
          if (loading) const SizedBox(height: AppSpacing.md),
          Text(title, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: action, child: const Text('Tekrar Dene')),
          ],
        ],
      ),
    ),
  );
}
