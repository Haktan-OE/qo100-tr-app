import 'package:flutter/material.dart';
import 'package:qo100_tr/core/widgets/placeholder_feature_page.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  static const pageKey = Key('live-page');

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeaturePage(
      pageKey: pageKey,
      title: 'Canlı',
      description: 'Canlı dinleme deneyimi yakında burada.',
      icon: Icons.graphic_eq_rounded,
    );
  }
}
