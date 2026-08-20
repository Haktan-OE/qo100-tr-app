enum AppBackend { fixture, firebase }

class AppConfig {
  const AppConfig({this.liveUrl, this.backend = AppBackend.fixture});

  factory AppConfig.fromEnvironment() {
    const rawLiveUrl = String.fromEnvironment('QO100_LIVE_URL');
    const rawBackend = String.fromEnvironment('QO100_BACKEND');
    return AppConfig(
      liveUrl: parseLiveUrl(rawLiveUrl),
      backend: parseBackend(rawBackend),
    );
  }

  final Uri? liveUrl;
  final AppBackend backend;

  static AppBackend parseBackend(String value) =>
      switch (value.trim().toLowerCase()) {
        'firebase' => AppBackend.firebase,
        _ => AppBackend.fixture,
      };

  static Uri? parseLiveUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      return null;
    }
    return uri;
  }
}
