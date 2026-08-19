import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/router/app_router.dart';
import 'package:qo100_tr/app/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key, this.router});

  final GoRouter? router;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = widget.router ?? createAppRouter();

  @override
  void dispose() {
    if (widget.router == null) {
      _router.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QO-100 TR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: _router,
    );
  }
}
