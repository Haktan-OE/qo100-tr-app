import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/app.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/app/router/app_router.dart';
import 'package:qo100_tr/features/participation/data/fixtures/fixture_check_in_repository.dart';
import 'package:qo100_tr/features/participation/data/fixtures/fixture_session_repository.dart';
import 'package:qo100_tr/features/participation/data/fixtures/participation_fixtures.dart';
import 'package:qo100_tr/features/participation/domain/entities/check_in.dart';
import 'package:qo100_tr/features/participation/domain/repositories/check_in_repository.dart';
import 'package:qo100_tr/features/participation/domain/repositories/session_repository.dart';
import 'package:qo100_tr/features/participation/domain/services/check_in_factory.dart';
import 'package:qo100_tr/features/participation/presentation/participation_page.dart';
import 'package:qo100_tr/features/participation/presentation/providers/check_in_dependencies.dart';
import 'package:qo100_tr/features/participation/presentation/week_detail_placeholder_page.dart';
import 'package:qo100_tr/features/participation/presentation/widgets/check_in_action_card.dart';
import 'package:qo100_tr/features/participation/presentation/widgets/participation_type_selector.dart';
import 'package:qo100_tr/features/profile/domain/repositories/user_profile_repository.dart';

void main() {
  testWidgets('renders fixture session and saved operator identity', (
    tester,
  ) async {
    final repository = FixtureCheckInRepository(checkIns: const []);
    addTearDown(repository.dispose);
    final router = await _pumpParticipation(
      tester,
      checkInRepository: repository,
    );
    addTearDown(router.dispose);

    expect(
      find.text(ParticipationFixtures.activeSession.title),
      findsOneWidget,
    );
    expect(find.text('10489.777 MHz'), findsOneWidget);
    await _scrollTo(
      tester,
      find.byKey(const Key('participation-profile-callsign')),
    );
    expect(find.text('TA0AAA'), findsOneWidget);
    expect(find.text('Örnek Operatör'), findsOneWidget);
    expect(find.text('Ankara'), findsOneWidget);
    expect(find.text('KM69'), findsOneWidget);
  });

  testWidgets('Direkt and SWL selector changes the selected type', (
    tester,
  ) async {
    final repository = FixtureCheckInRepository(checkIns: const []);
    addTearDown(repository.dispose);
    final router = await _pumpParticipation(
      tester,
      checkInRepository: repository,
    );
    addTearDown(router.dispose);
    await _scrollTo(tester, find.byType(ParticipationTypeSelector));

    expect(_selectedType(tester), ParticipationType.direct);
    await tester.tap(find.text('SWL').first);
    await tester.pump();

    expect(_selectedType(tester), ParticipationType.swl);
  });

  testWidgets('submit shows success and updates list and statistics', (
    tester,
  ) async {
    final repository = FixtureCheckInRepository(checkIns: const []);
    addTearDown(repository.dispose);
    final router = await _pumpParticipation(
      tester,
      checkInRepository: repository,
    );
    addTearDown(router.dispose);

    await _scrollTo(tester, find.byKey(CheckInActionCard.submitButtonKey));
    await tester.tap(find.byKey(CheckInActionCard.submitButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('participation-success')), findsOneWidget);
    await _scrollTo(tester, find.text('TA0AAA').last);
    expect(find.text('TA0AAA'), findsNWidgets(2));
    await _scrollTo(
      tester,
      find.byKey(const Key('participation-direct-count')),
    );
    expect(_textAt(tester, const Key('participation-direct-count')), '1');
    expect(_textAt(tester, const Key('participation-swl-count')), '0');
    expect(_textAt(tester, const Key('participation-total-count')), '1');
  });

  testWidgets('shows already checked-in state and disables submission', (
    tester,
  ) async {
    final repository = FixtureCheckInRepository();
    addTearDown(repository.dispose);
    final router = await _pumpParticipation(
      tester,
      checkInRepository: repository,
    );
    addTearDown(router.dispose);

    await _scrollTo(
      tester,
      find.byKey(const Key('participation-already-checked-in')),
    );

    expect(
      find.byKey(const Key('participation-already-checked-in')),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(
      find.byKey(CheckInActionCard.submitButtonKey),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('shows empty state when there is no current session', (
    tester,
  ) async {
    final router = await _pumpParticipation(
      tester,
      sessionRepository: FixtureSessionRepository(sessions: const []),
    );
    addTearDown(router.dispose);

    expect(find.byKey(const Key('participation-no-session')), findsOneWidget);
    expect(find.text('Aktif oturum bulunmuyor'), findsOneWidget);
  });

  testWidgets('Hafta Detayı opens its placeholder route', (tester) async {
    final repository = FixtureCheckInRepository();
    addTearDown(repository.dispose);
    final router = await _pumpParticipation(
      tester,
      checkInRepository: repository,
    );
    addTearDown(router.dispose);

    await _scrollTo(tester, find.byKey(ParticipationPage.weekDetailButtonKey));
    await tester.tap(find.byKey(ParticipationPage.weekDetailButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(WeekDetailPlaceholderPage.pageKey), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.participationWeekDetail);
  });

  testWidgets('compact phone width and increased text scale do not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final repository = FixtureCheckInRepository();
    addTearDown(repository.dispose);
    final router = await _pumpParticipation(
      tester,
      checkInRepository: repository,
    );
    addTearDown(router.dispose);

    await _scrollTo(tester, find.byKey(ParticipationPage.weekDetailButtonKey));

    expect(find.byKey(ParticipationPage.weekDetailButtonKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final _fixedTime = DateTime.utc(2026, 8, 23, 18, 30);

Future<GoRouter> _pumpParticipation(
  WidgetTester tester, {
  SessionRepository? sessionRepository,
  CheckInRepository? checkInRepository,
  UserProfileRepository? profileRepository,
}) async {
  final router = createAppRouter();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (sessionRepository != null)
          sessionRepositoryProvider.overrideWithValue(sessionRepository),
        if (checkInRepository != null)
          checkInRepositoryProvider.overrideWithValue(checkInRepository),
        if (profileRepository != null)
          userProfileRepositoryProvider.overrideWithValue(profileRepository),
        checkInFactoryProvider.overrideWithValue(
          CheckInFactory(
            clock: () => _fixedTime,
            idGenerator: (timestamp) => 'widget-check-in',
          ),
        ),
      ],
      child: App(router: router),
    ),
  );
  router.go(AppRoutes.participation);
  await tester.pumpAndSettle();
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

ParticipationType _selectedType(WidgetTester tester) {
  return tester
      .widget<SegmentedButton<ParticipationType>>(
        find.byKey(const Key('participation-type-selector')),
      )
      .selected
      .single;
}

String? _textAt(WidgetTester tester, Key key) {
  return tester.widget<Text>(find.byKey(key)).data;
}
