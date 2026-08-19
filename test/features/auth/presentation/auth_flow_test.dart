import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qo100_tr/app/app.dart';
import 'package:qo100_tr/app/providers/repository_providers.dart';
import 'package:qo100_tr/app/router/app_router.dart';
import 'package:qo100_tr/app/router/auth_route_guard.dart';
import 'package:qo100_tr/features/auth/data/fixtures/fixture_auth_repository.dart';
import 'package:qo100_tr/features/auth/domain/entities/auth_user.dart';
import 'package:qo100_tr/features/auth/domain/repositories/auth_repository.dart';
import 'package:qo100_tr/features/auth/presentation/auth_form_page.dart';
import 'package:qo100_tr/features/auth/presentation/controllers/onboarding_controller.dart';
import 'package:qo100_tr/features/auth/presentation/onboarding_page.dart';
import 'package:qo100_tr/features/news/presentation/news_page.dart';
import 'package:qo100_tr/features/profile/data/fixtures/fixture_user_profile_repository.dart';
import 'package:qo100_tr/features/profile/data/fixtures/profile_fixtures.dart';

void main() {
  testWidgets('unauthenticated bootstrap goes to login and renders form', (
    tester,
  ) async {
    final harness = await _pumpGuarded(tester);
    addTearDown(harness.dispose);
    expect(harness.router.state.uri.path, AppRoutes.login);
    expect(find.byKey(AuthFormPage.loginKey), findsOneWidget);
    expect(find.text('E-posta'), findsOneWidget);
  });

  testWidgets('login and register screens navigate between each other', (
    tester,
  ) async {
    final harness = await _pumpGuarded(tester);
    addTearDown(harness.dispose);
    await tester.tap(find.byKey(const Key('auth-alternate')));
    await tester.pumpAndSettle();
    expect(find.byKey(AuthFormPage.registerKey), findsOneWidget);
    await tester.tap(find.byKey(const Key('auth-alternate')));
    await tester.pumpAndSettle();
    expect(find.byKey(AuthFormPage.loginKey), findsOneWidget);
  });

  testWidgets('blank login shows validation', (tester) async {
    final harness = await _pumpGuarded(tester);
    addTearDown(harness.dispose);
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pump();
    expect(find.text('Geçerli bir e-posta girin.'), findsOneWidget);
    expect(find.text('Şifre zorunludur.'), findsOneWidget);
  });

  testWidgets('repeated login submit is disabled while pending', (
    tester,
  ) async {
    final auth = _PendingAuthRepository();
    final harness = await _pumpGuarded(tester, auth: auth);
    addTearDown(harness.dispose);
    await _enterLogin(tester, 'user@example.com', 'password');
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('auth-submit')))
          .onPressed,
      isNull,
    );
    expect(auth.signInCalls, 1);
    auth.completer.completeError(StateError('done'));
    await tester.pump();
  });

  testWidgets('existing fixture login enters home with five tabs', (
    tester,
  ) async {
    final harness = await _pumpGuarded(tester);
    addTearDown(harness.dispose);
    await _enterLogin(
      tester,
      FixtureAuthRepository.existingEmail,
      FixtureAuthRepository.existingPassword,
    );
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();
    expect(harness.router.state.uri.path, AppRoutes.home);
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.destinations, hasLength(5));
  });

  testWidgets('fixture registration enters onboarding', (tester) async {
    final harness = await _pumpGuarded(tester);
    addTearDown(harness.dispose);
    harness.router.go(AppRoutes.register);
    await tester.pumpAndSettle();
    await _enterRegistration(tester);
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();
    expect(harness.router.state.uri.path, AppRoutes.onboarding);
    expect(find.byKey(OnboardingPage.pageKey), findsOneWidget);
  });

  testWidgets('authenticated user without matching profile is gated', (
    tester,
  ) async {
    final auth = FixtureAuthRepository(
      initialUser: const AuthUser(id: 'new-user', email: 'new@example.com'),
    );
    final profile = FixtureUserProfileRepository.empty();
    final harness = await _pumpGuarded(tester, auth: auth, profiles: profile);
    addTearDown(harness.dispose);
    expect(harness.router.state.uri.path, AppRoutes.onboarding);
  });

  testWidgets('onboarding validates required fields', (tester) async {
    final auth = FixtureAuthRepository(
      initialUser: const AuthUser(id: 'new-user', email: 'new@example.com'),
    );
    final harness = await _pumpGuarded(
      tester,
      auth: auth,
      profiles: FixtureUserProfileRepository.empty(),
    );
    addTearDown(harness.dispose);
    await _scrollTo(tester, find.byKey(const Key('onboarding-submit')));
    await tester.tap(find.byKey(const Key('onboarding-submit')));
    await tester.pump();
    expect(find.text('Bu alan zorunludur.'), findsNWidgets(4));
  });

  testWidgets(
    'successful onboarding persists matching profile and enters home',
    (tester) async {
      const user = AuthUser(id: 'new-user', email: 'new@example.com');
      final profile = FixtureUserProfileRepository.empty();
      final harness = await _pumpGuarded(
        tester,
        auth: FixtureAuthRepository(initialUser: user),
        profiles: profile,
      );
      addTearDown(harness.dispose);
      for (final entry in const {
        'callsign': 'TA1NEW',
        'name': 'Yeni Operatör',
        'city': 'İzmir',
        'locator': 'KM38',
      }.entries) {
        await tester.enterText(
          find.byKey(Key('onboarding-${entry.key}')),
          entry.value,
        );
      }
      tester.testTextInput.hide();
      await _scrollTo(tester, find.byKey(const Key('onboarding-submit')));
      await tester.ensureVisible(find.byKey(const Key('onboarding-submit')));
      final container = ProviderScope.containerOf(
        tester.element(find.byKey(OnboardingPage.pageKey)),
      );
      await tester.tap(find.byKey(const Key('onboarding-submit')));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(
        container.read(onboardingControllerProvider).status,
        OnboardingStatus.success,
      );
      expect((await profile.getCurrentUserProfile())?.id, user.id);
      expect(harness.router.state.uri.path, AppRoutes.home);
    },
  );

  testWidgets('unauthenticated app deep link is gated then preserved', (
    tester,
  ) async {
    final harness = await _pumpGuarded(tester, requested: AppRoutes.news);
    addTearDown(harness.dispose);
    expect(harness.router.state.uri.path, AppRoutes.login);
    await _enterLogin(
      tester,
      FixtureAuthRepository.existingEmail,
      FixtureAuthRepository.existingPassword,
    );
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pumpAndSettle();
    expect(harness.router.state.uri.path, AppRoutes.news);
    expect(find.byKey(NewsPage.pageKey), findsOneWidget);
  });

  testWidgets('profile-complete deep link reaches requested app route', (
    tester,
  ) async {
    final harness = await _pumpGuarded(
      tester,
      auth: FixtureAuthRepository(
        initialUser: FixtureAuthRepository.existingUser,
      ),
      requested: AppRoutes.news,
    );
    addTearDown(harness.dispose);
    expect(harness.router.state.uri.path, AppRoutes.news);
  });

  testWidgets('repository errors show recoverable feedback', (tester) async {
    final harness = await _pumpGuarded(tester, auth: _ErrorAuthRepository());
    addTearDown(harness.dispose);
    await _enterLogin(tester, 'user@example.com', 'password');
    await tester.tap(find.byKey(const Key('auth-submit')));
    await tester.pump();
    expect(find.byKey(const Key('auth-error')), findsOneWidget);
  });

  testWidgets('compact login with text scaling does not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final harness = await _pumpGuarded(tester);
    addTearDown(harness.dispose);
    expect(tester.takeException(), isNull);
  });
}

typedef _Harness = ({GoRouter router, Future<void> Function() dispose});

Future<_Harness> _pumpGuarded(
  WidgetTester tester, {
  AuthRepository? auth,
  FixtureUserProfileRepository? profiles,
  String? requested,
}) async {
  final authRepo = auth ?? FixtureAuthRepository();
  final profileRepo =
      profiles ??
      FixtureUserProfileRepository(currentUser: ProfileFixtures.currentUser);
  final guard = AuthRouteGuard(authRepo, profileRepo);
  final router = createAppRouter(guard: guard);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
        userProfileRepositoryProvider.overrideWithValue(profileRepo),
      ],
      child: App(router: router),
    ),
  );
  if (requested != null) router.go(requested);
  await tester.pumpAndSettle();
  return (
    router: router,
    dispose: () async {
      router.dispose();
      guard.dispose();
      await profileRepo.dispose();
      if (authRepo is FixtureAuthRepository) await authRepo.dispose();
    },
  );
}

Future<void> _enterLogin(
  WidgetTester tester,
  String email,
  String password,
) async {
  await tester.enterText(find.byKey(const Key('auth-email')), email);
  await tester.enterText(find.byKey(const Key('auth-password')), password);
}

Future<void> _enterRegistration(WidgetTester tester) async {
  await _enterLogin(tester, 'new@example.com', 'password');
  await tester.enterText(
    find.byKey(const Key('auth-confirmation')),
    'password',
  );
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
}

class _PendingAuthRepository implements AuthRepository {
  final completer = Completer<AuthUser>();
  int signInCalls = 0;
  @override
  Future<AuthUser?> getCurrentUser() async => null;
  @override
  Stream<AuthUser?> watchAuthUser() => Stream.value(null);
  @override
  Future<AuthUser> signIn({required String email, required String password}) {
    signInCalls++;
    return completer.future;
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) => throw UnimplementedError();
  @override
  Future<void> signOut() async {}
}

class _ErrorAuthRepository implements AuthRepository {
  @override
  Future<AuthUser?> getCurrentUser() async => null;
  @override
  Stream<AuthUser?> watchAuthUser() => Stream.value(null);
  @override
  Future<AuthUser> signIn({required String email, required String password}) =>
      Future.error(StateError('failure'));
  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) => Future.error(StateError('failure'));
  @override
  Future<void> signOut() async {}
}
