import 'package:qo100_tr/features/news/domain/entities/news_item.dart';

enum NewsCategory {
  all('Tümü'),
  qo100('QO-100'),
  satellite('Uydu'),
  community('Topluluk');

  const NewsCategory(this.label);

  final String label;
}

/// Temporary presentation-only categorization until the source taxonomy exists.
NewsCategory categoryForNews(NewsItem item) => switch (item.id) {
  'fixture-news-satellite' => NewsCategory.satellite,
  'fixture-news-radio' => NewsCategory.qo100,
  _ => NewsCategory.community,
};
