import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/app/router/auth_route_guard.dart';
import 'package:qo100_tr/app/router/app_router.dart';
import 'package:qo100_tr/app/theme/app_theme.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key, this.router});

  final GoRouter? router;

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  AuthRouteGuard? _guard;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    if (widget.router == null) {
      _guard = AuthRouteGuard(
        ref.read(authRepositoryProvider),
        ref.read(userProfileRepositoryProvider),
      );
    }
    _router = widget.router ?? createAppRouter(guard: _guard);
  }

  @override
  void dispose() {
    if (widget.router == null) {
      _router.dispose();
      _guard?.dispose();
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
