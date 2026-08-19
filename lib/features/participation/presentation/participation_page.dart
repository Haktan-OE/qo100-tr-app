import 'package:flutter/material.dart';
import 'package:qo100_tr/core/widgets/placeholder_feature_page.dart';

class ParticipationPage extends StatelessWidget {
  const ParticipationPage({super.key});

  static const pageKey = Key('participation-page');

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeaturePage(
      pageKey: pageKey,
      title: 'Katılım',
      description: 'Haftalık katılım akışı yakında burada.',
      icon: Icons.how_to_reg_rounded,
    );
  }
}
