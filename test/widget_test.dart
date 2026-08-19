import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/app.dart';
import 'package:qo100_tr/app/router/app_router.dart';
import 'package:qo100_tr/app/shell/app_shell.dart';
import 'package:qo100_tr/app/theme/app_colors.dart';
import 'package:qo100_tr/features/home/presentation/home_page.dart';
import 'package:qo100_tr/features/live/presentation/live_page.dart';
import 'package:qo100_tr/features/news/presentation/news_page.dart';
import 'package:qo100_tr/features/participation/presentation/participation_page.dart';
import 'package:qo100_tr/features/profile/presentation/profile_page.dart';

void main() {
  testWidgets('application shell renders with the dark Material 3 theme', (
    tester,
  ) async {
    final router = await _pumpApp(tester);
    addTearDown(router.dispose);

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byKey(HomePage.pageKey), findsOneWidget);

    final context = tester.element(find.byKey(HomePage.pageKey));
    final theme = Theme.of(context);
    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
  });

  testWidgets('all five navigation destinations exist', (tester) async {
    final router = await _pumpApp(tester);
    addTearDown(router.dispose);

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    final labels = navigationBar.destinations.cast<NavigationDestination>().map(
      (destination) => destination.label,
    );

    expect(
      labels,
      orderedEquals(['Ana Sayfa', 'Canlı', 'Katılım', 'Haberler', 'Profil']),
    );
  });

  testWidgets('switching tabs updates the active destination', (tester) async {
    final router = await _pumpApp(tester);
    addTearDown(router.dispose);

    expect(_selectedIndex(tester), 0);

    await tester.tap(find.text('Katılım'));
    await tester.pumpAndSettle();

    expect(_selectedIndex(tester), 2);
    expect(find.byKey(ParticipationPage.pageKey), findsOneWidget);
  });

  testWidgets('each route reaches its corresponding page', (tester) async {
    final router = await _pumpApp(tester);
    addTearDown(router.dispose);

    const routes = <String, Key>{
      AppRoutes.home: HomePage.pageKey,
      AppRoutes.live: LivePage.pageKey,
      AppRoutes.participation: ParticipationPage.pageKey,
      AppRoutes.news: NewsPage.pageKey,
      AppRoutes.profile: ProfilePage.pageKey,
    };

    for (final entry in routes.entries) {
      router.go(entry.key);
      await tester.pumpAndSettle();

      expect(find.byKey(entry.value), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    }
  });
}

Future<GoRouter> _pumpApp(WidgetTester tester) async {
  final router = createAppRouter();
  await tester.pumpWidget(ProviderScope(child: App(router: router)));
  await tester.pumpAndSettle();
  return router;
}

int _selectedIndex(WidgetTester tester) {
  return tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;
}
