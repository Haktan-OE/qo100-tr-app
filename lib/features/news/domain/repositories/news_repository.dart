import 'package:qo100_tr/features/news/domain/entities/news_item.dart';

abstract interface class NewsRepository {
  /// Emits recent news ordered by publication time, newest first.
  Stream<List<NewsItem>> watchRecentNews({int limit = 20});

  /// Returns recent news ordered by publication time, newest first.
  Future<List<NewsItem>> getRecentNews({int limit = 20});
}
