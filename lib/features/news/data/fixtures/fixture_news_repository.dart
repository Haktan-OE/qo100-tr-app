import 'package:qo100_tr/features/news/data/fixtures/news_fixtures.dart';
import 'package:qo100_tr/features/news/domain/entities/news_item.dart';
import 'package:qo100_tr/features/news/domain/repositories/news_repository.dart';

class FixtureNewsRepository implements NewsRepository {
  FixtureNewsRepository({Iterable<NewsItem>? items})
    : _items = List.of(items ?? NewsFixtures.items);

  final List<NewsItem> _items;

  @override
  Future<List<NewsItem>> getRecentNews({int limit = 20}) async {
    return _recentNews(limit);
  }

  @override
  Stream<List<NewsItem>> watchRecentNews({int limit = 20}) {
    return Stream.value(_recentNews(limit));
  }

  List<NewsItem> _recentNews(int limit) {
    RangeError.checkNotNegative(limit, 'limit');
    final items = [..._items]
      ..sort((left, right) => right.publishedAt.compareTo(left.publishedAt));
    return List.unmodifiable(items.take(limit));
  }
}
