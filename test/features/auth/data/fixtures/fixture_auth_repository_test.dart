import 'package:flutter_test/flutter_test.dart';
import 'package:qo100_tr/features/auth/data/fixtures/fixture_auth_repository.dart';
import 'package:qo100_tr/features/auth/domain/exceptions/auth_exceptions.dart';

void main() {
  test(
    'deterministic existing credentials sign in and emit auth state',
    () async {
      final repository = FixtureAuthRepository();
      addTearDown(repository.dispose);
      final states = repository.watchAuthUser().take(2).toList();
      final user = await repository.signIn(
        email: FixtureAuthRepository.existingEmail,
        password: FixtureAuthRepository.existingPassword,
      );
      expect(user.id, 'fixture-user-current');
      expect(await states, [null, user]);
    },
  );

  test('invalid credentials and duplicate registration are explicit', () async {
    final repository = FixtureAuthRepository();
    addTearDown(repository.dispose);
    await expectLater(
      repository.signIn(email: 'bad@example.com', password: 'bad'),
      throwsA(isA<InvalidCredentialsException>()),
    );
    await expectLater(
      repository.register(
        email: FixtureAuthRepository.existingEmail,
        password: 'anything',
      ),
      throwsA(isA<DuplicateAccountException>()),
    );
  });

  test('instances do not share registered or authenticated state', () async {
    final first = FixtureAuthRepository();
    final second = FixtureAuthRepository();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    await first.register(email: 'new@example.com', password: 'value');
    expect(await second.watchAuthUser().first, isNull);
    expect(
      await second.register(email: 'new@example.com', password: 'different'),
      isNotNull,
    );
  });
}
