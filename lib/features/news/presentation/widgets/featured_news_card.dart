import 'package:flutter/material.dart';
import 'package:qo100_tr/app/theme/app_colors.dart';
import 'package:qo100_tr/app/theme/app_radius.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/core/formatters/app_date_formatter.dart';
import 'package:qo100_tr/features/news/domain/entities/news_item.dart';

class FeaturedNewsCard extends StatelessWidget {
  const FeaturedNewsCard({required this.item, required this.onTap, super.key});

  final NewsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: Key('featured-news-${item.id}'),
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surfaceElevated, AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.control,
              ),
              child: Text(
                'ÖNE ÇIKAN',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.onPrimary),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(item.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${item.source} • ${AppDateFormatter.date(item.publishedAt)}',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    ),
  );
}
