import 'package:flutter/material.dart';
import 'package:qo100_tr/app/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QO-100 TR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      routerConfig: appRouter,
    );
  }
}
