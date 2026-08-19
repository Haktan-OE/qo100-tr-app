import 'package:flutter/material.dart';
import 'package:qo100_tr/app/theme/app_colors.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';
import 'package:qo100_tr/features/participation/presentation/controllers/check_in_flow_state.dart';

class CheckInActionCard extends StatelessWidget {
  const CheckInActionCard({
    required this.state,
    required this.onSubmit,
    super.key,
  });

  static const submitButtonKey = Key('participation-submit-button');

  final CheckInFlowState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.status == CheckInStatus.success)
              _Feedback(
                key: const Key('participation-success'),
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                title: 'Katılımınız kaydedildi',
                message: _modeMessage(state.checkIn),
              )
            else if (state.status == CheckInStatus.alreadyCheckedIn)
              _Feedback(
                key: const Key('participation-already-checked-in'),
                icon: Icons.verified_rounded,
                color: Theme.of(context).colorScheme.primary,
                title: 'Bu oturuma zaten katıldınız',
                message: _modeMessage(state.checkIn),
              )
            else if (state.status == CheckInStatus.error)
              _Feedback(
                key: const Key('participation-submit-error'),
                icon: Icons.error_outline_rounded,
                color: AppColors.error,
                title: 'Katılım kaydedilemedi',
                message: state.errorMessage ?? 'Lütfen yeniden deneyin.',
              ),
            if (state.status == CheckInStatus.success ||
                state.status == CheckInStatus.alreadyCheckedIn ||
                state.status == CheckInStatus.error)
              const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              key: submitButtonKey,
              onPressed: state.canSubmit ? onSubmit : null,
              icon: state.status == CheckInStatus.submitting
                  ? const SizedBox.square(
                      dimension: AppSpacing.lg,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.how_to_reg_rounded),
              label: Text(_buttonLabel(state.status)),
            ),
          ],
        ),
      ),
    );
  }

  static String _buttonLabel(CheckInStatus status) {
    return switch (status) {
      CheckInStatus.submitting => 'Kaydediliyor…',
      CheckInStatus.success => 'Katılım Kaydedildi',
      CheckInStatus.alreadyCheckedIn => 'Zaten Katıldınız',
      CheckInStatus.idle || CheckInStatus.error => 'Katılımımı Kaydet',
    };
  }

  static String _modeMessage(CheckIn? checkIn) {
    final mode = checkIn?.participationType == ParticipationType.swl
        ? 'SWL'
        : 'Direkt';
    return 'Katılım türü: $mode';
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
