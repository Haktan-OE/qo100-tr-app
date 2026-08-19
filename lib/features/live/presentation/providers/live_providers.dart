import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/features/live/data/services/url_launcher_external_url_launcher.dart';
import 'package:qo100_tr/features/live/domain/services/external_url_launcher.dart';
import 'package:qo100_tr/features/live/presentation/webview/live_webview_factory.dart';

final externalUrlLauncherProvider = Provider<ExternalUrlLauncher>(
  (ref) => const UrlLauncherExternalUrlLauncher(),
);

final liveWebViewFactoryProvider = Provider<LiveWebViewFactory>(
  (ref) => const PlatformLiveWebViewFactory(),
);
