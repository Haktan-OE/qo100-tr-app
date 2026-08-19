import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/app.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/app/router/app_router.dart';
import 'package:qo100_tr/features/home/presentation/home_page.dart';
import 'package:qo100_tr/features/home/presentation/widgets/home_action_card.dart';
import 'package:qo100_tr/features/home/presentation/widgets/session_hero_card.dart';
import 'package:qo100_tr/features/live/presentation/live_page.dart';
import 'package:qo100_tr/features/news/data/fixtures/news_fixtures.dart';
import 'package:qo100_tr/features/news/presentation/news_page.dart';
import 'package:qo100_tr/features/participation/domain/entities/community_session.dart';
import 'package:qo100_tr/features/participation/domain/repositories/session_repository.dart';
import 'package:qo100_tr/features/participation/presentation/participation_page.dart';

void main() {
  testWidgets('renders fixture session data and repository frequency', (
    tester,
  ) async {
    final router = await _pumpApp(tester);
    addTearDown(router.dispose);

    expect(find.text('TA-NET 777 Örnek Haftalık Buluşma'), findsOneWidget);
    expect(find.text('10489.777 MHz'), findsOneWidget);
    expect(find.text('23 Ağustos 2026 • 18:00 UTC'), findsOneWidget);
  });

  testWidgets('renders direct, SWL, and total participation counts', (
    tester,
  ) async {
    final router = await _pumpApp(tester);
    addTearDown(router.dispose);

    await _scrollTo(tester, find.byKey(const Key('home-direct-count')));

    expect(_textAt(tester, const Key('home-direct-count')), '1');
    expect(_textAt(tester, const Key('home-swl-count')), '1');
    expect(_textAt(tester, const Key('home-total-count')), '2');
  });

  testWidgets('renders the latest fixture news items', (tester) async {
    final router = await _pumpApp(tester);
    addTearDown(router.dispose);
    final latest = NewsFixtures.items.first;
    final second = NewsFixtures.items[1];

    await _scrollTo(tester, find.text(latest.title));

    expect(find.text(latest.title), findsOneWidget);
    expect(find.text(second.title), findsOneWidget);
  });

  testWidgets('Canlı Dinle navigates to the live tab', (tester) async {
    final router = await _pumpApp(tester);
    addTearDown(router.dispose);

    await tester.tap(find.byKey(SessionHeroCard.liveButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(LivePage.pageKey), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.live);
  });

  testWidgets('Yoklamaya Katıl navigates to the participation tab', (
    tester,
  ) async {
    final router = await _pumpApp(tester);
    addTearDown(router.dispose);

    await _scrollTo(tester, find.byKey(HomeActionCard.joinButtonKey));
    await tester.tap(find.byKey(HomeActionCard.joinButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(ParticipationPage.pageKey), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.participation);
  });

  testWidgets('Tüm Haberler navigates to the news tab', (tester) async {
    final router = await _pumpApp(tester);
    addTearDown(router.dispose);

    await _scrollTo(tester, find.byKey(HomePage.allNewsButtonKey));
    await tester.tap(find.byKey(HomePage.allNewsButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(NewsPage.pageKey), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.news);
  });

  testWidgets('shows the session loading state', (tester) async {
    final repository = _PendingSessionRepository();
    addTearDown(repository.dispose);
    final router = await _pumpApp(
      tester,
      sessionRepository: repository,
      settle: false,
    );
    addTearDown(router.dispose);

    expect(find.byKey(const Key('home-session-loading')), findsOneWidget);
    expect(find.text('Oturum bilgisi yükleniyor'), findsOneWidget);
  });

  testWidgets('shows an empty state when there is no current session', (
    tester,
  ) async {
    final router = await _pumpApp(
      tester,
      sessionRepository: const _EmptySessionRepository(),
    );
    addTearDown(router.dispose);

    expect(find.byKey(const Key('home-no-current-session')), findsOneWidget);
    expect(find.text('Aktif oturum bulunmuyor'), findsOneWidget);
  });

  testWidgets('supports a compact phone width and increased text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final router = await _pumpApp(tester);
    addTearDown(router.dispose);

    await _scrollTo(tester, find.text(NewsFixtures.items.last.title));

    expect(find.text(NewsFixtures.items.last.title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<GoRouter> _pumpApp(
  WidgetTester tester, {
  SessionRepository? sessionRepository,
  bool settle = true,
}) async {
  final router = createAppRouter();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (sessionRepository != null)
          sessionRepositoryProvider.overrideWithValue(sessionRepository),
      ],
      child: App(router: router),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return router;
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

String? _textAt(WidgetTester tester, Key key) {
  return tester.widget<Text>(find.byKey(key)).data;
}

class _PendingSessionRepository implements SessionRepository {
  final StreamController<CommunitySession?> _controller =
      StreamController<CommunitySession?>();

  @override
  Future<List<CommunitySession>> getRecentSessions() async => const [];

  @override
  Stream<CommunitySession?> watchCurrentSession() => _controller.stream;

  Future<void> dispose() => _controller.close();
}

class _EmptySessionRepository implements SessionRepository {
  const _EmptySessionRepository();

  @override
  Future<List<CommunitySession>> getRecentSessions() async => const [];

  @override
  Stream<CommunitySession?> watchCurrentSession() => Stream.value(null);
}
