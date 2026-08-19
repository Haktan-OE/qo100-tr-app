import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/app.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/app/router/app_router.dart';
import 'package:qo100_tr/features/profile/data/fixtures/fixture_user_profile_repository.dart';
import 'package:qo100_tr/features/profile/data/fixtures/profile_fixtures.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';
import 'package:qo100_tr/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:qo100_tr/features/profile/presentation/profile_edit_page.dart';

void main() {
  testWidgets('fixture profile and station fields render', (tester) async {
    final result = await _pumpProfile(tester);
    addTearDown(result.dispose);

    expect(find.text('TA0AAA'), findsOneWidget);
    expect(find.text('Örnek Operatör'), findsOneWidget);
    expect(find.text('Ankara • KM69'), findsOneWidget);
    expect(find.text('80 cm ofset çanak'), findsOneWidget);
    expect(find.text('Örnek SDR istasyonu'), findsOneWidget);
  });

  testWidgets('participation summary is derived from repositories', (
    tester,
  ) async {
    final result = await _pumpProfile(tester);
    addTearDown(result.dispose);
    await _scrollTo(tester, find.byKey(const Key('profile-total-count')));

    expect(_text(tester, 'profile-total-count'), '1');
    expect(_text(tester, 'profile-direct-count'), '1');
    expect(_text(tester, 'profile-swl-count'), '0');
  });

  testWidgets('edit route opens and current values populate the form', (
    tester,
  ) async {
    final result = await _pumpProfile(tester);
    addTearDown(result.dispose);
    await _scrollTo(tester, find.byKey(const Key('profile-edit-button')));
    await tester.tap(find.byKey(const Key('profile-edit-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(ProfileEditPage.pageKey), findsOneWidget);
    expect(result.router.state.uri.path, AppRoutes.profileEdit);
    expect(_field(tester, 'callsign').controller?.text, 'TA0AAA');
    expect(_field(tester, 'locator').controller?.text, 'KM69');
  });

  testWidgets('required fields show validation and are not saved', (
    tester,
  ) async {
    final repository = FixtureUserProfileRepository();
    final result = await _pumpProfile(
      tester,
      repository: repository,
      initialLocation: AppRoutes.profileEdit,
    );
    addTearDown(result.dispose);
    await tester.enterText(
      find.byKey(const Key('profile-field-callsign')),
      '   ',
    );
    await _scrollTo(tester, find.byKey(const Key('profile-save-button')));
    await tester.tap(find.byKey(const Key('profile-save-button')));
    await tester.pump();

    expect(find.text('Bu alan zorunludur.'), findsOneWidget);
    expect((await repository.getCurrentUserProfile())?.callsign, 'TA0AAA');
  });

  testWidgets('successful save updates repository and overview', (
    tester,
  ) async {
    final repository = FixtureUserProfileRepository();
    final result = await _pumpProfile(
      tester,
      repository: repository,
      initialLocation: AppRoutes.profileEdit,
    );
    addTearDown(result.dispose);
    await tester.enterText(
      find.byKey(const Key('profile-field-callsign')),
      '  TA1NEW  ',
    );
    await _scrollTo(tester, find.byKey(const Key('profile-save-button')));
    await tester.tap(find.byKey(const Key('profile-save-button')));
    await tester.pumpAndSettle();

    expect((await repository.getCurrentUserProfile())?.callsign, 'TA1NEW');
    expect(result.router.state.uri.path, AppRoutes.profile);
    expect(find.text('TA1NEW'), findsOneWidget);
  });

  testWidgets('save failure displays recoverable feedback', (tester) async {
    final repository = _TestProfileRepository(
      profile: ProfileFixtures.currentUser,
      failSave: true,
    );
    final result = await _pumpProfile(
      tester,
      repository: repository,
      initialLocation: AppRoutes.profileEdit,
    );
    addTearDown(result.dispose);
    await _scrollTo(tester, find.byKey(const Key('profile-save-button')));
    await tester.tap(find.byKey(const Key('profile-save-button')));
    await tester.pump();

    expect(find.byKey(const Key('profile-save-error')), findsOneWidget);
    expect(find.textContaining('Profil kaydedilemedi'), findsOneWidget);
  });

  testWidgets('cancel returns without saving edits', (tester) async {
    final repository = FixtureUserProfileRepository();
    final result = await _pumpProfile(
      tester,
      repository: repository,
      initialLocation: AppRoutes.profileEdit,
    );
    addTearDown(result.dispose);
    await tester.enterText(
      find.byKey(const Key('profile-field-name')),
      'Değişmemeli',
    );
    await _scrollTo(tester, find.byKey(const Key('profile-cancel-button')));
    await tester.tap(find.byKey(const Key('profile-cancel-button')));
    await tester.pumpAndSettle();

    expect((await repository.getCurrentUserProfile())?.name, 'Örnek Operatör');
  });

  testWidgets('profile loading state renders', (tester) async {
    final repository = _PendingProfileRepository();
    final result = await _pumpProfile(
      tester,
      repository: repository,
      settle: false,
    );
    addTearDown(result.dispose);
    addTearDown(repository.dispose);
    expect(find.byKey(const Key('profile-loading')), findsOneWidget);
  });

  testWidgets('profile unavailable state renders', (tester) async {
    final result = await _pumpProfile(
      tester,
      repository: _TestProfileRepository(profile: null),
    );
    addTearDown(result.dispose);
    expect(find.byKey(const Key('profile-unavailable')), findsOneWidget);
  });

  testWidgets('repository error shows retry and resubscribes', (tester) async {
    final repository = _ErrorProfileRepository();
    final result = await _pumpProfile(tester, repository: repository);
    addTearDown(result.dispose);
    expect(find.byKey(const Key('profile-error')), findsOneWidget);
    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();
    await tester.pump();
    expect(repository.watchCalls, 2);
  });

  testWidgets('/app/profile remains inside persistent shell', (tester) async {
    final result = await _pumpProfile(tester);
    addTearDown(result.dispose);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      4,
    );
  });

  testWidgets('compact width and increased text scaling do not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final result = await _pumpProfile(tester);
    addTearDown(result.dispose);
    await _scrollTo(tester, find.textContaining('Bildirim tercihleri'));
    expect(tester.takeException(), isNull);
  });
}

typedef _PumpResult = ({GoRouter router, Future<void> Function() dispose});

Future<_PumpResult> _pumpProfile(
  WidgetTester tester, {
  UserProfileRepository? repository,
  String initialLocation = AppRoutes.profile,
  bool settle = true,
}) async {
  final owned = repository == null ? FixtureUserProfileRepository() : null;
  final effective = repository ?? owned!;
  final router = createAppRouter();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [userProfileRepositoryProvider.overrideWithValue(effective)],
      child: App(router: router),
    ),
  );
  router.go(initialLocation);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return (
    router: router,
    dispose: () async {
      router.dispose();
      await owned?.dispose();
      if (repository is FixtureUserProfileRepository) {
        await repository.dispose();
      }
    },
  );
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

TextField _field(WidgetTester tester, String name) =>
    tester.widget(find.byKey(Key('profile-field-$name')));

String? _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data;

class _TestProfileRepository implements UserProfileRepository {
  _TestProfileRepository({required this.profile, this.failSave = false});
  UserProfile? profile;
  final bool failSave;
  final StreamController<UserProfile?> _controller =
      StreamController.broadcast();

  @override
  Future<UserProfile?> getCurrentUserProfile() async => profile;
  @override
  Stream<UserProfile?> watchCurrentUserProfile() async* {
    yield profile;
    yield* _controller.stream;
  }

  @override
  Future<UserProfile> updateCurrentUserProfile(UserProfile value) async {
    if (failSave) throw StateError('save failed');
    profile = value;
    _controller.add(value);
    return value;
  }
}

class _PendingProfileRepository implements UserProfileRepository {
  final StreamController<UserProfile?> _controller = StreamController();
  @override
  Future<UserProfile?> getCurrentUserProfile() async => null;
  @override
  Stream<UserProfile?> watchCurrentUserProfile() => _controller.stream;
  @override
  Future<UserProfile> updateCurrentUserProfile(UserProfile profile) async =>
      profile;
  Future<void> dispose() => _controller.close();
}

class _ErrorProfileRepository implements UserProfileRepository {
  int watchCalls = 0;
  @override
  Future<UserProfile?> getCurrentUserProfile() async => null;
  @override
  Stream<UserProfile?> watchCurrentUserProfile() {
    watchCalls += 1;
    return Stream.error(StateError('profile error'));
  }

  @override
  Future<UserProfile> updateCurrentUserProfile(UserProfile profile) async =>
      profile;
}
