import 'package:qo100_tr/features/news/domain/entities/news_item.dart';

abstract final class NewsFixtures {
  static final items = List<NewsItem>.unmodifiable([
    NewsItem(
      id: 'fixture-news-community',
      source: 'QO-100 TR Fixture',
      title: 'Haftalık buluşma için örnek duyuru',
      summary: 'Bu içerik yalnızca yerel arayüz geliştirmesinde kullanılır.',
      url: Uri.parse('https://example.com/qo100-tr/fixture-announcement'),
      publishedAt: DateTime.utc(2026, 8, 18, 9),
    ),
    NewsItem(
      id: 'fixture-news-satellite',
      source: 'Uydu Haberleri Fixture',
      title: 'Amatör uydu çalışmaları için örnek haber',
      summary: 'Gerçek bir haber kaynağına veya API’ye bağlı değildir.',
      url: Uri.parse('https://example.com/qo100-tr/fixture-satellite'),
      publishedAt: DateTime.utc(2026, 8, 17, 12),
    ),
    NewsItem(
      id: 'fixture-news-radio',
      source: 'Topluluk Fixture',
      title: 'İstasyon hazırlıkları için örnek içerik',
      summary: 'Fixture veri sıralamasını doğrulamak için eklenmiştir.',
      url: Uri.parse('https://example.com/qo100-tr/fixture-station'),
      publishedAt: DateTime.utc(2026, 8, 15, 15),
    ),
  ]);
}
