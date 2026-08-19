import 'package:flutter/material.dart';
import 'package:qo100_tr/core/widgets/placeholder_feature_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const pageKey = Key('home-page');

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeaturePage(
      pageKey: pageKey,
      title: 'Ana Sayfa',
      description: 'QO-100 TR topluluk merkezi yakında burada.',
      icon: Icons.satellite_alt_rounded,
    );
  }
}
