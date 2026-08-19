import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/features/news/domain/entities/news_item.dart';

final newsFeedProvider = StreamProvider<List<NewsItem>>((ref) {
  return ref.watch(newsRepositoryProvider).watchRecentNews();
});

final newsItemProvider = FutureProvider.family<NewsItem?, String>((
  ref,
  id,
) async {
  final items = await ref.watch(newsRepositoryProvider).getRecentNews();
  for (final item in items) {
    if (item.id == id) {
      return item;
    }
  }
  return null;
});
