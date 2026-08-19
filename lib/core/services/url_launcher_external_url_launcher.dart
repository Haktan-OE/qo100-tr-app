import 'package:qo100_tr/core/services/external_url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherExternalUrlLauncher implements ExternalUrlLauncher {
  const UrlLauncherExternalUrlLauncher();

  @override
  Future<bool> open(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);
}
