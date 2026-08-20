import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qo100_tr/features/profile/data/firebase/firestore_user_profile_mapper.dart';
import 'package:qo100_tr/features/profile/domain/entities/user_profile.dart';
import 'package:qo100_tr/features/profile/domain/exceptions/profile_exceptions.dart';
import 'package:qo100_tr/features/profile/domain/repositories/user_profile_repository.dart';

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      final snapshot = await _profileDocument(uid).get();
      final data = snapshot.data();
      return data == null
          ? null
          : FirestoreUserProfileMapper.fromMap(
              documentId: snapshot.id,
              data: data,
            );
    } on FirebaseException {
      throw ProfileInfrastructureException();
    }
  }

  @override
  Stream<UserProfile?> watchCurrentUserProfile() => Stream.multi((listener) {
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    profileSubscription;
    final authSubscription = _auth.authStateChanges().listen((user) {
      unawaited(profileSubscription?.cancel());
      profileSubscription = null;
      final uid = user?.uid;
      if (uid == null) {
        listener.add(null);
        return;
      }
      profileSubscription = _profileDocument(uid).snapshots().listen((
        snapshot,
      ) {
        if (_auth.currentUser?.uid != uid) return;
        final data = snapshot.data();
        listener.add(
          data == null
              ? null
              : FirestoreUserProfileMapper.fromMap(
                  documentId: snapshot.id,
                  data: data,
                ),
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
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw ProfileInfrastructureException();
    FirestoreUserProfileMapper.assertUidMatchesProfile(uid, profile);
    try {
      await _profileDocument(
        uid,
      ).set(FirestoreUserProfileMapper.toMap(profile));
      return profile;
    } on FirebaseException {
      throw ProfileInfrastructureException();
    }
  }

  DocumentReference<Map<String, dynamic>> _profileDocument(String uid) {
    return _firestore.collection('users').doc(uid);
  }
}
