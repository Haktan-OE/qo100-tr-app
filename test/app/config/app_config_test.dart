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

  group('AppConfig.parseBackend', () {
    test('selects Firebase only for an explicit firebase value', () {
      expect(AppConfig.parseBackend('firebase'), AppBackend.firebase);
      expect(AppConfig.parseBackend(' FIREBASE '), AppBackend.firebase);
    });

    test('keeps fixture as the safe default', () {
      expect(AppConfig.parseBackend(''), AppBackend.fixture);
      expect(AppConfig.parseBackend('fixture'), AppBackend.fixture);
      expect(AppConfig.parseBackend('unknown'), AppBackend.fixture);
    });
  });
}
