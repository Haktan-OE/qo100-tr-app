import 'package:flutter/material.dart';
import 'package:qo100_tr/core/widgets/placeholder_feature_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const pageKey = Key('profile-page');

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeaturePage(
      pageKey: pageKey,
      title: 'Profil',
      description: 'Operatör profiliniz yakında burada.',
      icon: Icons.person_rounded,
    );
  }
}
