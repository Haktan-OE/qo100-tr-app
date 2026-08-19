import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/features/live/presentation/webview/live_webview_factory.dart';

final liveWebViewFactoryProvider = Provider<LiveWebViewFactory>(
  (ref) => const PlatformLiveWebViewFactory(),
);
