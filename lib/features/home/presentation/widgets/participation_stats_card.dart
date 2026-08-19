import 'package:flutter/material.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';

class ParticipationStatsCard extends StatelessWidget {
  const ParticipationStatsCard({
    required this.directCount,
    required this.swlCount,
    super.key,
  });

  final int directCount;
  final int swlCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatTile(
                valueKey: const Key('home-direct-count'),
                label: 'Direkt',
                value: directCount,
                icon: Icons.mic_rounded,
              ),
            ),
            Expanded(
              child: _StatTile(
                valueKey: const Key('home-swl-count'),
                label: 'SWL',
                value: swlCount,
                icon: Icons.headphones_rounded,
              ),
            ),
            Expanded(
              child: _StatTile(
                valueKey: const Key('home-total-count'),
                label: 'Toplam',
                value: directCount + swlCount,
                icon: Icons.groups_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.valueKey,
    required this.label,
    required this.value,
    required this.icon,
  });

  final Key valueKey;
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: Column(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$value',
            key: valueKey,
            style: textTheme.titleLarge?.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
