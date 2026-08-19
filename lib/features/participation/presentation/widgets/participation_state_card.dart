import 'package:flutter/material.dart';
import 'package:qo100_tr/app/theme/app_colors.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';

class ParticipationStateCard extends StatelessWidget {
  const ParticipationStateCard({
    required this.title,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.isLoading = false,
    this.isError = false,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final bool isLoading;
  final bool isError;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = isError ? AppColors.error : colors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            if (isLoading)
              const CircularProgressIndicator()
            else
              Icon(icon, size: AppSpacing.xxl, color: foreground),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
