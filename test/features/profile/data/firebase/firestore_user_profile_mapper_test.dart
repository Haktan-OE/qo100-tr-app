import 'package:flutter_test/flutter_test.dart';
import 'package:qo100_tr/features/profile/data/firebase/firestore_user_profile_mapper.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';
import 'package:qo100_tr/features/profile/domain/exceptions/profile_exceptions.dart';

void main() {
  const profile = UserProfile(
    id: 'firebase-uid',
    callsign: 'TA1ABC',
    name: 'Örnek Operatör',
    city: 'İstanbul',
    locator: 'KN41',
    antenna: '90 cm çanak',
    gear: 'PlutoSDR',
    role: UserRole.moderator,
  );

  test('maps a Firestore profile map and derives id from the document', () {
    final result = FirestoreUserProfileMapper.fromMap(
      documentId: 'firebase-uid',
      data: FirestoreUserProfileMapper.toMap(profile),
    );

    expect(result.id, 'firebase-uid');
    expect(result.callsign, profile.callsign);
    expect(result.name, profile.name);
    expect(result.city, profile.city);
    expect(result.locator, profile.locator);
    expect(result.antenna, profile.antenna);
    expect(result.gear, profile.gear);
    expect(result.role, UserRole.moderator);
  });

  test('write map excludes redundant id and preserves profile fields', () {
    final data = FirestoreUserProfileMapper.toMap(profile);

    expect(data, isNot(contains('id')));
    expect(data['callsign'], 'TA1ABC');
    expect(data['role'], 'moderator');
    expect(data['gear'], 'PlutoSDR');
  });

  test('missing optional fields map to null', () {
    final result = FirestoreUserProfileMapper.fromMap(
      documentId: 'firebase-uid',
      data: const {
        'callsign': 'TA1ABC',
        'name': 'Operatör',
        'city': 'Ankara',
        'locator': 'KM69',
        'role': 'member',
      },
    );

    expect(result.antenna, isNull);
    expect(result.gear, isNull);
  });

  test('unknown or missing roles safely fall back to member', () {
    for (final role in [null, 'owner', 42]) {
      final result = FirestoreUserProfileMapper.fromMap(
        documentId: 'firebase-uid',
        data: {
          'callsign': 'TA1ABC',
          'name': 'Operatör',
          'city': 'Ankara',
          'locator': 'KM69',
          'role': role,
        },
      );
      expect(result.role, UserRole.member);
    }
  });

  test('rejects writes when authenticated uid and profile id differ', () {
    expect(
      () => FirestoreUserProfileMapper.assertUidMatchesProfile(
        'other-user',
        profile,
      ),
      throwsA(isA<ProfileIdentityMismatchException>()),
    );
    expect(
      () => FirestoreUserProfileMapper.assertUidMatchesProfile(
        'firebase-uid',
        profile,
      ),
      returnsNormally,
    );
  });
}
