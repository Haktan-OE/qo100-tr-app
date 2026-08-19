import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/app/theme/app_colors.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';
import 'package:qo100_tr/core/formatters/app_date_formatter.dart';
import 'package:qo100_tr/core/providers/external_url_launcher_provider.dart';
import 'package:qo100_tr/features/news/domain/entities/news_item.dart';
import 'package:qo100_tr/features/news/presentation/providers/news_providers.dart';
import 'package:qo100_tr/features/news/presentation/widgets/news_state_card.dart';

class NewsDetailPage extends ConsumerWidget {
  const NewsDetailPage({required this.newsId, super.key});

  final String newsId;

  static const pageKey = Key('news-detail-page');

  Future<void> _openSource(BuildContext context, WidgetRef ref, Uri url) async {
    var opened = false;
    try {
      opened = await ref.read(externalUrlLauncherProvider).open(url);
    } on Exception {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Haber kaynağı açılamadı.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(newsItemProvider(newsId));
    return Scaffold(
      key: pageKey,
      appBar: AppBar(title: const Text('Haber Detayı')),
      body: SafeArea(
        child: item.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: NewsStateCard(
              title: 'Haber yükleniyor',
              message: 'İçerik hazırlanıyor.',
              loading: true,
            ),
          ),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: NewsStateCard(
              title: 'Haber yüklenemedi',
              message: 'İçeriği yeniden yükleyebilirsiniz.',
              icon: Icons.cloud_off_rounded,
              actionLabel: 'Tekrar Dene',
              onAction: () => ref.invalidate(newsItemProvider(newsId)),
            ),
          ),
          data: (newsItem) => newsItem == null
              ? const _NewsNotFound()
              : _NewsDetail(
                  item: newsItem,
                  onOpenSource: () => _openSource(context, ref, newsItem.url),
                ),
        ),
      ),
    );
  }
}

class _NewsDetail extends StatelessWidget {
  const _NewsDetail({required this.item, required this.onOpenSource});

  final NewsItem item;
  final VoidCallback onOpenSource;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.xxl,
    ),
    children: [
      const Icon(
        Icons.satellite_alt_rounded,
        size: 52,
        color: AppColors.primary,
      ),
      const SizedBox(height: AppSpacing.lg),
      Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: AppSpacing.sm),
      Text(
        '${item.source} • ${AppDateFormatter.date(item.publishedAt)}',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
      ),
      const SizedBox(height: AppSpacing.xl),
      Text(item.summary, style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: AppSpacing.xl),
      FilledButton.icon(
        key: const Key('news-open-source'),
        onPressed: onOpenSource,
        icon: const Icon(Icons.open_in_new_rounded),
        label: const Text('Kaynağı Aç'),
      ),
    ],
  );
}

class _NewsNotFound extends StatelessWidget {
  const _NewsNotFound();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppSpacing.md),
    child: NewsStateCard(
      key: Key('news-not-found'),
      title: 'Haber bulunamadı',
      message: 'Bu içerik kaldırılmış veya bağlantı geçersiz olabilir.',
      icon: Icons.search_off_rounded,
    ),
  );
}
