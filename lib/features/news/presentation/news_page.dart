import 'package:flutter/material.dart';
import 'package:qo100_tr/core/widgets/placeholder_feature_page.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  static const pageKey = Key('news-page');

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeaturePage(
      pageKey: pageKey,
      title: 'Haberler',
      description: 'Topluluk haberleri ve duyuruları yakında burada.',
      icon: Icons.article_rounded,
    );
  }
}
