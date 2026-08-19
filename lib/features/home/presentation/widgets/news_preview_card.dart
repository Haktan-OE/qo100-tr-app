import 'package:flutter/material.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/core/formatters/app_date_formatter.dart';
import 'package:qo100_tr/features/news/domain/entities/news_item.dart';

class NewsPreviewCard extends StatelessWidget {
  const NewsPreviewCard({required this.item, this.onTap, super.key});

  final NewsItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('home-news-${item.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: colors.primaryContainer,
                  shape: const CircleBorder(),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(Icons.article_rounded, color: colors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${item.source} • '
                      '${AppDateFormatter.date(item.publishedAt)}',
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
