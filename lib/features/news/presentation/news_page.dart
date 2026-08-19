import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/router/app_router.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/features/news/domain/entities/news_item.dart';
import 'package:qo100_tr/features/news/presentation/models/news_category.dart';
import 'package:qo100_tr/features/news/presentation/providers/news_providers.dart';
import 'package:qo100_tr/features/news/presentation/widgets/featured_news_card.dart';
import 'package:qo100_tr/features/news/presentation/widgets/news_feed_card.dart';
import 'package:qo100_tr/features/news/presentation/widgets/news_state_card.dart';

class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({super.key});

  static const pageKey = Key('news-page');

  @override
  ConsumerState<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends ConsumerState<NewsPage> {
  NewsCategory _selectedCategory = NewsCategory.all;

  @override
  Widget build(BuildContext context) {
    final news = ref.watch(newsFeedProvider);

    return Scaffold(
      key: NewsPage.pageKey,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            const _NewsHeader(),
            const SizedBox(height: AppSpacing.lg),
            _CategoryFilters(
              selected: _selectedCategory,
              onSelected: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            news.when(
              loading: () => const NewsStateCard(
                key: Key('news-loading'),
                title: 'Haberler yükleniyor',
                message: 'Topluluk gündemi hazırlanıyor.',
                loading: true,
              ),
              error: (error, stackTrace) => NewsStateCard(
                key: const Key('news-error'),
                title: 'Haberler alınamadı',
                message: 'Bağlantıyı kontrol edip yeniden deneyin.',
                icon: Icons.cloud_off_rounded,
                actionLabel: 'Tekrar Dene',
                onAction: () => ref.invalidate(newsFeedProvider),
              ),
              data: _buildFeed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeed(List<NewsItem> items) {
    final filtered = _selectedCategory == NewsCategory.all
        ? items
        : items
              .where((item) => categoryForNews(item) == _selectedCategory)
              .toList(growable: false);

    if (filtered.isEmpty) {
      return const NewsStateCard(
        key: Key('news-empty'),
        title: 'Bu kategoride haber yok',
        message: 'Yeni içerikler yayınlandığında burada görünecek.',
      );
    }

    final featured = filtered.first;
    final remaining = filtered.skip(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeaturedNewsCard(
          item: featured,
          onTap: () => context.go(AppRoutes.newsDetail(featured.id)),
        ),
        if (remaining.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text('Son Haberler', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          for (final item in remaining) ...[
            NewsFeedCard(
              item: item,
              onTap: () => context.go(AppRoutes.newsDetail(item.id)),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ],
    );
  }
}

class _NewsHeader extends StatelessWidget {
  const _NewsHeader();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.article_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Haberler', style: Theme.of(context).textTheme.headlineMedium),
            Text(
              'QO-100 ve topluluk gündemi',
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

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({required this.selected, required this.onSelected});

  final NewsCategory selected;
  final ValueChanged<NewsCategory> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final category in NewsCategory.values) ...[
          FilterChip(
            key: Key('news-filter-${category.name}'),
            label: Text(category.label),
            selected: category == selected,
            onSelected: (_) => onSelected(category),
          ),
          if (category != NewsCategory.values.last)
            const SizedBox(width: AppSpacing.xs),
        ],
      ],
    ),
  );
}
