import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qo100_tr/core/services/external_url_launcher.dart';
import 'package:qo100_tr/core/services/url_launcher_external_url_launcher.dart';

final externalUrlLauncherProvider = Provider<ExternalUrlLauncher>(
  (ref) => const UrlLauncherExternalUrlLauncher(),
);
