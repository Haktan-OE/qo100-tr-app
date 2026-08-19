import 'package:flutter/material.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';

class WeekDetailPlaceholderPage extends StatelessWidget {
  const WeekDetailPlaceholderPage({super.key});

  static const pageKey = Key('week-detail-placeholder-page');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      appBar: AppBar(title: const Text('Hafta Detayı')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: AppSpacing.xxl,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Haftalık geçmiş yakında burada.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
