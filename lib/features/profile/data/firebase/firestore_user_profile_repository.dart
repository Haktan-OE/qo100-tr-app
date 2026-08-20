import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qo100_tr/features/profile/data/firebase/firestore_user_profile_data_source.dart';
import 'package:qo100_tr/features/profile/data/firebase/firestore_user_profile_mapper.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';
import 'package:qo100_tr/features/profile/domain/exceptions/profile_exceptions.dart';
import 'package:qo100_tr/features/profile/domain/repositories/user_profile_repository.dart';

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository(FirebaseAuth auth, FirebaseFirestore firestore)
    : this.withDataSource(
        FirebaseFirestoreUserProfileDataSource(auth, firestore),
      );

  FirestoreUserProfileRepository.withDataSource(this._dataSource);

  final FirestoreUserProfileDataSource _dataSource;

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final uid = _dataSource.currentUid;
    if (uid == null) return null;
    final data = await _dataSource.getProfile(uid);
    if (_dataSource.currentUid != uid) return null;
    return data == null
        ? null
        : FirestoreUserProfileMapper.fromMap(documentId: uid, data: data);
  }

  @override
  Stream<UserProfile?> watchCurrentUserProfile() => Stream.multi((listener) {
    StreamSubscription<Map<String, dynamic>?>? profileSubscription;
    final authSubscription = _dataSource.watchUid().listen((uid) {
      unawaited(profileSubscription?.cancel());
      profileSubscription = null;
      if (uid == null) {
        listener.add(null);
        return;
      }
      profileSubscription = _dataSource.watchProfile(uid).listen((data) {
        if (_dataSource.currentUid != uid) return;
        listener.add(
          data == null
              ? null
              : FirestoreUserProfileMapper.fromMap(documentId: uid, data: data),
        );
      }, onError: (_) => listener.addError(ProfileInfrastructureException()));
    }, onError: (_) => listener.addError(ProfileInfrastructureException()));
    listener.onCancel = () async {
      await authSubscription.cancel();
      await profileSubscription?.cancel();
    };
  });

  @override
  Future<UserProfile> updateCurrentUserProfile(UserProfile profile) async {
    final uid = _dataSource.currentUid;
    if (uid == null) throw ProfileInfrastructureException();
    FirestoreUserProfileMapper.assertUidMatchesProfile(uid, profile);
    await _dataSource.setProfile(
      uid,
      FirestoreUserProfileMapper.toMap(profile),
    );
    if (_dataSource.currentUid != uid) {
      throw ProfileAuthenticationChangedException();
    }
    return profile;
  }
}
