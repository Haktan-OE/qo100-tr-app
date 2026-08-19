import 'package:flutter_test/flutter_test.dart';
import 'package:qo100_tr/features/news/data/fixtures/fixture_news_repository.dart';

void main() {
  test('returns fixture news newest first and respects the limit', () async {
    final repository = FixtureNewsRepository();

    final items = await repository.getRecentNews(limit: 2);

    expect(items, hasLength(2));
    expect(items.first.publishedAt.isAfter(items.last.publishedAt), isTrue);
  });

  test('watches fixture news using the same newest-first contract', () async {
    final repository = FixtureNewsRepository();

    final items = await repository.watchRecentNews().first;

    expect(items, hasLength(3));
    for (var index = 1; index < items.length; index++) {
      expect(
        items[index - 1].publishedAt.isAfter(items[index].publishedAt),
        isTrue,
      );
    }
  });
}
