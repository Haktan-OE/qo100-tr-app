import 'package:flutter/material.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';

class OperatorIdentityCard extends StatelessWidget {
  const OperatorIdentityCard({required this.profile, super.key});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.badge_rounded, color: colors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('Kayıtlı Operatör', style: textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              profile.callsign,
              key: const Key('participation-profile-callsign'),
              style: textTheme.headlineMedium?.copyWith(color: colors.primary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(profile.name, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                _IdentityDetail(icon: Icons.location_city, label: profile.city),
                _IdentityDetail(
                  icon: Icons.grid_4x4_rounded,
                  label: profile.locator,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityDetail extends StatelessWidget {
  const _IdentityDetail({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSpacing.lg, color: colors.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
