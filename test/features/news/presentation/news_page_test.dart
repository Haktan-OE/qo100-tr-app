import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/app.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/app/router/app_router.dart';
import 'package:qo100_tr/core/providers/external_url_launcher_provider.dart';
import 'package:qo100_tr/core/services/external_url_launcher.dart';
import 'package:qo100_tr/features/news/data/fixtures/fixture_news_repository.dart';
import 'package:qo100_tr/features/news/data/fixtures/news_fixtures.dart';
import 'package:qo100_tr/features/news/domain/entities/news_item.dart';
import 'package:qo100_tr/features/news/domain/repositories/news_repository.dart';
import 'package:qo100_tr/features/news/presentation/news_detail_page.dart';
import 'package:qo100_tr/features/news/presentation/news_page.dart';

void main() {
  testWidgets('fixture news renders newest-first with a featured article', (
    tester,
  ) async {
    final router = await _pumpNewsApp(tester);
    addTearDown(router.dispose);

    final newest = NewsFixtures.items[0];
    final second = NewsFixtures.items[1];
    final oldest = NewsFixtures.items[2];

    expect(find.byKey(Key('featured-news-${newest.id}')), findsOneWidget);
    expect(find.text(newest.title), findsOneWidget);
    expect(find.text(second.title), findsOneWidget);
    expect(find.text(oldest.title), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(second.title)).dy,
      lessThan(tester.getTopLeft(find.text(oldest.title)).dy),
    );
  });

  testWidgets('Tümü is selected initially and restores the full feed', (
    tester,
  ) async {
    final router = await _pumpNewsApp(tester);
    addTearDown(router.dispose);

    expect(_filter(tester, 'all').selected, isTrue);
    await tester.tap(find.byKey(const Key('news-filter-satellite')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('news-filter-all')));
    await tester.pump();

    expect(_filter(tester, 'all').selected, isTrue);
    for (final item in NewsFixtures.items) {
      expect(find.text(item.title), findsOneWidget);
    }
  });

  testWidgets('category filter shows only matching fixture news', (
    tester,
  ) async {
    final router = await _pumpNewsApp(tester);
    addTearDown(router.dispose);

    await tester.tap(find.byKey(const Key('news-filter-satellite')));
    await tester.pump();

    expect(find.text(NewsFixtures.items[1].title), findsOneWidget);
    expect(find.text(NewsFixtures.items[0].title), findsNothing);
    expect(find.text(NewsFixtures.items[2].title), findsNothing);
  });

  testWidgets('tapping an article opens detail with the correct content', (
    tester,
  ) async {
    final router = await _pumpNewsApp(tester);
    addTearDown(router.dispose);
    final item = NewsFixtures.items[1];

    await tester.tap(find.byKey(Key('news-feed-${item.id}')));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, AppRoutes.newsDetail(item.id));
    expect(find.byKey(NewsDetailPage.pageKey), findsOneWidget);
    expect(find.text(item.title), findsOneWidget);
    expect(find.text(item.summary), findsOneWidget);
    expect(find.textContaining(item.source), findsOneWidget);
  });

  testWidgets('invalid article ID shows a safe not-found state', (
    tester,
  ) async {
    final router = await _pumpNewsApp(
      tester,
      initialLocation: AppRoutes.newsDetail('missing-article'),
    );
    addTearDown(router.dispose);

    expect(find.byKey(const Key('news-not-found')), findsOneWidget);
    expect(find.text('Haber bulunamadı'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('external source action uses the shared launcher abstraction', (
    tester,
  ) async {
    final launcher = _FakeExternalUrlLauncher();
    final item = NewsFixtures.items.first;
    final router = await _pumpNewsApp(
      tester,
      initialLocation: AppRoutes.newsDetail(item.id),
      launcher: launcher,
    );
    addTearDown(router.dispose);

    await tester.tap(find.byKey(const Key('news-open-source')));
    await tester.pump();

    expect(launcher.openedUrls, [item.url]);
  });

  testWidgets('launcher failure gives user-visible feedback', (tester) async {
    final launcher = _FakeExternalUrlLauncher(result: false);
    final router = await _pumpNewsApp(
      tester,
      initialLocation: AppRoutes.newsDetail(NewsFixtures.items.first.id),
      launcher: launcher,
    );
    addTearDown(router.dispose);

    await tester.tap(find.byKey(const Key('news-open-source')));
    await tester.pump();

    expect(find.text('Haber kaynağı açılamadı.'), findsOneWidget);
  });

  testWidgets('shows loading state while repository stream is pending', (
    tester,
  ) async {
    final repository = _PendingNewsRepository();
    addTearDown(repository.dispose);
    await _pumpStandaloneNews(tester, repository);

    expect(find.byKey(const Key('news-loading')), findsOneWidget);
    expect(find.text('Haberler yükleniyor'), findsOneWidget);
  });

  testWidgets('shows empty state when repository has no news', (tester) async {
    await _pumpStandaloneNews(tester, FixtureNewsRepository(items: const []));

    expect(find.byKey(const Key('news-empty')), findsOneWidget);
    expect(find.text('Bu kategoride haber yok'), findsOneWidget);
  });

  testWidgets('repository error shows retry and retry resubscribes', (
    tester,
  ) async {
    final repository = _ErrorNewsRepository();
    await _pumpStandaloneNews(tester, repository);
    await tester.pump();

    expect(find.byKey(const Key('news-error')), findsOneWidget);
    expect(find.text('Haberler alınamadı'), findsOneWidget);

    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();
    await tester.pump();

    expect(repository.watchCalls, 2);
  });

  testWidgets('/app/news stays inside the persistent navigation shell', (
    tester,
  ) async {
    final router = await _pumpNewsApp(tester);
    addTearDown(router.dispose);

    expect(find.byKey(NewsPage.pageKey), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      3,
    );
  });

  testWidgets('compact phone width and text scaling do not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final router = await _pumpNewsApp(tester);
    addTearDown(router.dispose);
    await tester.scrollUntilVisible(
      find.text(NewsFixtures.items.last.title),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

FilterChip _filter(WidgetTester tester, String name) =>
    tester.widget(find.byKey(Key('news-filter-$name')));

Future<GoRouter> _pumpNewsApp(
  WidgetTester tester, {
  String initialLocation = AppRoutes.news,
  NewsRepository? repository,
  ExternalUrlLauncher? launcher,
}) async {
  final router = createAppRouter();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (repository != null)
          newsRepositoryProvider.overrideWithValue(repository),
        if (launcher != null)
          externalUrlLauncherProvider.overrideWithValue(launcher),
      ],
      child: App(router: router),
    ),
  );
  router.go(initialLocation);
  await tester.pumpAndSettle();
  return router;
}

Future<void> _pumpStandaloneNews(
  WidgetTester tester,
  NewsRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [newsRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: const NewsPage(),
      ),
    ),
  );
  await tester.pump();
}

class _FakeExternalUrlLauncher implements ExternalUrlLauncher {
  _FakeExternalUrlLauncher({this.result = true});

  final bool result;
  final List<Uri> openedUrls = [];

  @override
  Future<bool> open(Uri url) async {
    openedUrls.add(url);
    return result;
  }
}

class _PendingNewsRepository implements NewsRepository {
  final StreamController<List<NewsItem>> _controller = StreamController();

  @override
  Future<List<NewsItem>> getRecentNews({int limit = 20}) async => const [];

  @override
  Stream<List<NewsItem>> watchRecentNews({int limit = 20}) =>
      _controller.stream;

  Future<void> dispose() => _controller.close();
}

class _ErrorNewsRepository implements NewsRepository {
  int watchCalls = 0;

  @override
  Future<List<NewsItem>> getRecentNews({int limit = 20}) async => const [];

  @override
  Stream<List<NewsItem>> watchRecentNews({int limit = 20}) {
    watchCalls += 1;
    return Stream.error(StateError('fixture news failure'));
  }
}
