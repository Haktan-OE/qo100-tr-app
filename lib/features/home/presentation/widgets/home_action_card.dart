import 'package:flutter/material.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';

class HomeActionCard extends StatelessWidget {
  const HomeActionCard({required this.onJoin, super.key});

  static const joinButtonKey = Key('home-join-button');

  final VoidCallback onJoin;

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
                Icon(Icons.how_to_reg_rounded, color: colors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('Yoklama', style: textTheme.titleLarge)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Haftalık buluşmaya direkt veya SWL olarak katılımını kaydet.',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                key: joinButtonKey,
                onPressed: onJoin,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Yoklamaya Katıl'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
