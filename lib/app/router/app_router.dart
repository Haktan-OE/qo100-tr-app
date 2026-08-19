import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const _FoundationPage()),
  ],
);

class _FoundationPage extends StatelessWidget {
  const _FoundationPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('QO-100 TR')));
  }
}
