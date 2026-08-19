import 'package:flutter_test/flutter_test.dart';
import 'package:qo100_tr/app/config/app_config.dart';

void main() {
  group('AppConfig.parseLiveUrl', () {
    test('accepts an absolute HTTPS URL', () {
      expect(
        AppConfig.parseLiveUrl('https://example.com/live'),
        Uri.parse('https://example.com/live'),
      );
    });

    test('rejects missing, relative, and insecure URLs', () {
      expect(AppConfig.parseLiveUrl(''), isNull);
      expect(AppConfig.parseLiveUrl('/live'), isNull);
      expect(AppConfig.parseLiveUrl('http://example.com/live'), isNull);
      expect(AppConfig.parseLiveUrl('not a url'), isNull);
    });
  });
}
