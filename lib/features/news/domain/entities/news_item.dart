class NewsItem {
  const NewsItem({
    required this.id,
    required this.source,
    required this.title,
    required this.summary,
    required this.url,
    required this.publishedAt,
  });

  final String id;
  final String source;
  final String title;
  final String summary;
  final Uri url;
  final DateTime publishedAt;
}
