import 'package:flutter/material.dart';
import 'package:qo100_tr/app/theme/app_colors.dart';
import 'package:qo100_tr/app/theme/app_radius.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/core/formatters/app_date_formatter.dart';
import 'package:qo100_tr/features/participation/domain/entities/community_session.dart';

class ParticipationSessionCard extends StatelessWidget {
  const ParticipationSessionCard({required this.session, super.key});

  final CommunitySession session;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = session.isActive ? AppColors.success : colors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: AppRadius.control,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      Icons.satellite_alt_rounded,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(session.title, style: textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InfoChip(
                  icon: Icons.graphic_eq_rounded,
                  label: '${session.frequencyMHz.toStringAsFixed(3)} MHz',
                  key: const Key('participation-session-frequency'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoChip(
                  icon: Icons.schedule_rounded,
                  label: AppDateFormatter.dateTimeUtc(session.startAt),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.circle, size: AppSpacing.xs, color: statusColor),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  session.isActive ? 'Aktif oturum' : 'Yaklaşan oturum',
                  style: textTheme.labelMedium?.copyWith(color: statusColor),
                ),
              ],
            ),
            if (session.scenarioNote case final note?) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppRadius.control,
                ),
                child: Text(note, style: textTheme.bodyMedium),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppRadius.control,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppSpacing.lg, color: colors.primary),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
