import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:qo100_tr/features/profile/data/firebase/firestore_user_profile_data_source.dart';
import 'package:qo100_tr/features/profile/data/firebase/firestore_user_profile_repository.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';
import 'package:qo100_tr/features/profile/domain/exceptions/profile_exceptions.dart';

void main() {
  const userAProfile = UserProfile(
    id: 'user-a',
    callsign: 'TA1AAA',
    name: 'User A',
    city: 'Ankara',
    locator: 'KM69',
    role: UserRole.member,
  );

  test(
    'discards an in-flight read when the authenticated uid changes',
    () async {
      final source = _ControllableProfileDataSource('user-a');
      final repository = FirestoreUserProfileRepository.withDataSource(source);

      final result = repository.getCurrentUserProfile();
      expect(source.readUid, 'user-a');

      source.currentUid = 'user-b';
      source.readCompleter.complete(_profileMap(userAProfile));

      expect(await result, isNull);
      await source.dispose();
    },
  );

  test('does not report a stale in-flight write as successful', () async {
    final source = _ControllableProfileDataSource('user-a');
    final repository = FirestoreUserProfileRepository.withDataSource(source);

    final result = repository.updateCurrentUserProfile(userAProfile);
    expect(source.writeUid, 'user-a');

    source.currentUid = 'user-b';
    source.writeCompleter.complete();

    await expectLater(
      result,
      throwsA(isA<ProfileAuthenticationChangedException>()),
    );
    expect(source.writtenData?['callsign'], 'TA1AAA');
    await source.dispose();
  });

  test(
    'stream switches uid, ignores stale events, and emits null on logout',
    () async {
      final source = _ControllableProfileDataSource(null);
      final repository = FirestoreUserProfileRepository.withDataSource(source);
      final values = <UserProfile?>[];
      final subscription = repository.watchCurrentUserProfile().listen(
        values.add,
      );

      source.emitUid('user-a');
      await pumpEventQueue();
      source.emitProfile('user-a', _profileMap(userAProfile));
      await pumpEventQueue();

      source.emitUid('user-b');
      await pumpEventQueue();
      source.emitProfile('user-a', _profileMap(userAProfile));
      source.emitProfile('user-b', {
        ..._profileMap(userAProfile),
        'callsign': 'TA1BBB',
      });
      await pumpEventQueue();

      source.emitUid(null);
      await pumpEventQueue();

      expect(values.map((profile) => profile?.callsign), [
        'TA1AAA',
        'TA1BBB',
        null,
      ]);
      await subscription.cancel();
      await source.dispose();
    },
  );
}

Map<String, dynamic> _profileMap(UserProfile profile) => {
  'callsign': profile.callsign,
  'name': profile.name,
  'city': profile.city,
  'locator': profile.locator,
  'role': profile.role.name,
};

class _ControllableProfileDataSource implements FirestoreUserProfileDataSource {
  _ControllableProfileDataSource(this.currentUid);

  @override
  String? currentUid;
  final readCompleter = Completer<Map<String, dynamic>?>();
  final writeCompleter = Completer<void>();
  final uidController = StreamController<String?>.broadcast();
  final profileControllers =
      <String, StreamController<Map<String, dynamic>?>>{};
  String? readUid;
  String? writeUid;
  Map<String, dynamic>? writtenData;

  @override
  Future<Map<String, dynamic>?> getProfile(String uid) {
    readUid = uid;
    return readCompleter.future;
  }

  @override
  Future<void> setProfile(String uid, Map<String, dynamic> data) {
    writeUid = uid;
    writtenData = data;
    return writeCompleter.future;
  }

  @override
  Stream<String?> watchUid() => uidController.stream;

  @override
  Stream<Map<String, dynamic>?> watchProfile(String uid) {
    return profileControllers
        .putIfAbsent(uid, StreamController.broadcast)
        .stream;
  }

  void emitUid(String? uid) {
    currentUid = uid;
    uidController.add(uid);
  }

  void emitProfile(String uid, Map<String, dynamic>? data) {
    profileControllers[uid]?.add(data);
  }

  Future<void> dispose() async {
    await uidController.close();
    for (final controller in profileControllers.values) {
      await controller.close();
    }
  }
}
