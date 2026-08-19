class AppConfig {
  const AppConfig({this.liveUrl});

  factory AppConfig.fromEnvironment() {
    const rawLiveUrl = String.fromEnvironment('QO100_LIVE_URL');
    return AppConfig(liveUrl: parseLiveUrl(rawLiveUrl));
  }

  final Uri? liveUrl;

  static Uri? parseLiveUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      return null;
    }
    return uri;
  }
}
