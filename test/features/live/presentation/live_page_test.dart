import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qo100_tr/app/app.dart';
import 'package:qo100_tr/app/config/app_config.dart';
import 'package:qo100_tr/app/providers/app_config_provider.dart';
import 'package:qo100_tr/app/router/app_router.dart';
import 'package:qo100_tr/features/live/domain/services/external_url_launcher.dart';
import 'package:qo100_tr/features/live/presentation/live_page.dart';
import 'package:qo100_tr/features/live/presentation/providers/live_providers.dart';
import 'package:qo100_tr/features/live/presentation/webview/live_webview_factory.dart';

void main() {
  testWidgets('missing live URL shows configuration state without a WebView', (
    tester,
  ) async {
    final webView = _FakeLiveWebViewFactory();
    await _pumpLivePage(tester, config: const AppConfig(), webView: webView);

    expect(find.text('Canlı yayın kaynağı yapılandırılmadı'), findsOneWidget);
    expect(find.byKey(_FakeLiveWebViewFactory.viewKey), findsNothing);
    expect(webView.createCount, 0);
  });

  testWidgets('valid URL renders the live container in loading state', (
    tester,
  ) async {
    final webView = _FakeLiveWebViewFactory();
    await _pumpLivePage(tester, webView: webView);

    expect(find.byKey(_FakeLiveWebViewFactory.viewKey), findsOneWidget);
    expect(find.text('example.com'), findsOneWidget);
    expect(find.text('Canlı yayın yükleniyor…'), findsOneWidget);
    expect(webView.lastUrl, _liveUrl);
  });

  testWidgets('successful page load changes state to ready', (tester) async {
    final webView = _FakeLiveWebViewFactory();
    await _pumpLivePage(tester, webView: webView);

    webView.onReady!();
    await tester.pump();

    expect(find.text('Dinlemeye hazır'), findsOneWidget);
    expect(find.text('Canlı yayın yükleniyor…'), findsNothing);
  });

  testWidgets('load failure shows error and retry requests a reload', (
    tester,
  ) async {
    final webView = _FakeLiveWebViewFactory();
    await _pumpLivePage(tester, webView: webView);

    webView.onError!('network unavailable');
    await tester.pump();

    expect(find.text('Yayın yüklenemedi'), findsOneWidget);
    expect(find.byKey(const Key('live-error-retry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('live-error-retry')));
    await tester.pump();

    expect(webView.lastReloadRequest, 1);
    expect(find.text('Canlı yayın yükleniyor…'), findsOneWidget);
  });

  testWidgets('reload action requests a WebView reload', (tester) async {
    final webView = _FakeLiveWebViewFactory();
    await _pumpLivePage(tester, webView: webView);

    await _scrollTo(tester, find.byKey(const Key('live-reload')));
    await tester.tap(find.byKey(const Key('live-reload')));
    await tester.pump();

    expect(webView.lastReloadRequest, 1);
  });

  testWidgets('external browser action uses the launcher abstraction', (
    tester,
  ) async {
    final webView = _FakeLiveWebViewFactory();
    final launcher = _FakeExternalUrlLauncher();
    await _pumpLivePage(tester, webView: webView, launcher: launcher);

    await _scrollTo(tester, find.byKey(const Key('live-open-external')));
    await tester.tap(find.byKey(const Key('live-open-external')));
    await tester.pump();

    expect(launcher.openedUrls, [_liveUrl]);
  });

  testWidgets('/app/live renders inside the persistent navigation shell', (
    tester,
  ) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final webView = _FakeLiveWebViewFactory();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig(liveUrl: _liveUrl)),
          liveWebViewFactoryProvider.overrideWithValue(webView),
        ],
        child: App(router: router),
      ),
    );
    router.go(AppRoutes.live);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(LivePage.pageKey), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
  });

  testWidgets('compact phone width and increased text scale do not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final webView = _FakeLiveWebViewFactory();
    await _pumpLivePage(
      tester,
      webView: webView,
      textScaler: const TextScaler.linear(1.3),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
}

final _liveUrl = Uri.parse('https://example.com/live');

Future<void> _pumpLivePage(
  WidgetTester tester, {
  AppConfig? config,
  required _FakeLiveWebViewFactory webView,
  _FakeExternalUrlLauncher? launcher,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(
          config ?? AppConfig(liveUrl: _liveUrl),
        ),
        liveWebViewFactoryProvider.overrideWithValue(webView),
        if (launcher != null)
          externalUrlLauncherProvider.overrideWithValue(launcher),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: MediaQuery(
          data: MediaQueryData(textScaler: textScaler),
          child: const LivePage(),
        ),
      ),
    ),
  );
  await tester.pump();
}

class _FakeLiveWebViewFactory implements LiveWebViewFactory {
  static const viewKey = Key('fake-live-webview');

  int createCount = 0;
  int? lastReloadRequest;
  Uri? lastUrl;
  VoidCallback? onLoading;
  VoidCallback? onReady;
  ValueChanged<String>? onError;

  @override
  Widget create({
    required Uri url,
    required int reloadRequest,
    required VoidCallback onLoading,
    required VoidCallback onReady,
    required ValueChanged<String> onError,
  }) {
    createCount += 1;
    lastUrl = url;
    lastReloadRequest = reloadRequest;
    this.onLoading = onLoading;
    this.onReady = onReady;
    this.onError = onError;
    return const ColoredBox(key: viewKey, color: Colors.black);
  }
}

class _FakeExternalUrlLauncher implements ExternalUrlLauncher {
  final List<Uri> openedUrls = [];

  @override
  Future<bool> open(Uri url) async {
    openedUrls.add(url);
    return true;
  }
}
