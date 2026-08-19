import 'package:flutter/material.dart';
import 'package:qo100_tr/app/theme/app_colors.dart';
import 'package:qo100_tr/app/theme/app_radius.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/features/home/presentation/formatters/home_date_formatter.dart';
import 'package:qo100_tr/features/participation/domain/entities/community_session.dart';

class SessionHeroCard extends StatelessWidget {
  const SessionHeroCard({
    required this.session,
    required this.onListen,
    super.key,
  });

  static const liveButtonKey = Key('home-live-button');

  final CommunitySession session;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = session.isActive ? AppColors.success : colors.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primaryContainer, colors.surfaceContainer],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -AppSpacing.lg,
              top: -AppSpacing.lg,
              child: Icon(
                Icons.satellite_alt_rounded,
                size: AppSpacing.xxl * 4,
                color: colors.primary.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusBadge(
                    label: session.isActive
                        ? 'AKTİF OTURUM'
                        : 'YAKLAŞAN OTURUM',
                    color: statusColor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(session.title, style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '${session.frequencyMHz.toStringAsFixed(3)} MHz',
                    key: const Key('home-session-frequency'),
                    style: textTheme.headlineMedium?.copyWith(
                      color: colors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: AppSpacing.lg,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          HomeDateFormatter.sessionDateTime(session.startAt),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (session.scenarioNote case final note?) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.55),
                        borderRadius: AppRadius.control,
                      ),
                      child: Text(note, style: textTheme.bodyMedium),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: liveButtonKey,
                      onPressed: onListen,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Canlı Dinle'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.14),
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: AppSpacing.xs, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
