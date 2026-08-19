import 'package:flutter/material.dart';
import 'package:qo100_tr/app/theme/app_colors.dart';
import 'package:qo100_tr/app/theme/app_spacing.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  static const pageKey = Key('splash-page');
  @override
  Widget build(BuildContext context) => const Scaffold(
    key: pageKey,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.satellite_alt_rounded, size: 72, color: AppColors.primary),
          SizedBox(height: AppSpacing.md),
          Text('QO-100 TR'),
          SizedBox(height: AppSpacing.md),
          CircularProgressIndicator(),
        ],
      ),
    ),
  );
}
